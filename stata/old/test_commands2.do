use data/dta/data_intan.dta
//ssc install egenmore //install this to use xtile with egen

// Creating Fama and French industry classification, quantiles of intangible capital and other variables
gen intan_at = org_cap_comp/at
gen inv_at = investmentnet/totalassets
gen cre_ppe = buildings/netpropertyplantequipment
by GVKEY: gen inv_tang = ppegt - L.ppegt
by GVKEY: gen inv_intan = org_cap_comp - L.org_cap_comp
gen inv = inv_tang + inv_intan
gen inv_at = inv/at
gen cre_ppe = fatb/ppent
gen ltdebt_issue_at = dltis/at
gen cf = (ib + dp)/L.ppent

gen ff_indust = 1 if sic >= 100 & sic <= 999 | sic >= 2000 & sic <= 2399 | /*
		   */sic >= 2700 & sic <= 2749 | sic >= 3100 & sic <= 3199 |/*
		   */sic >= 3940 & sic <= 3989
replace ff_indust = 2 if sic >= 2500 & sic <= 2519 | sic >= 2590 & sic <= 2599 | /*
           */sic >= 3630 & sic <= 3659 | sic >= 3710 & sic <= 3711 | /*
           */sic == 3714 | sic == 3716 | sic >= 3750 & sic <= 3751 | /*
           */sic == 3792 | sic >= 3900 & sic <= 3939 | sic >= 3990 & sic <= 3999
replace ff_indust = 3 if sic >= 2520 & sic <= 2589 | sic >= 2600 & sic <= 2699 | sic >= 2750 & sic <= 2769 | /*
           */sic >= 3000 & sic <= 3099 | sic >= 3200 & sic <= 3569 | sic >= 3580 & sic <= 3629 | /*
           */sic >= 3700 & sic <= 3709 | sic >= 3712 & sic <= 3713 | sic == 3715 | sic >= 3717 & sic <= 3749 | /*
           */sic >= 3752 & sic <= 3791 | sic >= 3793 & sic <= 3799 | sic >= 3830 & sic <= 3839 | /*
           */sic >= 3860 & sic <= 3899
replace ff_indust = 4 if sic >= 1200 & sic <= 1399 | sic >= 2900 & sic <= 2999
replace ff_indust = 5 if sic >= 2800 & sic <= 2829 | sic >= 2840 & sic <= 2899
replace ff_indust = 6 if sic >= 3570 & sic <= 3579 | sic >= 3660 & sic <= 3692 | sic >= 3694 & sic <= 3699 | /*
           */sic >= 3810 & sic <= 3829 | sic >= 7370 & sic <= 7379
replace ff_indust = 7 if sic >= 4800 & sic <= 4899
replace ff_indust = 8 if sic >= 4900 & sic <= 4949
replace ff_indust = 9 if sic >= 5000 & sic <= 5999 | sic >= 7200 & sic <= 7299 | sic >= 7600 & sic <= 7699
replace ff_indust = 10 if sic >= 2830 & sic <= 2839 | sic == 3693 | sic >= 3840 & sic <= 3859 | sic >= 8000 & sic <= 8099
replace ff_indust = 12 if ff_indust ==.

egen med = xtile(intan_at), by(year ff_indust) n(2)
egen tercile = xtile(intan_at), by(year ff_indust) n(3)
egen quartile = xtile(intan_at), by(year ff_indust) n(4)
egen quintile = xtile(intan_at), by(year ff_indust) n(5)
egen decile = xtile(intan_at), by(year ff_indust) n(10)
//RUN UP TO THIS LINE AND MERGE WITH "df_1989.dta", generated from the code "gen_1989"

keep if _merge == 3 //only keep matched observations
drop if year == year[_n-1]
// Running the regressions

xtset GVKEY year

// Commercial real estate
xtreg inv_at c.cre_ppe##c.med c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.tercile c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.quartile c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.quintile c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.decile c.cf i.year if year >= 1990,fe cluster(ff_indust)

// Interest expense
xtreg inv_at c.ltdebt_issue_at##c.med c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.tercile c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.quartile c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.quintile c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.decile c.cf i.year if year >= 1990,fe cluster(ff_indust)

// Using dummies

// Commercial real estate
xtreg inv_at c.cre_ppe##c.d_med_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.d_terc_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.d_quar_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.d_quin_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.d_dec_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)

// Interest expense
xtreg inv_at c.ltdebt_issue_at##c.d_med_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.d_terc_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.d_quar_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.d_quin_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.ltdebt_issue_at##c.d_dec_1989 c.cf i.year if year >= 1990,fe cluster(ff_indust)
