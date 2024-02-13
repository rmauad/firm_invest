//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and leverage on several alternative monetary policy shocks.

//use data/dta/db_reg_q_cf_old_controls.dta
use data/dta/db_reg_emp_cf_q_with_exit.dta
winsor2 inv_tot_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

// Volume of debt
xtset GVKEY year_q

// //Generate lagged variables
gen ffrate_zlb_lag1 = l1.ffrate_zlb
gen ffrate_zlb_lag2 = l2.ffrate_zlb
gen ffrate_zlb_lag3 = l3.ffrate_zlb
gen ns_lag1 = l1.ns_q // Nakamura-Steinsson (QJE, 2018) MP shock
gen ns_lag2 = l2.ns_q
gen brw_lag1 = l1.brw_q/100 //Bu-Rogers-Wu (JME, March 2021) MP shock
gen brw_lag2 = l2.brw_q/100
gen JKff3_q_lag1 = l1.JKff3_q/100 //Paper by John Rogers
gen JKff3_q_lag2 = l2.JKff3_q/100
gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor // Paper by Eric Swanson
gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor 
gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor // Paper by Eric Swanson
gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor 
gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor/100 // Paper by Eric Swanson
gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor/100
//gen gdp_g_lag1 = l1.gdp_g
//gen ip_g_lag1 = l1.ip_g
//gen log_inflation_lag1 = l1.log_inflation
//gen d_cash_at_lag1 = l1.d_cash_at 

// gen ir_diff_delta_lag1 = l1.ir_diff_delta
// gen ir_diff_delta_lag2 = l2.ir_diff_delta
// gen ir_diff_10y_2y_lag1 = l1.ir_diff_10y_2y
// gen ir_diff_10y_2y_lag2 = l2.ir_diff_10y_2y

//gen log_inv_tot_at = log(inv_tot_at)
//gen log_capx_ppe = log(capx_ppe)
//gen log_ltdebt_issue_at = log(ltdebt_issue_at)
//gen log_inv_tot = log(inv_tot)
gen sales_growth_lag1 = l1.sales_gr

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
save data/dta/db_reg_emp_cf_q_with_exit_old_controls.dta, replace


************************************************************
* 						 Employment 					   *
************************************************************

* Wu and Shia ffrate_zlb (DO NOT INCLUDE)

xtreg dln_emp c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.cf b_pred_med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.cf b_pred_ter sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.cf b_pred_qua sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.cf b_pred_qui sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.cf b_pred_dec sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)

xtreg dln_emp c.ffrate_zlb_lag1##c.med c.cf b_pred_med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ffrate_zlb_lag1##c.tercile c.cf b_pred_ter sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.ffrate_zlb_lag1##c.quartile c.cf b_pred_qua sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.ffrate_zlb_lag1##c.quintile c.cf b_pred_qui sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.ffrate_zlb_lag1##c.decile c.cf b_pred_dec sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


* Nakamura-Steinsson (DO NOT INCLUDE) - Interaction term is negative.

xtreg dln_emp c.ns_lag1##c.med c.ns_lag2##c.med c.cf b_pred_med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ns_lag1##c.tercile c.ns_lag2##c.tercile c.cf b_pred_ter sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.ns_lag1##c.quartile c.ns_lag2##c.quartile c.cf b_pred_qua sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.ns_lag1##c.quintile c.ns_lag2##c.quintile c.cf b_pred_qui sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.ns_lag1##c.decile c.ns_lag2##c.decile c.cf b_pred_dec sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)

* The MP shock on its own is not significant, so don't include it in the regressions. 
xtreg dln_emp c.ns_lag1##c.med b_pred_med d_cash_at_lag1 sales_growth_lag1 log_inflation_lag1 gdp_g_lag1 ip_g_lag1 i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ns_lag1##c.tercile b_pred_ter d_cash_at_lag1 sales_growth_lag1 log_inflation_lag1 gdp_g_lag1 ip_g_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.ns_lag1##c.quartile b_pred_qua d_cash_at_lag1 sales_growth_lag1 log_inflation_lag1 gdp_g_lag1 ip_g_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.ns_lag1##c.quintile b_pred_qui d_cash_at_lag1 sales_growth_lag1 log_inflation_lag1 gdp_g_lag1 ip_g_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.ns_lag1##c.decile b_pred_dec d_cash_at_lag1 sales_growth_lag1 log_inflation_lag1 gdp_g_lag1 ip_g_lag1 i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_ns.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec)


* Bu-Rogers-Wu (JME, March 2021) MP shock (INCLUDE WITH TWO LAGS)


