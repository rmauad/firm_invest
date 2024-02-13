//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and leverage on several alternative monetary policy shocks.

//use data/dta/db_reg_q_cf_old_controls.dta
use data/dta/db_reg_emp_cf_q_with_exit.dta
//use data/dta/db_reg_emp_cf_q_with_exit.dta
//winsor2 inv_tot_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

// Volume of debt
xtset GVKEY year_q

// //Generate lagged variables
// gen ffrate_zlb_lag1 = l1.ffrate_zlb
// gen ffrate_zlb_lag2 = l2.ffrate_zlb
// gen ffrate_zlb_lag3 = l3.ffrate_zlb
// gen ns_lag1 = l1.ns_q/100 // Nakamura-Steinsson (QJE, 2018) MP shock
// gen ns_lag2 = l2.ns_q/100
// gen brw_lag1 = l1.brw_q/100 //Bu-Rogers-Wu (JME, March 2021) MP shock
// gen brw_lag2 = l2.brw_q/100
// gen JKff3_q_lag1 = l1.JKff3_q/100 //Paper by John Rogers
// gen JKff3_q_lag2 = l2.JKff3_q/100
// gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor/100 // Paper by Eric Swanson
// gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor/100 
// gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor/100 // Paper by Eric Swanson
// gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor/100 
// gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor/100 // Paper by Eric Swanson
// gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor/100
// gen gdp_g_lag1 = l1.gdp_g
// gen ip_g_lag1 = l1.ip_g
// gen log_inflation_lag1 = l1.log_inflation
// gen d_cash_at_lag1 = l1.d_cash_at 

// gen ir_diff_delta_lag1 = l1.ir_diff_delta
// gen ir_diff_delta_lag2 = l2.ir_diff_delta
// gen ir_diff_10y_2y_lag1 = l1.ir_diff_10y_2y
// gen ir_diff_10y_2y_lag2 = l2.ir_diff_10y_2y

//gen log_inv_tot_at = log(inv_tot_at)
//gen log_capx_ppe = log(capx_ppe)
//gen log_ltdebt_issue_at = log(ltdebt_issue_at)
//gen log_inv_tot = log(inv_tot)
gen sales_growth_lag1 = l1.sales_gr
gen cash_at_lag1 = l1.cash_at
gen CPI_lag1 = l1.CPI
gen RGDP_lag1 = l1.RGDP
gen Ind_prod_lag1 = l1.Ind_prod

// //Labeling the variables
//label variable log_ltdebt_issue_at " " //"Log(LT Debt Issuance)/assets"
label variable inv_tot_at " "
label variable debt_at " "
//label variable inv_tang_at " "
//label variable inv_intan_at " "
label variable ffrate_zlb_lag1 "FF rate(t-1)"
label variable ffrate_zlb_lag2 "FF rate(t-2)"
//label variable mb "Market-to-book"
//label variable cf "Cash flow"
label variable sales_growth_lag1 "Sales growth(t-1)"
label variable cash_at "Cash/assets"
label variable Ind_prod "Ind production"
//label variable ir_diff_delta "LT interest rate change (10y-2y)"
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"

label variable dln_emp " "
label variable ns_lag1 "NS shock(t-1)"
label variable ns_lag2 "NS shock(t-2)"
label variable brw_lag1 "BRW shock(t-1)"
label variable brw_lag2 "BRW shock(t-2)"
label variable JKff3_q_lag1 "JKff3 shock(t-1)"
label variable JKff3_q_lag2 "JKff3 shock(t-2)"
label variable MP_S_Fffactor_lag1 "FFfactor shock(t-1)"
label variable MP_S_Fffactor_lag2 "FFfactor shock(t-2)"
label variable MP_S_Fgfactor_lag1 "Fgfactor shock(t-1)"
label variable MP_S_Fgfactor_lag2 "Fgfactor shock(t-2)"
label variable MP_S_LSAPfactor_lag1 "LSAPFactor shock(t-1)"
label variable MP_S_LSAPfactor_lag2 "LSAPFactor shock(t-2)"




