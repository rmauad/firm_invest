// Set wd to the root folder
// This code investigates if intangible-intensive firms are more financially constrained than other firms.

use data/dta/db_reg_1989_only.dta
winsor2 debt_at, replace cut(1 99) trim
xtset GVKEY year

// With interest expense
xtreg inv_tot_at c.inter_debt##c.med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work
xtreg inv_tot_at c.inter_debt##c.terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.inter_debt##c.quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.inter_debt##c.quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.inter_debt##c.dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_tang_at c.inter_debt##c.med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work
xtreg inv_tang_at c.inter_debt##c.terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tang_at c.inter_debt##c.quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tang_at c.inter_debt##c.quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tang_at c.inter_debt##c.dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)    

xtreg inv_tot_perc c.inter_debt_perc##c.med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work
xtreg inv_tot_perc c.inter_debt_perc##c.terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.inter_debt_perc##c.quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.inter_debt_perc##c.quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.inter_debt_perc##c.dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

mixed inv_tang_at cre_at || ff_indust: cre_at

binscatter inter_debt intan_at if year >= 1990
binscatter intan_at intan_cre_at if year >= 1990
binscatter intan_at cre_at if year >= 1990
binscatter tang_at cre_at if year >= 1990

