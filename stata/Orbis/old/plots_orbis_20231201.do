// Plots of intangible/assets, investment/assets and employment change over time.


//bysort year: egen avr_intan_at = mean(intan_at)
gen intan_ppe = org_cap/netpropertyplantequipment
gen intan_sales = org_cap/netsales
gen intan_tot = org_cap/(org_cap + netpropertyplantequipment)

gen intan_inv =.
gen ln_org_cap = ln(org_cap)
sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {
    sort bvdidnumber year
	by bvdidnumber: replace intan_inv = ln_org_cap - ln_org_cap[_n- 1] if _n > 1
}

gen at_g =.
gen ln_at = ln(totalassets)
sort bvdidnumber year

 levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {
    sort bvdidnumber year
	by bvdidnumber: replace at_g = ln_at - ln_at[_n- 1] if _n > 1
}

	   graph box at_g intan_inv, title("title") ylabel(0[0.1]1) yscale(range(0 1)) nooutside over(year)

	   
label variable intan_ppe " "


forval y = 1990/2019 {
    if mod(`y', 3) {
        label def yearz `y' `"{c 0xa0}"', add 
    }
}

	   label value year yearz
	   label li yearz
	   // tab year

	   graph box intan_ppe, title("Intangible/tangible") ylabel(0[10]60) yscale(range(0 6)) nooutside over(year)
graph export /homes/nber/mauadr/bulk/orbis.work/intan_mp/graphs/intan_at.eps
	 //  graph box intan_at, title("Intangible/assets") ylabel(0[1]10) yscale(range(0 1)) nooutside over(year)
	 graph box intan_tot, title("Intangible/tot") ylabel(0[1]10) yscale(range(0 1)) nooutside over(year)
	 graph box inv_at, title("title") ylabel(0[0.1]1) yscale(range(0 1)) nooutside over(year)

	   
// Employment change (with respect to the first year)

gen ln_emp_gr = .
gen ln_emp = ln(numberofemployees)
gen ln_emp_1995 = 0 
replace ln_emp_1995 = ln(numberofemployees) if year == 1995

sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {
    sort bvdidnumber year
	by bvdidnumber: replace ln_emp_gr = ln_emp - ln_emp_1995 if _n > 1
}

*******************
*  Investment
*******************
gen inv_at = (capitalexpenditures + purchaseacquisitionofintangibles)/totalassets


gen inv_gr = .
gen inv_at_1995 = 0
replace inv_at_1995 = inv_at if year == 1995

sort bvdidnumber year

// Use a forval loop to loop through each firm
levelsof bvdidnumber, local(firm_list)
foreach bvdidnumber of local firm_list {
    sort bvdidnumber year
	by bvdidnumber: replace inv_gr = inv_at - inv_at_1995 if _n > 1
}


binscatter ln_emp_gr inv_gr

winsor2 intan_at, replace cut(1 99) trim

binscatter intan_at inv_at, nquantiles(10)
