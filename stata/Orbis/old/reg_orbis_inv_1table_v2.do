//Regressions measure monetary policy channels in the presence of intangibles.
// Investment and employment on several alternative monetary policy shocks.

clear
// use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt.dta
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta
//winsor2 inv_at, replace cut(1 99) trim

// ONLY RERUN THE LINES BELOW IF USING DATABASE GENERATED IN R


//encode bvdidnumber, generate(bvdid_factor)
xtset bvdid_factor year


replace cashflow = cashflow/100
replace cpi = cpi/100
replace RGDP_y = ln(RGDP_y)
replace Ind_prod_y = ln(Ind_prod_y)

label variable ffrate_zlb_lag1 "MPshock(t-1)"
label variable ffrate_zlb_lag2 "MPschock(t-2)"
label variable inv_at " "
label variable RGDP_y "RGDP"
label variable Ind_prod_y "Ind prod"
label variable cpi "CPI"
label variable netsales_lag1 "Sales growth(-1)"
label variable cashflow "Cash flow"

// save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_complete.dta, replace
gen low_ter = 0
replace low_ter = 1 if tercile == 1
gen mid_ter = 0
replace mid_ter = 1 if tercile == 2
gen top_ter = 0
replace top_ter = 1 if tercile == 3

************************************************************
*		 Investment					   
************************************************************

* Wu and Shia ffrate_zlb (INCLUDE WITH TWO LAGS)

// c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y

xtreg inv_at c.ffrate_zlb_lag1##c.quartile c.ffrate_zlb_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) //capx_ppe does not work. With one lag, the interaction term is still positive, but I lose significance of the term on its own.
est store wu_xia
xtreg inv_at c.MP_S_Fffactor_lag1##c.quartile c.MP_S_Fffactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store FFfactor
xtreg inv_at c.MP_S_LSAPfactor_lag1##c.quartile c.MP_S_LSAPfactor_lag2##c.quartile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor

esttab wu_xia ns jk FFfactor Fgfactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/inv_all_shocks.tex, b(%9.3f) label replace se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year med tercile quartile quintile decile ffrate_zlb_lag1 ffrate_zlb_lag2 c.ffrate_zlb_lag2#c.med c.ffrate_zlb_lag2#c.tercile c.ffrate_zlb_lag2#c.quartile c.ffrate_zlb_lag2#c.quintile c.ffrate_zlb_lag2#c.decile 
MP_S_Fffactor_lag1 MP_S_Fffactor_lag2 c.MP_S_Fffactor_lag1#c.med c.MP_S_Fffactor_lag1#c.tercile c.MP_S_Fffactor_lag1#c.quartile c.MP_S_Fffactor_lag1#c.quintile c.MP_S_Fffactor_lag1#c.decile
MP_S_LSAPfactor_lag1 MP_S_LSAPfactor_lag2 c.MP_S_LSAPfactor_lag2#c.med c.MP_S_LSAPfactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.quartile c.MP_S_LSAPfactor_lag2#c.quintile c.MP_S_LSAPfactor_lag2#c.decile)


***************************
* Only interaction terms
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.mpshock#c.tercile c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_LSAPfactor_lag1)

esttab wu_xia Fffactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/inv_all_shocks_v2.tex, replace b(%9.3f) label coeflabels(c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.tercile c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.tercile)



***************************
* Only interaction terms and no "All terciles"
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust)
est store wu_xia
cap rename (mpshock) (ffrate_zlb_lag1)
cap rename (MP_S_Fffactor_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store Fffactor
cap rename (mpshock) (MP_S_Fffactor_lag1)
cap rename (MP_S_LSAPfactor_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.mid_ter c.mpshock#c.top_ter c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990, cluster(ff_indust) 
est store LSAPfactor
cap rename (mpshock) (MP_S_LSAPfactor_lag1)

esttab wu_xia Fffactor LSAPfactor using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/inv_all_shocks_v2.tex, replace b(%9.3f) label coeflabels(c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.MP_S_Fffactor_lag2#c.low_ter c.MP_S_Fffactor_lag2#c.mid_ter c.MP_S_Fffactor_lag2#c.top_ter c.MP_S_LSAPfactor_lag2#c.low_ter c.MP_S_LSAPfactor_lag2#c.mid_ter c.MP_S_LSAPfactor_lag2#c.top_ter)



***************************
* Separating the levels of terciles
***************************


cap rename (ffrate_zlb_lag1) (mpshock)
xtreg inv_at c.mpshock#c.low_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_1
xtreg inv_at c.mpshock#c.mid_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_2
xtreg inv_at c.mpshock#c.top_ter c.mpshock#c.tercile c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile c.cashflow netsales_lag1 cpi RGDP_y Ind_prod_y i.year if year >= 1990,fe cluster(ff_indust)
est store wu_xia_3
cap rename (mpshock) (ffrate_zlb_lag1)



esttab wu_xia_1 wu_xia_2 wu_xia_3 using /homes/nber/mauadr/bulk/orbis.work/intan_mp/output/inv_all_shocks_sep_v2.tex, replace b(%9.3f) label coeflabels(c.mpshock#c.tercile "MPshock(t-1) x All terciles" c.mpshock#c.low_ter "MPshock(t-1) x Low Tercile" c.mpshock#c.mid_ter "MPshock(t-1) x Mid Tercile" c.mpshock#c.top_ter "MPshock(t-1) x Top Tercile") se ar2 stats(N r2, fmt(0 %9.3f)) star(* 0.10 ** 0.05 *** 0.01) drop(*.year cashflow netsales_lag1 cpi RGDP_y Ind_prod_y c.ffrate_zlb_lag2#c.low_ter c.ffrate_zlb_lag2#c.mid_ter c.ffrate_zlb_lag2#c.top_ter c.ffrate_zlb_lag2#c.tercile)
