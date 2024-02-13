//Regressions of employment change on interest rate change. Orbis data.

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt.dta

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_all_measures.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt.dta

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

encode bvdidnumber, generate(bvdid_factor)
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
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_all_measures.dta, replace


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

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets

xtreg dln_emp c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_low
xtreg dln_emp c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_mid
xtreg dln_emp c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low#c.ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid#c.ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high#c.ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_high_assets

cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ln_assets c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high c.mpshock#c.ter_low#c.ln_assets c.mpshock#c.ter_mid#c.ln_assets c.mpshock#c.ter_high#c.ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets

cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_low
xtreg dln_emp c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_mid
xtreg dln_emp c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_high
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock ln_assets dln_netsales_lag1 cash_at_lag1 i.year,fe cluster(ff_indust) 
est store emp_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ln_assets "Δ 2-year Treasury(t-1) x Log(assets)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high" c.mpshock#c.ter_low#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile low x Log(assets)" c.mpshock#c.ter_mid#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile mid x Log(assets)" c.mpshock#c.ter_high#c.ln_assets "Δ 2-year Treasury(t-1) x Tercile high x Log(assets)") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons dln_netsales_lag1 cash_at_lag1 dln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1)
