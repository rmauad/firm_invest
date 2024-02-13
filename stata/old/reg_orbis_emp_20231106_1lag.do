//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and employment on several alternative monetary policy shocks.

clear
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta
//winsor2 inv_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R


//encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

// //Generate lagged variables
// gen ffrate_zlb_lag1 = l1.ffrate_zlb_y/100
// gen ffrate_zlb_lag2 = l2.ffrate_zlb_y/100
// gen ns_lag1 = l1.ns_y/100 // Nakamura-Steinsson (QJE, 2018) MP shock
// gen ns_lag2 = l2.ns_y/100
// gen brw_lag1 = l1.brw_y/100 //Bu-Rogers-Wu (JME, March 2021) MP shock
// gen brw_lag2 = l2.brw_y/100
// gen JKff3_q_lag1 = l1.JKff3_y/100 //Paper by John Rogers
// gen JKff3_q_lag2 = l2.JKff3_y/100
// gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor_y/100 // Paper by Eric Swanson
// gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor_y/100 
// gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor_y/100 // Paper by Eric Swanson
// gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor_y/100 
// gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor_y/100 // Paper by Eric Swanson
// gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor_y/100
// gen netsales_lag1 =  l1.netsales/100
// gen cashflow_lag1 = l1.cashflow/100
// gen cpi_lag1 = l1.cpi/100
// gen RGDP_lag1 = l1.RGDP_y/100
// gen Ind_prod_lag1 = l1.Ind_prod_y/100
// replace cashflow = cashflow/100
// replace cpi = cpi/100
// replace RGDP_y = ln(RGDP_y)
// replace Ind_prod_y = ln(Ind_prod_y)

//
// // Generate dln_emp
// // Sort the dataset by firm and year to ensure the data is in the correct order
// gen dln_emp = .
// gen ln_emp = ln(numberofemployees)
// gen ln_emp_lag1 = ln(numberofemployees[_n- 1])
//
// sort bvdidnumber year
//
// // Use a forval loop to loop through each firm
// levelsof bvdidnumber, local(firm_list)
// foreach bvdidnumber of local firm_list {
//     // Sort the data by firm and year again (just to be safe)
//     sort bvdidnumber year
//
//     // Generate a new variable that stores the lagged expenses for each firm
// 	by bvdidnumber: replace dln_emp = ln_emp - ln_emp_lag1 if _n > 1
// }
//
//
// // //Labeling the variables
//
// label variable ffrate_zlb_lag1 "FF rate(t-1)"
// label variable ffrate_zlb_lag2 "FF rate(t-2)"
// label variable Ind_prod_y "Ind production"
// label variable med "Median"
// label variable tercile "Tercile"
// label variable quartile "Quartile"
// label variable quintile "Quintile"
// label variable decile "Decile"
// label variable dln_emp " "
// label variable ns_lag1 "NS shock(t-1)"
// label variable ns_lag2 "NS shock(t-2)"
// label variable brw_lag1 "BRW shock(t-1)"
// label variable brw_lag2 "BRW shock(t-2)"
// label variable JKff3_q_lag1 "JKff3 shock(t-1)"
// label variable JKff3_q_lag2 "JKff3 shock(t-2)"
// label variable MP_S_Fffactor_lag1 "FFfactor shock(t-1)"
// label variable MP_S_Fffactor_lag2 "FFfactor shock(t-2)"
// label variable MP_S_LSAPfactor_lag1 "LSAPFactor shock(t-1)"
// label variable MP_S_LSAPfactor_lag2 "LSAPFactor shock(t-2)"
// label variable MP_S_Fgfactor_lag1 "Fgfactor shock(t-1)"
// label variable MP_S_Fgfactor_lag2 "Fgfactor shock(t-2)"
label variable RGDP_y "RGDP"
label variable Ind_prod_y "Ind prod"
label variable cpi "CPI"
label variable netsales_lag1 "Sales growth(-1)"
label variable cashflow "Cash flow"
// label variable cashflow_lag1 "Cashflow(-1)"
// label variable cpi_lag1 "CPI(-1)"
// label variable RGDP_lag1 "RGDP(-1)"
// label variable Ind_prod_lag1 "Ind prod(-1)"
//
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta, replace

************************************************************
*		 Employment 					   
************************************************************

* Wu and Shia ffrate_zlb (INCLUDE WITH TWO LAGS)

// c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y
xtreg dln_emp c.ffrate_zlb_lag1##c.med c.ffrate_zlb_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Tercile
xtreg dln_emp c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Quartile
xtreg dln_emp c.ffrate_zlb_lag1##c.quintile c.ffrate_zlb_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Quintile
xtreg dln_emp c.ffrate_zlb_lag1##c.decile c.ffrate_zlb_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_wu_xia.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile)


* Nakamura-Steinsson (INCLUDE WITH ONE LAG)

