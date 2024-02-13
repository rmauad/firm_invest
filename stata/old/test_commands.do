//Scratch code to test commands
use data/dta/data_intan.dta
keep if year == 1989
gen at_test = at*2
keep GVKEY at_test
duplicates drop GVKEY, force
save data/dta/df_1989_merge_test.dta



merge m:1 GVKEY using data/dta/df_1989_merge_test.dta, keep(3) nogen
keep if _merge == 3 //only keep matched observations
drop if year == year[_n-1] //in case there are repeated time values within the panel


//ssc install egenmore //install this to use xtile with egen
use org_cap_comp using data/dta/data_intan.dta
append using data/dta/data_intan_copy.dta, keep(year at)


gen intan_at = org_cap_comp/at

// Creating Fama and French industry classification, quantiles of intangible capital and other variables

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

gen d_med_only_1989 = 1 if year == 1989 & med == 2
replace d_med_only_1989 = 0 if d_med_only_1989 ==.
gen d_terc_only_1989 = 1 if year == 1989 & tercile == 3
replace d_terc_only_1989 = 0 if d_terc_only_1989 ==.
gen d_quar_only_1989 = 1 if year == 1989 & quartile == 4
replace d_quar_only_1989 = 0 if d_quar_only_1989 ==.
gen d_quin_only_1989 = 1 if year == 1989 & quintile == 5
replace d_quin_only_1989 = 0 if d_quin_only_1989 ==.
gen d_dec_only_1989 = 1 if year == 1989 & decile == 10
replace d_dec_only_1989 = 0 if d_dec_only_1989 ==.

gen med_only_1989 = med if year == 1989
replace med_only_1989 = 0 if med_only_1989 ==.
gen terc_only_1989 = tercile if year == 1989
replace terc_only_1989 = 0 if terc_only_1989 ==.
gen quar_only_1989 = quartile if year == 1989
replace quar_only_1989 = 0 if quar_only_1989 ==.
gen quin_only_1989 = quintile if year == 1989
replace quin_only_1989 = 0 if quin_only_1989 ==.
gen dec_only_1989 = decile if year == 1989
replace dec_only_1989 = 0 if dec_only_1989 ==.

keep if year == 1989
duplicates drop GVKEY, force
keep GVKEY med_only_1989 terc_only_1989 quar_only_1989 quin_only_1989 dec_only_1989 /*
         */d_med_only_1989 d_terc_only_1989 d_quar_only_1989 d_quin_only_1989 d_dec_only_1989
rename (med_only_1989 terc_only_1989 quar_only_1989 quin_only_1989 dec_only_1989 /*
         */d_med_only_1989 d_terc_only_1989 d_quar_only_1989 d_quin_only_1989 d_dec_only_1989) /*
		 */(med_1989 terc_1989 quar_1989 quin_1989 dec_1989 /*
		 */d_med_1989 d_terc_1989 d_quar_1989 d_quin_1989 d_dec_1989)
		 
save "data/dta/df_1989_test.dta"
