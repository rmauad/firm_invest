// Set wd to the root folder
// This code investigates if intangible-intensive firms are more financially constrained than other firms.

use data/dta/db_reg_1989_only.dta
winsor2 debt_at, replace cut(1 99) trim
xtset GVKEY year

// ppe is a proxy for tangible investment
xtreg capx_ppe c.cre_ppe##d_med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe c.cre_ppe##d_terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe c.cre_ppe##d_quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe c.cre_ppe##d_quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg capx_ppe c.cre_ppe##d_dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

// 
xtreg inv_intan_perc c.cre_ppe##d_med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_intan_perc c.cre_ppe##d_terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_intan_perc c.cre_ppe##d_quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_intan_perc c.cre_ppe##d_quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_intan_perc c.cre_ppe##d_dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

// 
xtreg inv_tot_perc c.cre_ppe##d_med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

// 
xtreg inv_tot_perc c.cre_ppe##d_med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_perc c.cre_ppe##d_dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

// With continuous variables
xtreg inv_tot_at c.cre_ppe##c.med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_ppe##c.terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_ppe##c.quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_ppe##c.quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_ppe##c.dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)

xtreg inv_tot_at c.cre_at##c.med_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) // capx_ppe does not work
xtreg inv_tot_at c.cre_at##c.terc_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_at##c.quar_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_at##c.quin_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_at c.cre_at##c.dec_1989 c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust)  

xtreg inv_tot_ppe c.cre_ppe##c.med c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_ppe c.cre_ppe##c.tercile c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_ppe c.cre_ppe##c.quartile c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_ppe c.cre_ppe##c.quintile c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_tot_ppe c.cre_ppe##c.decile c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 


// without intangibles
xtreg capx_ppe c.cre_ppe c.mb c.cf i.year if year >= 1990,fe cluster(ff_indust) 
