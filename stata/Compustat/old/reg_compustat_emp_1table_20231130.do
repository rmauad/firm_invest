//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and leverage on several alternative monetary policy shocks.

use data/dta/db_reg_q_cf_old_controls.dta
//use data/dta/db_reg_emp_cf_q_with_exit.dta
//use data/dta/db_reg_emp_cf_q_with_exit.dta
//winsor2 inv_tot_at, replace cut(1 99) trim

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
gen JKff3_q_lag1 = l1.JKff3_q/100
gen JKff3_q_lag2 = l2.JKff3_q/100
gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor // Paper by Eric Swanson
gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor 
gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor // Paper by Eric Swanson
gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor 
gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor/100 // Paper by Eric Swanson
gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor/100
gen sales_growth_lag1 = l1.sales_gr
gen d_treas_2y_lag1 = l1.d_treas_2y_q/100
gen cash_at_lag1 = l1.cash_at
gen Ind_prod_lag1 = l1.Ind_prod
gen Inflation_lag1 = l1.CPI
gen RGDP_lag1 = l1.RGDP
gen dln_RGDP_lag1 = l1.dln_RGDP
gen d_Ind_prod_lag1 = l1.d_Ind_prod

///////////////////////////////////////////////////////
// PROBABLY DELETE ALL THESE SOON
///////////////////////////////////////////////////////

// gen dln_RGDP =.
// gen d_Ind_prod =.
// gen dln_netsales =.
// gen Inflation_lag1 = CPI[_n-1]/100
// gen ln_RGDP = ln(RGDP)
// gen ln_RGDP_lag1 = ln(RGDP[_n-1])
// //gen Ind_prod_lag1 = Ind_prod[_n-1]

// sort GVKEY year_q

// // Use a forval loop to loop through each firm
// levelsof GVKEY, local(firm_list)
// foreach GVKEY of local firm_list {

//     sort GVKEY year_q

// 	by GVKEY: replace dln_RGDP = ln_RGDP - ln_RGDP_lag1 if _n > 1

// }

// gen dln_RGDP_lag1 = ln(dln_RGDP[_n-1])
// gen d_Ind_prod_lag1 = ln(d_Ind_prod[_n-1])

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


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

//NOT NEEDED (even when database comes from R. Keep in case control changes).
// gen gdp_g_lag1 = l1.gdp_g
// gen ip_g_lag1 = l1.ip_g
// gen log_inflation_lag1 = l1.log_inflation
// gen d_cash_at_lag1 = l1.d_cash_at 

// Keep in case I need to use interest rates
// gen ir_diff_delta_lag1 = l1.ir_diff_delta
// gen ir_diff_delta_lag2 = l2.ir_diff_delta
// gen ir_diff_10y_2y_lag1 = l1.ir_diff_10y_2y
// gen ir_diff_10y_2y_lag2 = l2.ir_diff_10y_2y
// gen log_inv_tot_at = log(inv_tot_at)
// gen log_capx_ppe = log(capx_ppe)
// gen log_ltdebt_issue_at = log(ltdebt_issue_at)
// gen log_inv_tot = log(inv_tot)


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
//save data/dta/db_reg_emp_cf_q_with_exit_old_controls.dta, replace

gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

***************
* One line
***************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.tercile sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store Treas_2y
cap rename (mpshock) (d_treas_2y_lag1)

esttab Treas_2y using output/tex/emp_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile sales_growth_lag1 cash_at CPI RGDP Ind_prod)


***************
* All terc
***************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store low
xtreg inv_tot_at c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store mid
xtreg inv_tot_at c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store high
cap rename (mpshock) (d_treas_2y_lag1)

cap rename (JKff3_q_lag1) (mpshock)
xtreg inv_tot_at c.mpshock##c.ter_low sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store low
xtreg inv_tot_at c.mpshock##c.ter_mid sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store mid
xtreg inv_tot_at c.mpshock##c.ter_high sales_growth_lag1 cash_at_lag1 Inflation_lag1 dln_RGDP_lag1 d_Ind_prod_lag1 i.year if year >= 1990,fe cluster(ff_indust) 
est store high
cap rename (mpshock) (JKff3_q_lag1)

esttab Treas_2y using output/tex/emp_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year ter_low ter_mid ter_high sales_growth_lag1 cash_at CPI RGDP Ind_prod)


***************
* All quant
***************

cap rename (d_treas_2y_lag1) (mpshock)
xtreg dln_emp c.mpshock##c.med sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store med
xtreg dln_emp c.mpshock##c.tercile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store ter
xtreg dln_emp c.mpshock##c.quartile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store qua
xtreg dln_emp c.mpshock##c.quintile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store qui
xtreg dln_emp c.mpshock##c.decile sales_growth_lag1 cash_at CPI RGDP Ind_prod i.year if year >= 1990,fe cluster(ff_indust) 
est store dec
cap rename (mpshock) (d_treas_2y_lag1)

esttab med ter qua qui dec using output/tex/emp_all_shocks_tercile.tex, coeflabels(mpshock "MPshock(t-1)" c.mpshock#c.tercile "MPshock(t-1) x Tercile") b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile sales_growth_lag1 cash_at CPI RGDP Ind_prod)
