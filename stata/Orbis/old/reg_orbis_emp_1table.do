//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and employment on several alternative monetary policy shocks.

clear
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt.dta
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt.dta
//winsor2 inv_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

//encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

replace cashflow = cashflow/100
replace cpi = cpi/100
replace RGDP_y = ln(RGDP_y)
replace Ind_prod_y = ln(Ind_prod_y)

label variable RGDP_y "RGDP"
label variable Ind_prod_y "Ind prod"
label variable cpi "CPI"
label variable netsales_lag1 "Sales growth(-1)"
label variable cashflow "Cash flow"
//
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta, replace

************************************************************
*		 Employment 					   
************************************************************

xtreg dln_emp c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store wu_xia
xtreg dln_emp c.ns_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store ns
xtreg dln_emp c.JKff3_q_lag1##c.quartile c.JKff3_q_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store jk
xtreg dln_emp c.MP_S_Fffactor_lag1##c.quartile c.MP_S_Fffactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
xtreg dln_emp c.MP_S_Fgfactor_lag1##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fgfactor
xtreg dln_emp c.MP_S_LSAPfactor_lag1##c.quartile c.MP_S_LSAPfactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor

esttab wu_xia ns jk Fffactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile
ns_lag1
JKff3_q_lag1 c.JKff3_q_lag1#c.med c.JKff3_q_lag1#c.tercile c.JKff3_q_lag1#c.quartile c.JKff3_q_lag1#c.quintile c.JKff3_q_lag1#c.decile
MP_S_Fffactor_lag1 MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag1#c.med c.MP_S_Fffactor_lag1#c.tercile c.MP_S_Fffactor_lag1#c.quartile c.MP_S_Fffactor_lag1#c.quintile c.MP_S_Fffactor_lag1#c.decile
MP_S_Fgfactor_lag1
MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.med c.MP_S_LSAPfactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.quartile c.MP_S_LSAPfactor_lag2#c.quintile c.MP_S_LSAPfactor_lag2#c.decile)
