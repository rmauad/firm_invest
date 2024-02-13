//Regressions measure monetary policy channels in the presence of intangibles.
// Investment on monetary policy


//use db_reg_20220806.dta
use data/dta/db_reg.dta
winsor2 inv_tot_perc, replace cut(1 99) trim

// Volume of debt
xtset GVKEY year

//Generate lagged variables
gen ffrate_zlb_lag1 = l1.ffrate_zlb
gen ffrate_zlb_lag2 = l2.ffrate_zlb
gen ffrate_zlb_lag3 = l3.ffrate_zlb

gen ir_diff_delta_lag1 = l1.ir_diff_delta
gen ir_diff_delta_lag2 = l2.ir_diff_delta
gen ir_diff_10y_2y_lag1 = l1.ir_diff_10y_2y
gen ir_diff_10y_2y_lag2 = l2.ir_diff_10y_2y

gen log_inv_tot_at = log(inv_tot_at)
gen log_capx_ppe = log(capx_ppe)
gen log_ltdebt_issue_at = log(ltdebt_issue_at)
gen log_inv_tot_at = log(inv_tot_at)
gen log_inv_tot = log(inv_tot)

gen sales_growth_lag1 = l1.sales_gr

//Labeling the variables

label variable log_ltdebt_issue_at " " //"Log(LT Debt Issuance)/assets"
label variable inv_tot_at " "
label variable debt_at " "
label variable inv_tang_at " "
label variable inv_intan_at " "
label variable ffrate_zlb_lag1 "FF rate(t-1)"
label variable ffrate_zlb_lag2 "FF rate(t-2)"
label variable mb "Market-to-book"
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
xtlogit bankruptcy med mb cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990
predict b_pred_med, pu0
xtlogit bankruptcy tercile mb cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990
predict b_pred_ter, pu0
xtlogit bankruptcy quartile mb cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990
predict b_pred_qua, pu0
xtlogit bankruptcy quintile mb cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990
predict b_pred_qui, pu0
xtlogit bankruptcy decile mb cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990
predict b_pred_dec, pu0


// LT debt issuance

xtreg log_ltdebt_issue_at c.ffrate_zlb_lag1##c.med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) // with two lags, it doesn't work. With one lag, coefficient on its own is positive, but interaction is insignificant. With ir_diff_10y_2y_lag1, it doesn't work.
xtreg log_ltdebt_issue_at c.ffrate_zlb_lag1##c.tercile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at c.ffrate_zlb_lag1##c.quartile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at c.ffrate_zlb_lag1##c.quintile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at c.ffrate_zlb_lag1##c.decile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 

// xtreg log_ltdebt_issue_at c.ir_diff_delta##c.med c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) // the interaction term is positive, but the term on its own is insignificant. Insignificant with ir_diff_10y_2y or ir_diff_10y_2y_lag1
// est store reg1
// xtreg log_ltdebt_issue_at c.ir_diff_delta##c.tercile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
// est store reg2
// xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quartile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// est store reg3
// xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quintile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// est store reg4
// xtreg log_ltdebt_issue_at c.ir_diff_delta##c.decile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
// est store reg5
// //outreg2 [reg*] using output/tex/leverage.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)

xtreg log_ltdebt_issue_at c.ir_diff_delta##c.med b_pred_med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) // the interaction term is positive, but the term on its own is insignificant. Insignificant with ir_diff_10y_2y or ir_diff_10y_2y_lag1
est store Median_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.tercile b_pred_ter c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
est store Tercile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quartile b_pred_qua c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.quintile b_pred_qui c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_lev
xtreg log_ltdebt_issue_at c.ir_diff_delta##c.decile b_pred_dec c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile_lev
//outreg2 [Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev] using output/tex/leverage.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev using output/tex/leverage.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ir_diff_delta)


xtreg debt_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) //only the interaction of lag 2 is significant
est store Median_deb
xtreg debt_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
est store Tercile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_deb
xtreg debt_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Decile_deb
//outreg2 [Median_lev Tercile_lev Quartile_lev Quintile_lev Decile_lev] using output/tex/leverage.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_deb Tercile_deb Quartile_deb Quintile_deb Decile_deb using output/tex/debt.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag1#c.med c.ffrate_zlb_lag1#c.tercile c.ffrate_zlb_lag1#c.quartile c.ffrate_zlb_lag1#c.quintile c.ffrate_zlb_lag1#c.decile)


// xtreg debt_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) //only the interaction of lag 2 is significant
// xtreg debt_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990, fe cluster(ff_indust) 
// xtreg debt_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg debt_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg debt_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 


// Investment

xtreg log_inv_tot c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med b_pred_med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg log_inv_tot c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile b_pred_ter c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg log_inv_tot c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile b_pred_qua c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg inv_tot_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile b_pred_qui c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg inv_tot_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile b_pred_dec c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)



xtreg inv_tang_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median_tang
xtreg inv_tang_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile_tang
xtreg inv_tang_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_tang
xtreg inv_tang_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_tang
xtreg inv_tang_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile_tang
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_tang Tercile_tang Quartile_tang Quintile_tang Decile_tang using output/tex/investment_tang.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


xtreg inv_intan_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year i.ff_indust if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median_intan
xtreg inv_intan_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile_intan
xtreg inv_intan_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile_intan
xtreg inv_intan_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile_intan
xtreg inv_intan_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.mb c.cf sales_growth_lag1 cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
est store Decile_intan
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median_intan Tercile_intan Quartile_intan Quintile_intan Decile_intan using output/tex/investment_intan.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


// xtreg inv_tot_at c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
// xtreg inv_tot_at c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg inv_tot_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg inv_tot_at c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg inv_tot_at c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)


// xtreg inv_tot_at c.ir_diff_delta_lag1##c.med  c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // using ir_diff_delta or ir_diff_10y_2y_lag1 gives insignificant results.
// xtreg inv_tot_at c.ir_diff_delta_lag1##c.tercile  c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // using ir_diff_delta_lag1 gives insignificant results for the interest rate term on its own, and a negative term in the interaction.
// xtreg inv_tot_at c.ir_diff_delta_lag1##c.quartile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg inv_tot_at c.ir_diff_delta_lag1##c.quintile  c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
// xtreg inv_tot_at c.ir_diff_delta_lag1##c.decile c.mb c.cf L.sales_gr cash_at CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 


// outreg2 using inv_tot_perc.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
//esttab using ex1.tex, se ar2 stats(N r2) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.ff_indust)







