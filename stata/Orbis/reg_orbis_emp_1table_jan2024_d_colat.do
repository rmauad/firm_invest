//Regressions of employment change on interest rate change. Orbis data.

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt.dta

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt.dta

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

//encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

// gen cash_at = cashcashequivalent/totalassets
// gen cash_at_lag1 = l1.cash_at
// gen netsales_lag1 = l1.netsales

// gen d_treas_2y_lag1 = l1.d_treas_2y

// gen ter_low = 0
// replace ter_low = 1 if tercile == 1
// gen ter_mid = 0
// replace ter_mid = 1 if tercile == 2
// gen ter_high = 0
// replace ter_high = 1 if tercile == 3

// // Generating dln_emp
// gen dln_emp = .
// gen ln_emp = ln(numberofemployees)
// gen ln_emp_lag1 = ln(numberofemployees[_n- 1])

// sort bvdidnumber year

// levelsof bvdidnumber, local(firm_list)
// foreach bvdidnumber of local firm_list {

//     sort bvdidnumber year

// 	by bvdidnumber: replace dln_emp = ln_emp - ln_emp_lag1 if _n > 1
// }

// // Control variables
// gen dln_netsales = .
// gen ln_netsales = ln(netsales)
// gen ln_netsales_lag1 = ln(netsales[_n- 1])

// sort bvdidnumber year

// levelsof bvdidnumber, local(firm_list)
// foreach bvdidnumber of local firm_list {

//     sort bvdidnumber year

// 	by bvdidnumber: replace dln_netsales = ln_netsales - ln_netsales_lag1 if _n > 1
// }

// gen dln_netsales_lag1 = dln_netsales[_n-1]

// ********************
// ** Macro controls
// ********************

// gen d_ind_prod = .
// gen ind_prod_lag1 = Ind_prod[_n- 1]

// sort bvdidnumber year

// levelsof bvdidnumber, local(firm_list)
// foreach bvdidnumber of local firm_list {

//     sort bvdidnumber year

// 	by bvdidnumber: replace d_ind_prod = (Ind_prod/ind_prod_lag1)-1 if _n > 1
// }

// gen d_ind_prod_lag1 = d_ind_prod[_n-1]


// gen dln_RGDP = .
// gen ln_RGDP = ln(RGDP)
// gen ln_RGDP_lag1 = ln_RGDP[_n-1]

// sort bvdidnumber year

// levelsof bvdidnumber, local(firm_list)
// foreach bvdidnumber of local firm_list {

//     sort bvdidnumber year

// 	by bvdidnumber: replace dln_RGDP = ln_RGDP - ln_RGDP_lag1 if _n > 1
// }

// gen dln_RGDP_lag1 = dln_RGDP[_n-1]
// gen CPI_lag1 = CPI[_n-1]
// gen ln_assets = ln(totalassets)

// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap.dta, replace
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap.dta, replace

** Alternative ranking - only by year, not industry

drop med tercile quartile quintile decile
drop ter_low ter_mid ter_high

egen med = xtile(intan_cap), by(year) n(2)
egen tercile = xtile(intan_cap), by(year) n(3)
egen quartile = xtile(intan_cap), by(year) n(4)
egen quintile = xtile(intan_cap), by(year) n(5)
egen decile = xtile(intan_cap), by(year) n(10)

// gen ter_low = 0
// replace ter_low = 1 if tercile == 1
// gen ter_mid = 0
// replace ter_mid = 1 if tercile == 2
// gen ter_high = 0
// replace ter_high = 1 if tercile == 3

gen med_low = 0
replace med_low = 1 if med == 1
gen med_high = 0
replace med_high = 1 if med == 2



// Including data on states

// use year bvdidnumber stateorprovinceinusorcanada using /homes/nber/mauadr/orbis.work/orbis4/bycnty/US/contact.dta
// merge 1:m bvdidnumber using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap.dta, keep(3) nogen
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_state.dta, replace
 
// // Creating dummy for states/years where a law was enacted reducing uncertainty about seizing assets
// gen d_tx_la = 0
// replace d_tx_la = 1 if (stateorprovinceinusorcanada == "TX" | stateorprovinceinusorcanada == "LA")
// gen d_al = 0
// replace d_al = 1 if stateorprovinceinusorcanada == "AL"


// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_state.dta, replace


************************************************************
*		 Regressions					   
************************************************************


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_low
xtreg dln_emp c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_mid
xtreg dln_emp c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_high
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_2yt_low emp_2yt_mid emp_2yt_high using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)


************************************************************
*		 Galina's suggestions					   
************************************************************
// xtreg dln_emp c.mpshock#stck_exc_ind ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
// est store emp_assets

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if ((d_tx_la == 1 & year >= 1997 & year <= 2003) | (d_al == 1 & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_low
xtreg dln_emp c.mpshock#c.ter_mid ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if ((d_tx_la == 1 & year >= 1997 & year <= 2003) | (d_al == 1 & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_mid
xtreg dln_emp c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if ((d_tx_la == 1 & year >= 1997 & year <= 2003) | (d_al == 1 & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_high_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)
// ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1

// Using median
cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.med_low ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if ((d_tx_la == 1 & year >= 1997 & year <= 2003) | (d_al == 1 & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_low
xtreg dln_emp c.mpshock#c.med_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if ((d_tx_la == 1 & year >= 1997 & year <= 2003) | (d_al == 1 & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_mid

xtreg dln_emp c.mpshock#c.med_low ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.med_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_mid_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)

//

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 0,fe cluster(ff_indust)
est store emp_assets
xtreg dln_emp c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 0,fe cluster(ff_indust)
est store emp_low
xtreg dln_emp c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 0,fe cluster(ff_indust)
est store emp_mid
xtreg dln_emp c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 0,fe cluster(ff_indust)
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low#c.ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 1,fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid#c.ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 1,fe cluster(ff_indust)
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high#c.ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if stck_exc_ind == 1,fe cluster(ff_indust)
est store emp_high_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)



******************************************************************************************************
******************************************************************************************************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#stck_exc_ind c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high c.mpshock#c.ter_low#stck_exc_ind c.mpshock#c.ter_mid#stck_exc_ind c.mpshock#c.ter_high#stck_exc_ind ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#stck_exc_ind ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#stck_exc_ind c.mpshock#c.tercile c.mpshock#c.tercile#stck_exc_ind ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.tercile ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)