// Logit regression for the firms' survival probability
* Takes time to run - so save the database after running.

// xtlogit bankruptcy med sales_growth_lag1 cf cash_at CPI RGDP Ind_prod i.year if year >= 1990
// predict b_pred_med, pu0
// xtlogit bankruptcy tercile sales_growth_lag1 cf cash_at CPI RGDP Ind_prod i.year if year >= 1990
// predict b_pred_ter, pu0
// xtlogit bankruptcy quartile  sales_growth_lag1 cf cash_at CPI RGDP Ind_prod i.year if year >= 1990
// predict b_pred_qua, pu0
// xtlogit bankruptcy quintile sales_growth_lag1 cf cash_at CPI RGDP Ind_prod i.year if year >= 1990
// predict b_pred_qui, pu0
// xtlogit bankruptcy decile sales_growth_lag1 cf cash_at CPI RGDP Ind_prod i.year if year >= 1990
// predict b_pred_dec, pu0
//save data/dta/db_reg_emp_cf_q_with_exit_old_controls.dta, replace



***************
* One line in table
***************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile sales_growth_lag1 cash_at_lag1 CPI_lag1 RGDP_lag1 Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Treas_2y
cap rename (mpshock) (d_treas_2y_lag1)

esttab Treas_2y using output/tex/emp_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile sales_growth_lag1 cash_at CPI RGDP Ind_prod)



************************************************************
* 						 Investment 					   *
************************************************************

// xtreg dln_emp c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
// est store wu_xia
xtreg inv_tot_at c.brw_lag1##c.tercile c.brw_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store brw
xtreg inv_tot_at c.ns_lag1##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store ns
xtreg inv_tot_at c.JKff3_q_lag1##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store jk
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Fgfactor
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.tercile c.MP_S_LSAPfactor_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor

//esttab brw ns jk Fffactor Fgfactor LSAPfactor using output/tex/inv_all_shocks_tercile.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year b_pred_ter tercile brw_lag1 brw_lag2 c.brw_lag2#c.tercile ns_lag1 JKff3_q_lag1 MP_S_Fffactor_lag1 MP_S_Fgfactor_lag1 MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.tercile cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)
esttab brw ns jk Fffactor Fgfactor LSAPfactor using output/tex/inv_all_shocks_tercile.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile brw_lag2 c.brw_lag2#c.tercile MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.tercile cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


***************
* One line in table
***************

cap rename (brw_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.brw_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store brw
cap rename (mpshock) (brw_lag1)
cap rename (ns_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store ns
cap rename (mpshock) (ns_lag1)
cap rename (JKff3_q_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store jk
cap rename (mpshock) (JKff3_q_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_Fgfactor_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Fgfactor
cap rename (mpshock) (MP_S_Fgfactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.MP_S_LSAPfactor_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_LSAPfactor_lag1)
cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Treas_2y
cap rename (mpshock) (d_treas_2y_lag1)

//esttab brw ns jk Fffactor Fgfactor LSAPfactor using output/tex/inv_all_shocks_tercile.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year b_pred_ter tercile brw_lag1 brw_lag2 c.brw_lag2#c.tercile ns_lag1 JKff3_q_lag1 MP_S_Fffactor_lag1 MP_S_Fgfactor_lag1 MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.tercile cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)
esttab brw ns jk Fffactor Fgfactor LSAPfactor Treas_2y using output/tex/inv_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile brw_lag2 c.brw_lag2#c.tercile MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.tercile cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


***************
* All quant
***************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store med
xtreg inv_tot_at c.mpshock##c.tercile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store ter
xtreg inv_tot_at c.mpshock##c.quartile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store qua
xtreg inv_tot_at c.mpshock##c.quintile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store qui
xtreg inv_tot_at c.mpshock##c.decile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store dec
cap rename (mpshock) (d_treas_2y_lag1)

esttab med ter qua qui dec using output/tex/emp_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile sales_growth_lag1 cash_at CPI RGDP Ind_prod)
