// This code prepares the database from Orbis to run the regressions
ssc install egenmore //install this to use xtile with egen

// Creating Fama and French industry classification, quantiles of intangible capital and other variables
cd /homes/nber/mauadr/orbis.work/orbis4/bycnty/US
use year bvdidnumber intangibles totalassets netsales numberofemployees netpropertyplantequipment using dfindusd.dta
egen bvdid_year = concat(bvdidnumber year), punct(_)
duplicates drop bvdid_year, force
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan.dta, replace
	
use year bvdidnumber capitalexpenditures purchaseacquisitionofintangibles using cfusindusd.dta
egen bvdid_year = concat(bvdidnumber year), punct(_)
duplicates drop bvdid_year, force
merge 1:1 bvdid_year using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan.dta, keep(3) nogen
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_inv.dta, replace

// takes quite long to run
use year bvdidnumber cashflow cashcashequivalent operatingplebit using hindgfrusd.dta 
egen bvdid_year = concat(bvdidnumber year), punct(_)
duplicates drop bvdid_year, force
merge 1:1 bvdid_year using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_inv.dta, keep(3) nogen
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_inv_ctrl.dta, replace

//this drops MANY observations.
use bvdidnumber ussicprimarycodes using indclass.dta
duplicates drop bvdidnumber, force 
merge 1:m bvdidnumber using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_inv_ctrl.dta, keep(3) nogen
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_incomp.dta, replace

//gen intan_at = intan/totalassets
gen intan_cap = intangibles/(intangibles + netpropertyplantequipment)
gen intan_tan = intangibles/netpropertyplantequipment
gen intan_at = intangibles/totalassets
//gen inv_at = -(capitalexpenditures + purchaseacquisitionofintangibles)/totalassets
// these expenditures are registered as negative (outflow).

gen ff_indust = 1 if ussicprimarycodes >= 100 & ussicprimarycodes <= 999 | ussicprimarycodes >= 2000 & ussicprimarycodes <= 2399 | /*
		   */ussicprimarycodes >= 2700 & ussicprimarycodes <= 2749 | ussicprimarycodes >= 3100 & ussicprimarycodes <= 3199 |/*
		   */ussicprimarycodes >= 3940 & ussicprimarycodes <= 3989
replace ff_indust = 2 if ussicprimarycodes >= 2500 & ussicprimarycodes <= 2519 | ussicprimarycodes >= 2590 & ussicprimarycodes <= 2599 | /*
           */ussicprimarycodes >= 3630 & ussicprimarycodes <= 3659 | ussicprimarycodes >= 3710 & ussicprimarycodes <= 3711 | /*
           */ussicprimarycodes == 3714 | ussicprimarycodes == 3716 | ussicprimarycodes >= 3750 & ussicprimarycodes <= 3751 | /*
           */ussicprimarycodes == 3792 | ussicprimarycodes >= 3900 & ussicprimarycodes <= 3939 | ussicprimarycodes >= 3990 & ussicprimarycodes <= 3999
replace ff_indust = 3 if ussicprimarycodes >= 2520 & ussicprimarycodes <= 2589 | ussicprimarycodes >= 2600 & ussicprimarycodes <= 2699 | ussicprimarycodes >= 2750 & ussicprimarycodes <= 2769 | /*
           */ussicprimarycodes >= 3000 & ussicprimarycodes <= 3099 | ussicprimarycodes >= 3200 & ussicprimarycodes <= 3569 | ussicprimarycodes >= 3580 & ussicprimarycodes <= 3629 | /*
           */ussicprimarycodes >= 3700 & ussicprimarycodes <= 3709 | ussicprimarycodes >= 3712 & ussicprimarycodes <= 3713 | ussicprimarycodes == 3715 | ussicprimarycodes >= 3717 & ussicprimarycodes <= 3749 | /*
           */ussicprimarycodes >= 3752 & ussicprimarycodes <= 3791 | ussicprimarycodes >= 3793 & ussicprimarycodes <= 3799 | ussicprimarycodes >= 3830 & ussicprimarycodes <= 3839 | /*
           */ussicprimarycodes >= 3860 & ussicprimarycodes <= 3899
replace ff_indust = 4 if ussicprimarycodes >= 1200 & ussicprimarycodes <= 1399 | ussicprimarycodes >= 2900 & ussicprimarycodes <= 2999
replace ff_indust = 5 if ussicprimarycodes >= 2800 & ussicprimarycodes <= 2829 | ussicprimarycodes >= 2840 & ussicprimarycodes <= 2899
replace ff_indust = 6 if ussicprimarycodes >= 3570 & ussicprimarycodes <= 3579 | ussicprimarycodes >= 3660 & ussicprimarycodes <= 3692 | ussicprimarycodes >= 3694 & ussicprimarycodes <= 3699 | /*
           */ussicprimarycodes >= 3810 & ussicprimarycodes <= 3829 | ussicprimarycodes >= 7370 & ussicprimarycodes <= 7379
replace ff_indust = 7 if ussicprimarycodes >= 4800 & ussicprimarycodes <= 4899
replace ff_indust = 8 if ussicprimarycodes >= 4900 & ussicprimarycodes <= 4949
replace ff_indust = 9 if ussicprimarycodes >= 5000 & ussicprimarycodes <= 5999 | ussicprimarycodes >= 7200 & ussicprimarycodes <= 7299 | ussicprimarycodes >= 7600 & ussicprimarycodes <= 7699
replace ff_indust = 10 if ussicprimarycodes >= 2830 & ussicprimarycodes <= 2839 | ussicprimarycodes == 3693 | ussicprimarycodes >= 3840 & ussicprimarycodes <= 3859 | ussicprimarycodes >= 8000 & ussicprimarycodes <= 8099
replace ff_indust = 12 if ff_indust ==.

save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_ff.dta, replace

egen med = xtile(intan_cap), by(year ff_indust) n(2)
egen tercile = xtile(intan_cap), by(year ff_indust) n(3)
egen quartile = xtile(intan_cap), by(year ff_indust) n(4)
egen quintile = xtile(intan_cap), by(year ff_indust) n(5)
egen decile = xtile(intan_cap), by(year ff_indust) n(10)

save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/intan_comp_2yt_intan_cap.dta, replace
// Merging databases
merge m:1 year using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_y_orbis_2yt_all_measures.dta, keep(3) nogen //only keep matched observations
//drop if year == year[_n-1] //in case there are repeated time values within the panel
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_2yt_intan_cap_all_measures.dta, replace

// Selecting non-publicly traded firms
use bvdidnumber stockexchangeslisted using exchanges.dta
duplicates drop bvdidnumber, force
merge 1:m bvdidnumber using /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_2yt_intan_cap_all_measures.dta, keep(2) //keep (2) preserves the observations from b_reg_orbis.dta that did not have an equivalent in exchanges.dta
save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_npt_2yt_intan_cap_all_measures.dta, replace
