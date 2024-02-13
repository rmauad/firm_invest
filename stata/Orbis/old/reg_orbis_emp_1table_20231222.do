//Regressions of employment change on interest rate change. Orbis data.

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt.dta

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_all_measures.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt.dta

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

gen cash_at = cashcashequivalent/totalassets
gen cash_at_lag1 = l1.cash_at
gen netsales_lag1 = l1.netsales

gen d_treas_2y_lag1 = l1.d_treas_2y

gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

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

// //save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta, replace
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_complete_intan_cap_all_measures.dta, replace

// gen stck_exc_ind_new = 0
// replace stck_exc_ind_new = 1 if stck_exc_ind == 0
// drop stck_exc_ind
// rename stck_exc_ind_new stck_exc_ind

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


// cap rename (JKff3_q_lag1) (mpshock)
// xtreg dln_emp c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_low
// xtreg dln_emp c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_mid
// xtreg dln_emp c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_high
// cap rename (mpshock) (JKff3_q_lag1)

************************************************************
*		 Galina's suggestions					   
************************************************************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_2yt using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.tercile#stck_exc_ind dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_2yt using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)

