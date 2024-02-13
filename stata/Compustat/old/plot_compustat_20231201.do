
// Plots of intangible/assets, investment/assets and employment change over time.

use data/dta/db_reg_emp_cf_q_with_exit.dta
//bysort year: egen avr_intan_at = mean(intan_at)
gen intan_ppe = org_cap_comp/ppentq
gen intan_cap = org_cap_comp/(org_cap_comp + ppentq)

label variable intan_ppe " "


forval y = 1990/2019 {
    if mod(`y', 3) {
        label def yearz `y' `"{c 0xa0}"', add 
    }
}

	   label value year yearz
	   label li yearz
	   // tab year

	   graph box intan_at, title("Intangible/assets") ylabel(0[0.05].2) yscale(range(0 0.2)) nooutside over(year)
//graph export /homes/nber/mauadr/bulk/orbis.work/intan_mp/graphs/intan_at.eps

	   graph box intan_ppe, title("Intangible/tangible") ylabel(0[0.5]2) yscale(range(0 2)) nooutside over(year)
	   graph box intan_at, title("Intangible/total") ylabel(0[0.5]2) yscale(range(0 2)) nooutside over(year)

	  
// Plot intan_at vs equity/at

gen eq_tot = ceqq/(org_cap_comp + ppentq)
winsor2 intan_at, replace cut(0 95) trim
	   binscatter eq_tot intan_tot, nquantiles(40)