* With both lags, MP shock on its own is negative and significant. The interaction term is positive and significant.
xtreg dln_emp c.brw_lag1##c.med c.brw_lag2##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.brw_lag1##c.tercile c.brw_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.brw_lag1##c.quartile c.brw_lag2##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.brw_lag1##c.quintile c.brw_lag2##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.brw_lag1##c.decile c.brw_lag2##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_brw.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year cf med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec brw_lag2 c.brw_lag2#c.med c.brw_lag2#c.tercile c.brw_lag2#c.quartile c.brw_lag2#c.quintile c.brw_lag2#c.decile)

* With one lag, the results are reversed. MP shock on its own is positive, and the interaction term is negative and significant.
xtreg dln_emp c.brw_lag1##c.med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.brw_lag1##c.tercile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.brw_lag1##c.quartile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.brw_lag1##c.quintile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.brw_lag1##c.decile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)


* Paper by John Rogers (INCLUDE WITH TWO LAGS)


* With both lags, MP shock on its own is negative and significant, and the interaction term is positive and significant for the second lag (and mostly negative and significant for the first lag)
xtreg dln_emp c.JKff3_q_lag1##c.med c.JKff3_q_lag2##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.JKff3_q_lag1##c.tercile c.JKff3_q_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.JKff3_q_lag1##c.quartile c.JKff3_q_lag2##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.JKff3_q_lag1##c.quintile c.JKff3_q_lag2##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.JKff3_q_lag1##c.decile c.JKff3_q_lag2##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_JKff3.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year cf med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec JKff3_q_lag2 c.JKff3_q_lag2#c.med c.JKff3_q_lag2#c.tercile c.JKff3_q_lag2#c.quartile c.JKff3_q_lag2#c.quintile c.JKff3_q_lag2#c.decile)


* With one lag, MP shock on its own is negative and significant, and the interaction term is insignificant
xtreg dln_emp c.JKff3_q_lag1##c.med b_pred_med c.cf sales_growth_lag1 CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.JKff3_q_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.JKff3_q_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.JKff3_q_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.JKff3_q_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)


* Measure 1 by Eric Swanson (DO NOT INCLUDE)


* With both lags, MP shock on its own is negative and significant, and the interaction term on the second lag is positive and significant for most quantiles.
xtreg dln_emp c.MP_S_Fffactor_lag1##c.med c.MP_S_Fffactor_lag2##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fffactor_lag1##c.tercile c.MP_S_Fffactor_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quartile c.MP_S_Fffactor_lag2##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quintile c.MP_S_Fffactor_lag2##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.decile c.MP_S_Fffactor_lag2##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_FFfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec JKff3_q_lag1 c.JKff3_q_lag1#c.med c.JKff3_q_lag1#c.tercile c.JKff3_q_lag1#c.quartile c.JKff3_q_lag1#c.quintile c.JKff3_q_lag1#c.decile)

* With one lag, MP shock on its own is negative and significant, and the interaction term is insignificant
xtreg dln_emp c.MP_S_Fffactor_lag1##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fffactor_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)


* Measure 2 by Eric Swanson (DO NOT INCLUDE)


* With both lags, MP shock on its own is positive and significant, and the interaction terms are negative and significant
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.med c.MP_S_Fgfactor_lag2##c.med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.tercile c.MP_S_Fgfactor_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quartile c.MP_S_Fgfactor_lag2##c.quartile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quintile c.MP_S_Fgfactor_lag2##c.quintile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.decile c.MP_S_Fgfactor_lag2##c.decile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)

* With one lag, MP shock on its own is positive and significant, and the interaction term is negative and significant
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.med  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.tercile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quartile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quintile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.decile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


* Measure 3 by Eric Swanson (INCLUDE WITH ONE LAG OR TWO LAGS)


* With both lags, MP shock on its own is negative and significant for lag 2, and the interaction term is positive and significant for lag 2 only.
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.med c.MP_S_LSAPfactor_lag2##c.med b_pred_med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.tercile c.MP_S_LSAPfactor_lag2##c.tercile b_pred_ter sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quartile c.MP_S_LSAPfactor_lag2##c.quartile b_pred_qua sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quintile c.MP_S_LSAPfactor_lag2##c.quintile b_pred_qui sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.decile c.MP_S_LSAPfactor_lag2##c.decile b_pred_dec sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_LSAPfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec MP_S_LSAPfactor_lag1 c.MP_S_LSAPfactor_lag1#c.med c.MP_S_LSAPfactor_lag1#c.tercile c.MP_S_LSAPfactor_lag1#c.quartile c.MP_S_LSAPfactor_lag1#c.quintile c.MP_S_LSAPfactor_lag1#c.decile)

* With one lag, MP shock on its own is positive and significant, and the interaction term is negative and significant.
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.med  b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.tercile  b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/emp_LSAPfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec)
