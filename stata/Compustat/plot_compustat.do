// Plots of intangible/capital, investment/assets and employment change over time.

use data/dta/db_reg_q_cf_old_controls.dta
//bysort year: egen avr_intan_at = mean(intan_at)
gen intan_ppe = org_cap_comp/ppentq
gen intan_cap = org_cap_comp/(org_cap_comp + ppentq)

label variable intan_cap " "


forval y = 1990/2019 {
    if mod(`y', 3) {
        label def yearz `y' `"{c 0xa0}"', add 
    }
}

	   label value year yearz


	   graph box intan_cap, title("Intangible/tangible") ylabel(0[0.5]2) yscale(range(0 2)) nooutside over(year)
//graph export /homes/nber/mauadr/bulk/orbis.work/intan_mp/graphs/intan_at.eps

	  
// Plot intan_at vs equity/at

gen eq_tot = ceqq/(org_cap_comp + ppentq)
winsor2 intan_at, replace cut(0 95) trim
	   binscatter eq_tot intan_tot, nquantiles(40)

	   
********************
* Intangible/capital
********************

collapse (sum) org_cap_comp inv_tot ppentq atq, by(year)

gen intan_tan = org_cap_comp/ppentq

line intan_tan year

gen ter_low = 0
replace ter_low = 1 if tercile == 1
gen ter_mid = 0
replace ter_mid = 1 if tercile == 2
gen ter_high = 0
replace ter_high = 1 if tercile == 3

replace rate_ter_low = ter_low*d_treas_2y_q
replace inv_ter_low = ter_low*inv_tot_at
replace rate_ter_mid = ter_mid*d_treas_2y_q
replace inv_ter_mid = ter_mid*inv_tot_at
replace rate_ter_high = ter_high*d_treas_2y_q
replace inv_ter_high = ter_high*inv_tot_at

binscatter rate_ter_low inv_ter_low, nquantiles(40)
binscatter rate_ter_mid inv_ter_mid, nquantiles(40)
binscatter rate_ter_high inv_ter_high, nquantiles(40)


collapse (sum) org_cap_comp ppent, by(year)

gen intan_cap = org_cap_comp/(org_cap_comp+ppent)

label variable intan_cap = "Intangible_over_total_capital"

line intan_cap year
