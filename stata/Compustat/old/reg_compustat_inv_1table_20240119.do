//Regressions of employment change on interest rate change. Compustat data.

use data/dta/db_reg_q_cf_old_controls.dta

xtset GVKEY year_q

// //Generate lagged variables
gen JKff3_q_lag1 = l1.JKff3_q/100
gen sales_growth_lag1 = l1.sales_gr
gen d_treas_2y_lag1 = l1.d_treas_2y_q/100
gen cash_at_lag1 = l1.cash_at
gen Ind_prod_lag1 = l1.Ind_prod
gen Inflation_lag1 = l1.CPI
gen RGDP_lag1 = l1.RGDP
gen dln_RGDP_lag1 = l1.dln_RGDP
gen d_Ind_prod_lag1 = l1.d_Ind_prod

// Labeling the variables
label variable inv_tot_at " "
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"
label variable dln_emp " "
label variable JKff3_q_lag1 "JKff3 shock(t-1)"


gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

***********************
**   Regressions
***********************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_low
xtreg inv_tot_at c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_mid
xtreg inv_tot_at c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store inv_2yt_high
cap rename (mpshock) (d_treas_2y_lag1)

// cap rename (JKff3_q_lag1) (mpshock)
// xtreg inv_tot_at c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_low
// xtreg inv_tot_at c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_mid
// xtreg inv_tot_at c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store inv_jk_high
// cap rename (mpshock) (JKff3_q_lag1)

esttab inv_2yt_low inv_2yt_mid inv_2yt_high using output/tex/compustat_jt.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons ter_low ter_mid ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1)
