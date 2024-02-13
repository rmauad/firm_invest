//Preparing a database with MP shocks and macro variables to merge with Orbis.
//Convert into annual frequency.

// use data/dta/db_reg_q_with_exit.dta
// keep year year_q CPI RGDP Ind_prod ns_q brw_q JKff3_q MP_S_Fffactor MP_S_Fgfactor MP_S_LSAPfactor ffrate_zlb ir_diff_10y_2y
// drop CPI
// duplicates drop year_q, force
// save data/dta/db_reg_q_orbis.dta, replace

// import excel data/excel/CPI.xls, first case(lower)
// rename date year
// save data/dta/CPI.dta, replace

use data/dta/db_reg_q_orbis.dta

egen RGDP_y = sum(RGDP), by(year)
egen Ind_prod_y = mean(Ind_prod), by(year)
egen ir_diff_10y_2y_y = max(ir_diff_10y_2y), by(year)

egen ns_y = mean(ln(1+ns_q/100)), by(year)
replace ns_y = (exp(ns_y)-1)*100

egen brw_y = mean(ln(1+brw_q/100)), by(year)
replace brw_y = (exp(brw_y)-1)*100

egen MP_S_Fffactor_y = mean(ln(1+MP_S_Fffactor/100)), by(year)
replace MP_S_Fffactor_y = (exp(MP_S_Fffactor_y)-1)*100

egen MP_S_Fgfactor_y = mean(ln(1+MP_S_Fgfactor/100)), by(year)
replace MP_S_Fgfactor_y = (exp(MP_S_Fgfactor_y)-1)*100

egen MP_S_LSAPfactor_y = mean(ln(1+MP_S_LSAPfactor/100)), by(year)
replace MP_S_LSAPfactor_y = (exp(MP_S_LSAPfactor_y)-1)*100

egen ffrate_zlb_y = mean(ln(1+ffrate_zlb/100)), by(year)
replace ffrate_zlb_y = (exp(ffrate_zlb_y)-1)*100

egen JKff3_y = mean(ln(1+JKff3_q/100)), by(year)
replace JKff3_y = (exp(JKff3_y)-1)*100

tsset year_q
collapse (max) RGDP_y Ind_prod_y ir_diff_10y_2y_y ns_y brw_y MP_S_Fffactor_y MP_S_Fgfactor_y MP_S_LSAPfactor_y ffrate_zlb_y JKff3_y, by(year)
merge 1:1 year using data/dta/CPI.dta, keep(3) nogen //only keep matched observations

save data/dta/db_reg_y_orbis.dta, replace

