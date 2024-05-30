
use data/dta/db_reg_comp.dta

xtset GVKEY year_q

***************************
* Local projection graphs
***************************

******************
* Tangible firms *
******************

local h_cur 4

eststo clear
cap drop b u d Quarters Zero
gen Quarters = _n-1 if _n<=`h_cur'+1
gen Zero =  0    if _n<=`h_cur'+1
gen b=0
gen u=0
gen d=0
qui forv h = 1/`h_cur' {
xtreg dln_inv`h' c.d_treas_2y_lag1##ter_bot ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
replace b = _b[1.ter_bot#c.d_treas_2y_lag1]   if _n == `h'+1
replace u = _b[1.ter_bot#c.d_treas_2y_lag1] + 1.645* _se[1.ter_bot#c.d_treas_2y_lag1]  if _n == `h'+1
replace d = _b[1.ter_bot#c.d_treas_2y_lag1] - 1.645* _se[1.ter_bot#c.d_treas_2y_lag1]  if _n == `h'+1
eststo 
}
//nois esttab , se nocons keep(L.dstir)
local h_cur 4
twoway ///
		(rarea u d  Quarters,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line b Quarters, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Quarters, lcolor(black)), legend(off) ///
		title("Tangible firms", color(black) size(large)) ///
		ytitle("ln(K{subscript:t+h}/K{subscript:t})", size(medlarge)) xtitle("Quarter", size(medlarge)) ///
		yline(-3(1)4, lcolor(gs13) lpattern(solid)) ///
		ylabel(-3(1)4, angle(horizontal) labsize(medlarge)) ///
		xlabel(-0(2)`h_cur', angle(horizontal) labsize(medlarge)) ///
		graphregion(color(white)) plotregion(color(white))
		
		graph export "output/graphs/tang_other_states_inter.png", as(png) replace
		
		
********************
* Intangible firms *
********************		

local h_cur 4

eststo clear
cap drop b u d Quarters Zero
gen Quarters = _n-1 if _n<=`h_cur'+1
gen Zero =  0    if _n<=`h_cur'+1
gen b=0
gen u=0
gen d=0
qui forv h = 1/`h_cur' {
xtreg dln_inv`h' c.d_treas_2y_lag1##ter_top ln_assets sales_growth_lag1 cash_at_lag1 i.year if d_less_const == 0 & year>=1997 & year<=2003,fe cluster(ff_indust)
replace b = _b[1.ter_top#c.d_treas_2y_lag1]   if _n == `h'+1
replace u = _b[1.ter_top#c.d_treas_2y_lag1] + 1.645* _se[1.ter_top#c.d_treas_2y_lag1]  if _n == `h'+1
replace d = _b[1.ter_top#c.d_treas_2y_lag1] - 1.645* _se[1.ter_top#c.d_treas_2y_lag1]  if _n == `h'+1
eststo 
}
//nois esttab , se nocons keep(L.dstir)
twoway ///
		(rarea u d  Quarters,  ///
		fcolor(gs13) lcolor(gs13) lw(none) lpattern(solid)) ///
		(line b Quarters, lcolor(blue) ///
		lpattern(solid) lwidth(thick)) /// 
		(line Zero Quarters, lcolor(black)), legend(off) ///
		title("Intangible firms", color(black) size(large)) ///
		ytitle("ln(K{subscript:t+h}/K{subscript:t})", size(medlarge)) xtitle("Quarter", size(medlarge)) ///
		yline(-3(1)4, lcolor(gs13) lpattern(solid)) ///
		ylabel(-3(1)4, angle(horizontal) labsize(medlarge)) ///
		xlabel(-0(2)`h_cur', angle(horizontal) labsize(medlarge)) ///
		graphregion(color(white)) plotregion(color(white))
		
		graph export "output/graphs/intang_other_states_inter.png", as(png) replace

	
