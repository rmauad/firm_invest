
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt.dta, clear //from orbis_create_db.do
egen bvdid_code = group(bvdidnumber)
xtset bvdid_code year

***************************************************************************
* Lagged 2yT and intangibility classification and keep only tangible firms
***************************************************************************

sort bvdid_code year
by bvdid_code: gen d_treas_2y_lag1 = L.d_treas_2y

gen ter_bot = 0
replace ter_bot = 1 if tercile == 1
gen ter_top = 0
replace ter_top = 1 if tercile == 3

**************************
* Firm control variables
**************************

gen cash_at = cashcashequivalent/totalassets
by bvdid_code: gen cash_at_lag1 = L.cash_at

gen ln_netsales = ln(netsales)
by bvdid_code: gen ln_netsales_lag1 = L.ln_netsales
by bvdid_code: gen dln_netsales = ln_netsales - ln_netsales_lag1
by bvdid_code: gen dln_netsales_lag1 = L.dln_netsales

gen ln_assets = ln(totalassets)

********************
** Macro controls
********************

gen ln_ind_prod = ln(Ind_prod)
by bvdid_code: gen ln_ind_prod_lag1 = L.ln_ind_prod
by bvdid_code: gen dln_ind_prod = ln_ind_prod - ln_ind_prod_lag1
by bvdid_code: gen dln_ind_prod_lag1 = L.dln_ind_prod

gen ln_RGDP = ln(RGDP)
by bvdid_code: gen ln_RGDP_lag1 = L.ln_RGDP
by bvdid_code: gen dln_RGDP = ln_RGDP - ln_RGDP_lag1
by bvdid_code: gen dln_RGDP_lag1 = L.dln_RGDP

by bvdid_code: gen CPI_lag1 = L.CPI

********************************
* Generating cumulative returns
********************************

gen ln_nppe = ln(netpropertyplantequipment)

local lead_cur 4
quietly forval h = 1/`lead_cur' {
by bvdid_code: gen ln_nppe_lead`h' = L`h'.ln_nppe
by bvdid_code: gen dln_inv`h' = ln_nppe_lead`h' - ln_nppe 
}

save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_states_complete.dta, replace

