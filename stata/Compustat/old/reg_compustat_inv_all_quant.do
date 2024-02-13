//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and leverage on several alternative monetary policy shocks.

use data/dta/db_reg_emp_cf_q_with_exit.dta

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

// Volume of debt
xtset GVKEY year_q

// Labeling the variables
label variable inv_tot_at " "
label variable ffrate_zlb_lag1 "FF rate(t-1)"
label variable ffrate_zlb_lag2 "FF rate(t-2)"
label variable sales_growth_lag1 "Sales growth(t-1)"
label variable d_cash_at_lag1 "Δ Cash/assets(t-1)"
label variable ip_g_lag1 "Δ Indust prod(t-1)"
label variable gdp_g_lag1 "Δ RGDP(t-1)"
label variable log_inflation_lag1 "Inflation(t-1)"
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"
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
label variable MP_S_Fgfactor_lag1 "Fgfactor shock(t-1)"
label variable MP_S_Fgfactor_lag2 "Fgfactor shock(t-2)"

// Logit regression for the firms' survival probability
* Takes time to run - so save the database after running.

// xtlogit bankruptcy med d_cash_at sales_growth_lag1 log_inflation gdp_g ip_g i.year if year >= 1990
// predict b_pred_med, pu0
// xtlogit bankruptcy tercile d_cash_at sales_growth_lag1 log_inflation gdp_g ip_g i.year if year >= 1990
// predict b_pred_ter, pu0
// xtlogit bankruptcy quartile d_cash_at sales_growth_lag1 log_inflation gdp_g ip_g i.year if year >= 1990
// predict b_pred_qua, pu0
// xtlogit bankruptcy quintile d_cash_at sales_growth_lag1 log_inflation gdp_g ip_g i.year if year >= 1990
// predict b_pred_qui, pu0
// xtlogit bankruptcy decile d_cash_at sales_growth_lag1 log_inflation gdp_g ip_g i.year if year >= 1990
// predict b_pred_dec, pu0
// save data/dta/db_reg_q_with_exit.dta, replace


************************************************************
* 						 Investment 					   *
************************************************************


* Nakamura-Steinsson (INCLUDE WITH TWO LAGS) - removed Cash Flow and divided NS shock by 100

xtreg inv_tot_at c.ns_lag1##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.ns_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.ns_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.ns_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.ns_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_ns_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


* Bu-Rogers-Wu (JME, March 2021) MP shock (DO NOT INCLUDE)


* With both lags, MP shock on its own is barely significant, and the interaction terms are negative and insignificant
xtreg inv_tot_at c.brw_lag1##c.med c.brw_lag2##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.brw_lag1##c.tercile c.brw_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.brw_lag1##c.quartile c.brw_lag2##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.brw_lag1##c.quintile c.brw_lag2##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.brw_lag1##c.decile c.brw_lag2##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_brw_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod brw_lag2 c.brw_lag2#c.med c.brw_lag2#c.tercile c.brw_lag2#c.quartile c.brw_lag2#c.quintile c.brw_lag2#c.decile)


* Jarocinski and Karadi
* Old controls
xtreg inv_tot_at c.JKff3_q_lag1##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.JKff3_q_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.JKff3_q_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.JKff3_q_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.JKff3_q_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_jkff3_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


* Measure 1 by Eric Swanson (INCLUDE WITH ONE LAG)

* With one lag, MP shock on its own is negative and significant, and the interaction term is positive and significant
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.MP_S_Fffactor_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_FFfactor_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


* Measure 2 by Eric Swanson (INCLUDE WITH ONE LAG)

* With one lag, MP shock on its own is positive and insignificant, and the interaction term is negative and insignificant
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.MP_S_Fgfactor_lag1##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_Fgfactor_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod)


* Measure 3 by Eric Swanson (DO NOT INCLUDE)


* With both lags, MP shock on its own is negative and significant for lag 2, and the interaction term is positive and significant for lag 2 only.
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.med c.MP_S_LSAPfactor_lag2##c.med b_pred_med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.tercile c.MP_S_LSAPfactor_lag2##c.tercile b_pred_ter c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.quartile c.MP_S_LSAPfactor_lag2##c.quartile b_pred_qua c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.quintile c.MP_S_LSAPfactor_lag2##c.quintile b_pred_qui c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.MP_S_LSAPfactor_lag1##c.decile c.MP_S_LSAPfactor_lag2##c.decile b_pred_dec c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/inv_LSAP_all_quant.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile b_pred_med b_pred_ter b_pred_qua b_pred_qui b_pred_dec cf sales_growth_lag1 cash_at CPI RGDP Ind_prod MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.med c.MP_S_LSAPfactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.quartile c.MP_S_LSAPfactor_lag2#c.quintile c.MP_S_LSAPfactor_lag2#c.decile)
