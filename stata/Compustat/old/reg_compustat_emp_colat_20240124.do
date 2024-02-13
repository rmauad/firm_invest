//Regressions of employment change on interest rate change. Compustat data.

use data/dta/db_reg_comp.dta

xtset GVKEY year_q

// Labeling the variables
label variable inv_tot_at " "
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"
label variable dln_emp " "



****************************************
********* Galina's suggestions *********
****************************************



cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock c.mpshock#d_less_const c.mpshock#c.ter_bot c.mpshock#d_less_const#c.ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
est store emp_low

xtreg dln_emp c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp1 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp1 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp2 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp2 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp3 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp3 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp4 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp4 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp5 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp5 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_emp6 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_emp6 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)


xtreg dln_inv1 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv2 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv3 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv4 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv5 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv6 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)

xtreg dln_inv1 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv2 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv3 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv4 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv5 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv6 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv7 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv8 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv9 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv10 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv11 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv12 c.mpshock##d_less_const ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_inv1 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv2 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv3 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv4 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv5 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv6 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv7 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv8 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv9 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv10 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv11 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)
xtreg dln_inv12 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_bot == 1,fe cluster(ff_indust)

xtreg dln_inv1 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv2 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv3 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv4 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv5 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv6 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv7 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv8 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv9 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv10 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv11 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)
xtreg dln_inv12 c.mpshock ln_assets sales_growth_lag1 cash_at_lag1 i.year if qua_top == 1,fe cluster(ff_indust)


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


