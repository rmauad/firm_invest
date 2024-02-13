// Set wd to the root folder
// This code investigates if intangible-intensive firms are more financially constrained than other firms.

use data/dta/db_reg.dta
winsor2 debt_at, replace cut(1 99) trim
xtset GVKEY year

gen inter_debt_lag1 = l1.inter_debt
gen inter_debt_lag2 = l2.inter_debt


gen log_inv_tot_at = log(inv_tot_at)
gen log_capx_ppe = log(capx_ppe)
gen log_ltdebt_issue_at = log(ltdebt_issue_at)

gen ffrate_zlb_lag1 = l1.ffrate_zlb
gen ffrate_zlb_lag2 = l2.ffrate_zlb
gen ffrate_zlb_lag3 = l3.ffrate_zlb

//Do ffrate affect firm level interest rates?
xtreg inter_debt c.ffrate c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inter_debt c.ffrate##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inter_debt c.ffrate##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inter_debt c.ffrate##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inter_debt c.ffrate##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

// With interest expense
xtreg inv_tot_at c.inter_debt##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work, and using lag of interest rates inverts the results
xtreg inv_tot_at c.inter_debt##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_at c.inter_debt##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_at c.inter_debt##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_at c.inter_debt##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_tang_at c.inter_debt##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work, and using lag of interest rates inverts the results
xtreg inv_tang_at c.inter_debt##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tang_at c.inter_debt##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tang_at c.inter_debt##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tang_at c.inter_debt##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_intan_at c.inter_debt##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work, and using lag of interest rates inverts the results
xtreg inv_intan_at c.inter_debt##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_intan_at c.inter_debt##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_intan_at c.inter_debt##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_intan_at c.inter_debt##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
 
xtreg inv_tot_perc c.inter_debt##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work, and using lag of interest rates inverts the results
xtreg inv_tot_perc c.inter_debt##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_perc c.inter_debt##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_perc c.inter_debt##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_tot_perc c.inter_debt##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

// With debt issuance
xtreg ltdebt_issue_at c.inter_debt##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //ltdebt_issue_at does not work with contemporaneous interest rates
xtreg ltdebt_issue_at c.inter_debt##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

xtreg ltdebt_issue_at c.inter_debt_lag1##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) //ltdebt_issue_at works with the lag of interest rates
xtreg ltdebt_issue_at c.inter_debt_lag1##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt_lag1##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt_lag1##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg ltdebt_issue_at c.inter_debt_lag1##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)

//second lag of interest rates does not work well

xtreg debt_at c.inter_debt_lag1##c.med c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) // debt_at works
xtreg debt_at c.inter_debt_lag1##c.tercile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg debt_at c.inter_debt_lag1##c.quartile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg debt_at c.inter_debt_lag1##c.quintile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)
xtreg debt_at c.inter_debt_lag1##c.decile c.mb c.cf CPI GDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust)


binscatter inter_debt intan_at if year >= 1990
binscatter intan_at intan_cre_at if year >= 1990
binscatter intan_at cre_at if year >= 1990
binscatter tang_at cre_at if year >= 1990

