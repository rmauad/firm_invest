//Regressions of employment change on interest rate change. Compustat data.

use data/dta/db_reg_q_cf_old_controls.dta
use data/dta/db_reg_state.dta

xtset GVKEY year_q

// //Generate lagged variables
// gen JKff3_q_lag1 = l1.JKff3_q/100
gen sales_growth_lag1 = l1.sales_gr
gen d_treas_2y_lag1 = l1.d_treas_2y_q/100
gen cash_at_lag1 = l1.cash_at
gen Ind_prod_lag1 = l1.Ind_prod
gen Inflation_lag1 = l1.CPI
gen RGDP_lag1 = l1.RGDP
gen dln_RGDP_lag1 = l1.dln_RGDP
gen d_Ind_prod_lag1 = l1.d_Ind_prod
gen ln_assets = ln(atq)

// Labeling the variables
label variable inv_tot_at " "
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"
label variable dln_emp " "


gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

gen med_low = 0
replace med_low = 1 if med == 1
gen med_high = 0
replace med_high = 1 if med == 2

gen d_less_const = 0
replace d_less_const = 1 if (state == "TX" | state == "LA") & (year >= 1997 & year <= 2003)
replace d_less_const = 1 if state == "AL" & (year >= 2001 & year <= 2003)

use data/dta/db_reg_q_cf_old_controls.dta
replace GVKEY = GVKEY/10 
merge m:1 GVKEY using data/dta/state.dta, keep(1 3) nogen
save data/dta/db_reg_state.dta, replace
gen inv_at = capxy/atq


***********************
**   Regressions
***********************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 sales_growth_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_low
xtreg dln_emp c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_mid
xtreg dln_emp c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store emp_2yt_high
cap rename (mpshock) (d_treas_2y_lag1)

// cap rename (JKff3_q_lag1) (mpshock)
// xtreg dln_emp c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_low
// xtreg dln_emp c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_mid
// xtreg dln_emp c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
// est store emp_jk_high
// cap rename (mpshock) (JKff3_q_lag1)

esttab emp_2yt_low emp_2yt_mid emp_2yt_high using output/tex/compustat_jt.tex, coeflabels(mpshock "Δ 2-year Treasury(t-1)" c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year _cons ter_low ter_mid ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1)


****************************************
********* Galina's suggestions *********
****************************************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock##c.ter_low ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_low
xtreg dln_emp c.mpshock##c.ter_mid ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_mid
xtreg dln_emp c.mpshock##c.ter_high ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if ((state != "TX" & state != "LA" & state != "AL") | (state == "AL" & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_high_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)
// ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1


cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock##c.d_less_const ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_low
xtreg dln_emp c.mpshock#d_less_const#c.ter_high ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_mid
xtreg dln_emp c.mpshock#d_less_const#c.ter_high ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1,fe cluster(ff_indust)
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if ((state != "TX" & state != "LA" & state != "AL") | (state == "AL" & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_high_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)


cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_at c.mpshock##c.d_less_const ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if med_low == 1,fe cluster(ff_indust)
est store emp_low
xtreg inv_at c.mpshock##c.d_less_const ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if med_high == 1,fe cluster(ff_indust)
est store emp_mid
xtreg inv_at c.mpshock##c.d_less_const ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if ter_high == 1,fe cluster(ff_indust)
est store emp_high

xtreg dln_emp c.mpshock#c.ter_low ln_assets sales_growth_lag1 cash_at_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 if ((state != "TX" & state != "LA" & state != "AL") | (state == "AL" & year >= 2001 & year <= 2003)),fe cluster(ff_indust)
est store emp_low_assets
xtreg dln_emp c.mpshock#c.ter_mid ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_mid_assets
xtreg dln_emp c.mpshock#c.ter_high ln_assets dln_netsales_lag1 cash_at_lag1 ln_RGDP_lag1 d_ind_prod_lag1 CPI_lag1 if (d_tx_la == 0 & d_al == 0) & (year >= 1997 & year <= 2003),fe cluster(ff_indust)
est store emp_high_assets
cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)


