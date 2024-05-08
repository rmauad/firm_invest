//Regressions of investment/assets on interest rate change. Orbis data.

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

gen cash_at = cashcashequivalent/totalassets
gen cash_at_lag1 = l1.cash_at
gen netsales_lag1 = l1.netsales

gen d_treas_2y_lag1 = l1.d_treas_2y
gen JKff3_q_lag1 = l1.JKff3_y

// Generating investment/assets
gen int_inv =.
gen intangibles_lag1 = ln(intangibles[_n- 1])

sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {

    sort bvdidnumber year

	by bvdidnumber: replace int_inv = intangibles - intangibles_lag1 if _n > 1
}

gen inv = int_inv - capitalexpenditures
gen inv_at = inv/totalassets


gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

//save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta, replace


************************************************************
*		 Regressions					   
************************************************************


cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_at c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_low
xtreg inv_at c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_mid
xtreg inv_at c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_high
cap rename (mpshock) (d_treas_2y_lag1)

// cap rename (JKff3_q_lag1) (mpshock)
// xtreg inv_at c.mpshock#c.ter_low dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_low
// xtreg inv_at c.mpshock#c.ter_mid dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_mid
// xtreg inv_at c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_high
// cap rename (mpshock) (JKff3_q_lag1)

esttab inv_2yt_low inv_2yt_mid inv_2yt_high using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_inv.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)


************************************************************
*		Galina's suggestions					   
************************************************************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_at c.mpshock#c.ter_low c.mpshock#c.ter_mid c.mpshock#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt
cap rename (mpshock) (d_treas_2y_lag1)

esttab inv_2yt using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_inv.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_at c.mpshock#c.tercile#stck_exc_ind dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt
cap rename (mpshock) (d_treas_2y_lag1)

esttab inv_2yt using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_inv.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons dln_netsales_lag1 cash_at_lag1)
