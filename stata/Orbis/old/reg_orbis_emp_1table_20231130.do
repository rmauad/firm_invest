//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and employment on several alternative monetary policy shocks.

clear
//use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt.dta //use this if taking the database from R
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_intan_at.dta
//use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_intan_at_all_measures.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_at_all_measures.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_intan_cap_all_measures.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta


//use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete.dta
//use this if using the database after running the commands in Stata.
//winsor2 inv_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

gen cash_at = cashcashequivalent/totalassets
gen cash_at_lag1 = l1.cash_at
gen netsales_lag1 = l1.netsales


gen d_treas_2y_lag1 = l1.d_treas_2y
gen d_treas_2y_lag2 = l2.d_treas_2y
gen ffrate_zlb_lag1 = l1.ffrate_zlb_y
gen ffrate_zlb_lag2 = l2.ffrate_zlb_y
gen ns_lag1 = l1.ns_y
gen ns_lag2 = l2.ns_y
gen brw_lag1 = l1.brw_y
gen brw_lag2 = l2.brw_y
gen JKff3_q_lag1 = l1.JKff3_y
gen JKff3_q_lag2 = l2.JKff3_y
gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor_y
gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor_y 
gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor_y
gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor_y 
gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor_y
gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor_y

// Generate dln_emp
// Sort the dataset by firm and year to ensure the data is in the correct order
gen dln_emp = .
gen ln_emp = ln(numberofemployees)
gen ln_emp_lag1 = ln(numberofemployees[_n- 1])

sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {

    sort bvdidnumber year

	by bvdidnumber: replace dln_emp = ln_emp - ln_emp_lag1 if _n > 1
}


gen dln_netsales = .
gen ln_netsales = ln(netsales)
gen ln_netsales_lag1 = ln(netsales[_n- 1])

sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {

    sort bvdidnumber year

	by bvdidnumber: replace dln_netsales = ln_netsales - ln_netsales_lag1 if _n > 1
}

gen dln_netsales_lag1 = dln_netsales[_n-1]

label variable netsales_lag1 "Sales growth(-1)"
label variable cash_at_lag1 "Cash/assets(-1)"
//
//save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete.dta, replace
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_complete_intan_cap_all_measures.dta, replace


gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

gen qua_low = 0
replace qua_low = 1 if quartile == 1
gen qua_mid1 = 0
replace qua_mid1 = 1 if quartile == 2
gen qua_mid2 = 0
replace qua_mid2 = 1 if quartile == 3
gen qua_high = 0
replace qua_high = 1 if quartile == 4

************************************************************
*		 Employment 					   
************************************************************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.tercile netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Treas_2y
cap rename (mpshock) (d_treas_2y_lag1)
cap rename (ffrate_zlb_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.tercile c.ffrate_zlb_lag2#c.tercile netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)

xtreg dln_emp c.JKff3_q_lag1#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.JKff3_q_lag1#c.ter_high dln_netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 


xtreg dln_emp c.JKff3_q_lag1#c.quartile c.JKff3_q_lag2#c.tercile netsales_lag1 cash_at_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
xtreg dln_emp c.ns_lag1#c.tercile cash_at_lag1 netsales_lag1 i.year if year >= 1990,fe cluster(ff_indust) 




xtreg dln_emp c.ffrate_zlb_lag1#c.tercile c.ffrate_zlb_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.


esttab Treas_2y using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_2yt_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile sales_growth_lag1 cash_at_lag1)
