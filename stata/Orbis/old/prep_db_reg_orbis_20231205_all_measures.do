//Preparing a database with 2y treasury to merge with Orbis.
//Convert into annual frequency.

use data/dta/db_reg_q_cf_old_controls.dta
keep year year_q treas_2y_q ns_q brw_q JKff3_q MP_S_Fffactor MP_S_Fgfactor MP_S_LSAPfactor ffrate_zlb
duplicates drop year_q, force

egen treas_2y_y = mean(ln(1+treas_2y_q/100)), by(year)
replace treas_2y_y = (exp(treas_2y_y)-1)*100

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
collapse (max) treas_2y_y ns_y brw_y MP_S_Fffactor_y MP_S_Fgfactor_y MP_S_LSAPfactor_y ffrate_zlb_y JKff3_y, by(year)
tsset year

gen treas_2y_y_lag1 = l1.treas_2y_y
gen d_treas_2y_y = 100*(exp(ln(1+treas_2y_y/100) - ln(1+treas_2y_y_lag1/100))-1)
keep year treas_2y_y d_treas_2y_y

save data/dta/db_reg_y_orbis_2yt_all_measures.dta, replace

