//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and employment on several alternative monetary policy shocks.

clear
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt.dta
//use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/sales/db_reg_sales_orbis_npt.dta
//winsor2 inv_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R

encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year

gen ffrate_zlb_lag1 = l1.ffrate_zlb_y/100
gen ffrate_zlb_lag2 = l2.ffrate_zlb_y/100
gen ns_lag1 = l1.ns_y/100
gen ns_lag2 = l2.ns_y/100
gen brw_lag1 = l1.brw_y/100
gen brw_lag2 = l2.brw_y/100
gen JKff3_q_lag1 = l1.JKff3_y/100
gen JKff3_q_lag2 = l2.JKff3_y/100
gen MP_S_Fffactor_lag1 = l1.MP_S_Fffactor_y/100
gen MP_S_Fffactor_lag2 = l2.MP_S_Fffactor_y/100 
gen MP_S_Fgfactor_lag1 = l1.MP_S_Fgfactor_y/100
gen MP_S_Fgfactor_lag2 = l2.MP_S_Fgfactor_y/100 
gen MP_S_LSAPfactor_lag1 = l1.MP_S_LSAPfactor_y/100
gen MP_S_LSAPfactor_lag2 = l2.MP_S_LSAPfactor_y/100
gen netsales_lag1 =  l1.netsales/100
gen cashflow_lag1 = l1.cashflow/100
gen cpi_lag1 = l1.cpi/100
gen RGDP_lag1 = l1.RGDP_y/100
gen Ind_prod_lag1 = l1.Ind_prod_y/100

replace cashflow = cashflow/100
replace cpi = cpi/100
replace RGDP_y = ln(RGDP_y)
replace Ind_prod_y = ln(Ind_prod_y)

//Generating dln_emp
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


label variable RGDP_y "RGDP"
label variable Ind_prod_y "Ind prod"
label variable cpi "CPI"
label variable netsales_lag1 "Sales growth(-1)"
label variable cashflow "Cash flow"

//
// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta, replace

* Create dummy

gen low_ter = 0
replace low_ter = 1 if tercile == 1
gen mid_ter = 0
replace mid_ter = 1 if tercile == 2
gen top_ter = 0
replace top_ter = 1 if tercile == 3

************************************************************
*		 Employment 					   
************************************************************

xtreg dln_emp c.ffrate_zlb_lag1#c.low_ter c.ffrate_zlb_lag1#c.mid_ter c.ffrate_zlb_lag1#c.top_ter c.ffrate_zlb_lag1##c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia
xtreg dln_emp c.ns_lag1#low_ter c.ns_lag1#mid_ter c.ns_lag1#top_ter c.ns_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store ns
xtreg dln_emp c.JKff3_q_lag1#low_ter c.JKff3_q_lag1#mid_ter c.JKff3_q_lag1#top_ter c.JKff3_q_lag1##c.tercile c.JKff3_q_lag2##low_ter c.JKff3_q_lag2##mid_ter c.JKff3_q_lag2##top_ter c.JKff3_q_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store jk
xtreg dln_emp c.MP_S_Fffactor_lag1#low_ter c.MP_S_Fffactor_lag1#mid_ter c.MP_S_Fffactor_lag1#top_ter c.MP_S_Fffactor_lag1##c.tercile c.MP_S_Fffactor_lag2#low_ter c.MP_S_Fffactor_lag2#mid_ter c.MP_S_Fffactor_lag2#top_ter c.MP_S_Fffactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
xtreg dln_emp c.MP_S_Fgfactor_lag1#low_ter c.MP_S_Fgfactor_lag1#mid_ter c.MP_S_Fgfactor_lag1#top_ter c.MP_S_Fgfactor_lag1##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fgfactor
xtreg dln_emp c.MP_S_LSAPfactor_lag1#low_ter c.MP_S_LSAPfactor_lag1#mid_ter c.MP_S_LSAPfactor_lag1#top_ter c.MP_S_LSAPfactor_lag1##c.tercile c.MP_S_LSAPfactor_lag2#low_ter c.MP_S_LSAPfactor_lag2#mid_ter c.MP_S_LSAPfactor_lag2#top_ter c.MP_S_LSAPfactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor

esttab wu_xia ns jk Fffactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks_v2.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year tercile cashflow netsales_lag1 cpi RGDP_y Ind_prod_y
ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.tercile 
JKff3_q_lag1 c.JKff3_q_lag1#c.tercile 
MP_S_Fffactor_lag1 MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag2#c.tercile 
MP_S_Fgfactor_lag1 
MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.tercile)

******************************************
* With Tercile and MP shock on its own
******************************************

cap rename (ffrate_zlb_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)
cap rename (ns_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store ns
cap rename (mpshock) (ns_lag1)
cap rename (JKff3_q_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.JKff3_q_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store jk
cap rename (mpshock) (JKff3_q_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_Fgfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fgfactor
cap rename (mpshock) (MP_S_Fgfactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock##c.tercile c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2##c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_Fgfactor_lag1)

esttab wu_xia ns jk Fffactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks_v2.tex, replace b(%9.3f) label coeflabels(c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y mpshock tercile ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile JKff3_q_lag2 c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.JKff3_q_lag2#c.tercile MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.tercile MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.tercile)

***************************
* Only interaction terms
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust)
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)
cap rename (ns_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store ns
cap rename (mpshock) (ns_lag1)
cap rename (JKff3_q_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.JKff3_q_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store jk
cap rename (mpshock) (JKff3_q_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_Fgfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store Fgfactor
cap rename (mpshock) (MP_S_Fgfactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_LSAPfactor_lag1)

esttab wu_xia ns jk Fffactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks_v2.tex, replace b(%9.3f) label coeflabels(dln_emp "Emp" c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.JKff3_q_lag2#c.tercile c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.tercile)

***************************
* Only interaction terms and no "All terciles"
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust)
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)
cap rename (ns_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store ns
cap rename (mpshock) (ns_lag1)
cap rename (JKff3_q_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store jk
cap rename (mpshock) (JKff3_q_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_Fgfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store Fgfactor
cap rename (mpshock) (MP_S_Fgfactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_LSAPfactor_lag1)

esttab wu_xia ns jk Fffactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks_v2.tex, replace b(%9.3f) label coeflabels(dln_emp "Emp" c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.JKff3_q_lag2#c.low_ter c.JKff3_q_lag2#c.mid_ter c.JKff3_q_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter)



***************************
* Separating the levels of terciles
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg dln_emp c.mpshock#c.low_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_1
xtreg dln_emp c.mpshock#c.mid_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_2
xtreg dln_emp c.mpshock#c.top_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_3
cap rename (mpshock) (ffrate_zlb_lag1)

esttab wu_xia_1 wu_xia_2 wu_xia_3 using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/emp_all_shocks_sep_v2.tex, replace b(%9.3f) label coeflabels(dln_emp "Emp" c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile)
