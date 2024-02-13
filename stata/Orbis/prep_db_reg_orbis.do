//Preparing a database with 2y treasury to merge with Orbis.
//Convert into annual frequency.

use data/dta/db_reg_2yt.dta
keep year year_q treas_2y_q RGDP Ind_prod CPI
duplicates drop year_q, force

egen RGDP_y = sum(RGDP), by(year)
egen Ind_prod_y = mean(Ind_prod), by(year)
egen CPI_y = sum(ln(1+CPI/100)), by(year)
replace CPI_y = (exp(CPI_y)-1)*100
egen treas_2y_y = mean(ln(1+treas_2y_q/100)), by(year)
replace treas_2y_y = (exp(treas_2y_y)-1)*100

tsset year_q
collapse (max) RGDP_y Ind_prod_y CPI_y treas_2y_y, by(year)
tsset year

gen treas_2y_y_lag1 = l1.treas_2y_y
gen d_treas_2y_y = 100*(exp(ln(1+treas_2y_y/100) - ln(1+treas_2y_y_lag1/100))-1)
keep year RGDP_y Ind_prod_y CPI_y treas_2y_y d_treas_2y_y

save data/dta/db_reg_y_orbis_2yt.dta, replace

