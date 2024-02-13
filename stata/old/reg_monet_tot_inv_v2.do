//Regressions measure monetary policy channels in the presence of intangibles.
// Investment on monetary policy (but the results are not significant)


//use db_reg_20220806.dta
use data/dta/db_reg_1989_only.dta
winsor2 inv_tot_perc, replace cut(1 99) trim

// Volume of debt
xtset GVKEY year

//Generate lagged variables
gen ffrate_zlb_lag1 = l1.ffrate_zlb

xtreg capx_ppe c.ffrate_zlb##med_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#terc_1989 L.sales_gr cash_at i.year if year >= 1990, fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.ffrate_zlb_lag1#dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

xtreg capx_ppe_perc c.ffrate_zlb_lag1#terc_1989 L.sales_gr cash_at i.year if year >= 1990, fe cluster(ff_indust) 
xtreg capx_ppe_perc c.ffrate_zlb_lag1#quar_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe_perc c.ffrate_zlb_lag1#quin_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe_perc c.ffrate_zlb_lag1#dec_1989 L.sales_gr cash_at i.year if year >= 1990,fe cluster(ff_indust)

// outreg2 using inv_tot_perc.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
//esttab using ex1.tex, se ar2 stats(N r2) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.ff_indust)







