
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_states_equity_complete.dta, clear //from pre_process_all.do

xtset bvdid_code year

******************
* Equity median
*******************

egen med_equity = median(totalshareholdersequity)
gen equity_high = totalshareholdersequity >= med_equity
keep if equity_high == 0

***************************
* Local projection graphs
***************************

******************
* Tangible firms *
******************
replace d_treas_2y_lag1 = d_treas_2y_lag1/100

local h_cur 4

eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=`h_cur'+1
gen Zero =  0    if _n<=`h_cur'+1
gen b=0
gen u=0
gen d=0
qui forv h = 1/`h_cur' {
xtreg dln_inv`h' c.d_treas_2y_lag1##ter_bot ln_assets dln_netsales_lag1 cash_at_lag1 dln_ind_prod_lag1 dln_RGDP_lag1 CPI_lag1,fe cluster(ff_indust)
replace b = _b[1.ter_bot#c.d_treas_2y_lag1]   if _n == `h'+1
replace u = _b[1.ter_bot#c.d_treas_2y_lag1] + 1.645* _se[1.ter_bot#c.d_treas_2y_lag1]  if _n == `h'+1
replace d = _b[1.ter_bot#c.d_treas_2y_lag1] - 1.645* _se[1.ter_bot#c.d_treas_2y_lag1]  if _n == `h'+1
eststo 
}

twoway (rarea u d Years, fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) (line b Years, lcolor(blue) lpattern(solid) lwidth(thick)) (line Zero Years, lcolor(black)), legend(off) title("Tangible firms", color(black) size(large)) ytitle("ln(K{subscript:t+h}/K{subscript:t})", size(medlarge)) xtitle("Year", size(medlarge)) yscale(range(-8 6)) yline(-8 -6 -4 -2 0 2 4 6, lcolor(gs13) lpattern(solid)) ylabel(-8(2)6, angle(horizontal) labsize(medlarge)) xlabel(-0(1)`h_cur', angle(horizontal) labsize(medlarge)) graphregion(color(white)) plotregion(color(white))

	// graph export "/homes/nber/mauadr/bulk/orbis.work/intan_mp/graphs/tang_orbis.png", as(png) replace
		

	
********************
* Intangible firms *
********************		
		
local h_cur 4

eststo clear
cap drop b u d Years Zero
gen Years = _n-1 if _n<=`h_cur'+1
gen Zero =  0    if _n<=`h_cur'+1
gen b=0
gen u=0
gen d=0
qui forv h = 1/`h_cur' {
xtreg dln_inv`h' c.d_treas_2y_lag1##ter_top ln_assets dln_netsales_lag1 cash_at_lag1 dln_ind_prod_lag1 dln_RGDP_lag1 CPI_lag1,fe cluster(ff_indust)
replace b = _b[1.ter_top#c.d_treas_2y_lag1]   if _n == `h'+1
replace u = _b[1.ter_top#c.d_treas_2y_lag1] + 1.645* _se[1.ter_top#c.d_treas_2y_lag1]  if _n == `h'+1
replace d = _b[1.ter_top#c.d_treas_2y_lag1] - 1.645* _se[1.ter_top#c.d_treas_2y_lag1]  if _n == `h'+1
eststo 
}
twoway (rarea u d Years, fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) (line b Years, lcolor(blue) lpattern(solid) lwidth(thick)) (line Zero Years, lcolor(black)), legend(off) title("Intangible firms", color(black) size(large)) ytitle("ln(K{subscript:t+h}/K{subscript:t})", size(medlarge)) xtitle("Year", size(medlarge)) yscale(range(-8 6)) yline(-8 -6 -4 -2 0 2 4 6, lcolor(gs13) lpattern(solid)) ylabel(-8(2)6, angle(horizontal) labsize(medlarge)) xlabel(-0(1)`h_cur', angle(horizontal) labsize(medlarge)) graphregion(color(white)) plotregion(color(white))
		
	//	graph export "/homes/nber/mauadr/bulk/orbis.work/intan_mp/graphs/intang_orbis.png", as(png) replace

	
