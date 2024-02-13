//Regressions measure monetary policy channels in the presence of intangibles.
// Investment on monetary policy

//use db_reg_20220806.dta
use data/dta/db_reg_q.dta
winsor2 inv_tot_at, replace cut(1 99) trim

// Volume of debt
xtset GVKEY year_q

//Generate lagged variables
gen ffrate_zlb_lag1 = l1.ffrate_zlb
gen ffrate_zlb_lag2 = l2.ffrate_zlb
gen ffrate_zlb_lag3 = l3.ffrate_zlb
gen ns_lag1 = l1.ns_q
gen ns_lag2 = l2.ns_q

gen ir_diff_delta_lag1 = l1.ir_diff_delta
gen ir_diff_delta_lag2 = l2.ir_diff_delta
gen ir_diff_10y_2y_lag1 = l1.ir_diff_10y_2y
gen ir_diff_10y_2y_lag2 = l2.ir_diff_10y_2y

gen log_inv_tot_at = log(inv_tot_at)
//gen log_capx_ppe = log(capx_ppe)
gen log_ltdebt_issue_at = log(ltdebt_issue_at)
//gen log_inv_tot = log(inv_tot)
gen sales_growth_lag1 = l1.sales_gr

//Labeling the variables
label variable log_ltdebt_issue_at " " //"Log(LT Debt Issuance)/assets"
label variable inv_tot_at " "
label variable debt_at " "
//label variable inv_tang_at " "
//label variable inv_intan_at " "
label variable ffrate_zlb_lag1 "FF rate(t-1)"
label variable ffrate_zlb_lag2 "FF rate(t-2)"
//label variable mb "Market-to-book"
label variable cf "Cash flow"
label variable sales_growth_lag1 "Sales growth(t-1)"
label variable cash_at "Cash/assets"
label variable Ind_prod "Ind production"
label variable ir_diff_delta "LT interest rate change (10y-2y)"
label variable med "Median"
label variable tercile "Tercile"
label variable quartile "Quartile"
label variable quintile "Quintile"
label variable decile "Decile"

// Logit regression for the firms' survival probability
xtlogit bankruptcy med cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990
predict b_pred_med, pu0
xtlogit bankruptcy tercile cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990
predict b_pred_ter, pu0
xtlogit bankruptcy quartile  cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990
predict b_pred_qua, pu0
xtlogit bankruptcy quintile  cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990
predict b_pred_qui, pu0
xtlogit bankruptcy decile  cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990
predict b_pred_dec, pu0


// LT debt issuance

xtreg log_ltdebt_issue_at c.ir_diff_delta##c.med  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) // the interaction term is positive, but the term on its own is insignificant. Insignificant with ir_diff_10y_2y or ir_diff_10y_2y_lag1
est store Median_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.tercile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
est store Tercile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quartile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quintile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.decile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile_lev
//outreg2 [Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev] using output/tex/leverage.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev using output/tex/leverage.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ir_diff_delta)


xtreg debt_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) //only the interaction of lag 2 is significant
est store Median_deb
xtreg debt_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
est store Tercile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile  c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Decile_deb
//outreg2 [Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev] using output/tex/leverage.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_deb Tercile_deb Quartile_deb Quintile_deb Decile_deb using output/tex/debt.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag1#c.med c.ffrate_zlb_lag1#c.tercile c.ffrate_zlb_lag1#c.quartile c.ffrate_zlb_lag1#c.quintile c.ffrate_zlb_lag1#c.decile)

// Investment

xtreg inv_tot_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg inv_tot_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


// Investment

xtreg inv_tot_at c.ns_lag1##c.med c.ns_lag2##c.med c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg inv_tot_at c.ns_lag1##c.tercile c.ns_lag2##c.tercile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg inv_tot_at c.ns_lag1##c.quartile c.ns_lag2##c.quartile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.ns_lag1##c.quintile c.ns_lag2##c.quintile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.ns_lag1##c.decile c.ns_lag2##c.decile c.cf sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)







