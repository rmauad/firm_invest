//Regressions measure monetary policy channels in the presence of intangibles.
// Investment on monetary policy


//use db_reg_20220806.dta
use data/dta/db_reg_1989_only.dta
winsor2 inv_tot_perc, replace cut(1 99) trim

// Volume of debt
xtset GVKEY year

//Generate lagged variables
gen ffrate_zlb_lag1 = l1.ffrate_zlb
gen log_inv_tot_at = log(inv_tot_at)
gen log_capx_ppe = log(capx_ppe)
gen log_ltdebt_issue_at = log(ltdebt_issue_at)


xtreg log_ltdebt_issue_at d_med_1989 c.ffrate_zlb#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) // this specification works (except for median)
xtreg log_ltdebt_issue_at d_med_1989 c.ffrate_zlb#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at d_med_1989 c.ffrate_zlb#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at d_med_1989 c.ffrate_zlb#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at d_med_1989 c.ffrate_zlb#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

xtreg log_ltdebt_issue_at c.ffrate_zlb#d_med_1989 L.c.sales_gr#d_med_1989 c.cash_at#d_med_1989 i.year if year >= 1990,fe cluster(ff_indust) // this specification works (except for median)
xtreg log_ltdebt_issue_at  c.ffrate_zlb#d_terc_1989 L.c.sales_gr#d_med_1989 c.cash_at#d_med_1989 i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at  c.ffrate_zlb#d_quar_1989 L.c.sales_gr#d_med_1989 c.cash_at#d_med_1989 i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at  c.ffrate_zlb#d_quin_1989 L.c.sales_gr#d_med_1989 c.cash_at#d_med_1989 i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_ltdebt_issue_at  c.ffrate_zlb#d_dec_1989 L.c.sales_gr#d_med_1989 c.cash_at#d_med_1989 i.year if year >= 1990,fe cluster(ff_indust)

xtreg log_capx_ppe c.ffrate_zlb_lag1#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_capx_ppe c.ffrate_zlb_lag1#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_capx_ppe c.ffrate_zlb_lag1#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_capx_ppe c.ffrate_zlb_lag1#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_capx_ppe c.ffrate_zlb_lag1#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_tot_perc c.ffrate_zlb_lag1#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.ffrate_zlb_lag1#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.ffrate_zlb_lag1#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.ffrate_zlb_lag1#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.ffrate_zlb_lag1#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 

xtreg inv_tot_rev c.ffrate_zlb_lag1#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_rev c.ffrate_zlb_lag1#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_rev c.ffrate_zlb_lag1#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_rev c.ffrate_zlb_lag1#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_rev c.ffrate_zlb_lag1#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 

xtreg inv_tot_at c.ffrate_zlb_lag1#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

xtreg log_inv_tot_at c.ffrate_zlb_lag1#d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) //not significant
xtreg log_inv_tot_at c.ffrate_zlb_lag1#d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_inv_tot_at c.ffrate_zlb_lag1#d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_inv_tot_at c.ffrate_zlb_lag1#d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg log_inv_tot_at c.ffrate_zlb_lag1#d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_tot c.ffrate_zlb_lag1##d_med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot c.ffrate_zlb_lag1##d_terc_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot c.ffrate_zlb_lag1##d_quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot c.ffrate_zlb_lag1##d_quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot c.ffrate_zlb_lag1##d_dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)  

// outreg2 using inv_tot_perc.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
//esttab using ex1.tex, se ar2 stats(N r2) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.ff_indust)







