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
********* Local projection regressions *
****************************************

est store emp_low

***************
* Intangibles
***************

cap rename (d_treas_2y_lag1) (mpshock)

xtreg dln_emp1  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)

xtreg dln_emp1  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)

cap rename (mpshock) (d_treas_2y_lag1)

esttab emp_low emp_mid emp_high emp_low_assets emp_mid_assets emp_high_assets using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/orbis_emp.tex, coeflabels(c.mpshock#c.ter_low "Δ 2-year Treasury(t-1) x Tercile low" c.mpshock#c.ter_mid "Δ 2-year Treasury(t-1) x Tercile mid" c.mpshock#c.ter_high "Δ 2-year Treasury(t-1) x Tercile high") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(_cons)

*************
* Tangibles
*************
cap rename (d_treas_2y_lag1) (mpshock)

xtreg dln_emp1  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 1,fe cluster(ff_indust)

xtreg dln_emp1  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)

cap rename (mpshock) (d_treas_2y_lag1)


***************************************
* Comparison intangible vs. tangible
***************************************

cap rename (d_treas_2y_lag1) (mpshock)

xtreg dln_emp1  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)

xtreg dln_emp1  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp2  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp3  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp4  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp5  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp6  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp7  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)
xtreg dln_emp8  c.mpshock##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year,fe cluster(ff_indust)

cap rename (mpshock) (d_treas_2y_lag1)