xtreg dln_emp c.ns_lag1##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Median
xtreg dln_emp c.ns_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Tercile
xtreg dln_emp c.ns_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Quartile
xtreg dln_emp c.ns_lag1##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Quintile
xtreg dln_emp c.ns_lag1##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_ns.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile ns_lag1)


* Bu-Rogers-Wu (JME, March 2021) MP shock

xtreg dln_emp c.brw_lag1##c.med c.brw_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.brw_lag1##c.tercile c.brw_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.brw_lag1##c.quartile c.brw_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.brw_lag1##c.quintile c.brw_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.brw_lag1##c.decile c.brw_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_brw.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile brw_lag2 c.brw_lag2##c.med c.brw_lag2##c.tercile c.brw_lag2##c.quartile c.brw_lag2##c.quintile c.brw_lag2##c.decile)

* With one lag, MP shock on its own is positive, and the interaction term is negative and barely significant
xtreg dln_emp c.brw_lag1##c.med  c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.brw_lag1##c.tercile  c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.brw_lag1##c.quartile  c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.brw_lag1##c.quintile  c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.brw_lag1##c.decile  c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
//outreg2 [Median Tercile Quartile Quintile Decile] using output/tex/investment.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_brw.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile brw_lag2 c.brw_lag2##c.med c.brw_lag2##c.tercile c.brw_lag2##c.quartile c.brw_lag2##c.quintile c.brw_lag2##c.decile)


* Paper by John Rogers (INCLUDE WITH TWO LAGs)


* With both lags, MP shock on its own is negative and significant, and the interaction terms are positive and boderline significant
xtreg dln_emp c.JKff3_q_lag1##c.med c.JKff3_q_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.JKff3_q_lag1##c.tercile c.JKff3_q_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.JKff3_q_lag1##c.quartile c.JKff3_q_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.JKff3_q_lag1##c.quintile c.JKff3_q_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.JKff3_q_lag1##c.decile c.JKff3_q_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_JKff3.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile JKff3_q_lag1 JKff3_q_lag2 c.JKff3_q_lag2#c.med c.JKff3_q_lag2#c.tercile c.JKff3_q_lag2#c.quartile c.JKff3_q_lag2#c.quintile c.JKff3_q_lag2#c.decile)


* Measure 1 by Eric Swanson


xtreg dln_emp c.MP_S_Fffactor_lag1##c.med c.MP_S_Fffactor_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fffactor_lag1##c.tercile c.MP_S_Fffactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quartile c.MP_S_Fffactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quintile c.MP_S_Fffactor_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.decile c.MP_S_Fffactor_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_Fffactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile MP_S_Fffactor_lag1 MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag2#c.med c.MP_S_Fffactor_lag2#c.tercile c.MP_S_Fffactor_lag2#c.quartile c.MP_S_Fffactor_lag2#c.quintile c.MP_S_Fffactor_lag2#c.decile)

xtreg dln_emp c.MP_S_Fffactor_lag1##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fffactor_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fffactor_lag1##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_Fffactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag2##c.med c.MP_S_Fffactor_lag2##c.tercile c.MP_S_Fffactor_lag2##c.quartile c.MP_S_Fffactor_lag2##c.quintile c.MP_S_Fffactor_lag2##c.decile)


* Measure 2 by Eric Swanson

xtreg dln_emp c.MP_S_Fgfactor_lag1##c.med c.MP_S_Fgfactor_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.tercile c.MP_S_Fgfactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quartile c.MP_S_Fgfactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quintile c.MP_S_Fgfactor_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.decile c.MP_S_Fgfactor_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_Fgfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.year med tercile quartile quintile decile MP_S_Fgfactor_lag2 c.MP_S_Fgfactor_lag2#c.med c.MP_S_Fgfactor_lag2#c.tercile c.MP_S_Fgfactor_lag2#c.quartile c.MP_S_Fgfactor_lag2#c.quintile c.MP_S_Fgfactor_lag2#c.decile)


xtreg dln_emp c.MP_S_Fgfactor_lag1##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_Fgfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile MP_S_Fgfactor_lag1)


* Measure 3 by Eric Swanson

xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.med c.MP_S_LSAPfactor_lag2##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.tercile c.MP_S_LSAPfactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quartile c.MP_S_LSAPfactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quintile c.MP_S_LSAPfactor_lag2##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.decile c.MP_S_LSAPfactor_lag2##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_LSAPfactor.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.med c.MP_S_LSAPfactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.quartile c.MP_S_LSAPfactor_lag2#c.quintile c.MP_S_LSAPfactor_lag2#c.decile)

xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.med c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Median
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Tercile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quartile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quintile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Quintile
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.decile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store Decile
esttab Median Tercile Quartile Quintile Decile using output/tex/investment.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2##c.med c.MP_S_LSAPfactor_lag2##c.tercile c.MP_S_LSAPfactor_lag2##c.quartile c.MP_S_LSAPfactor_lag2##c.quintile c.MP_S_LSAPfactor_lag2##c.decile)
