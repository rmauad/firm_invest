ssc install psmatch2

use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_states_complete.dta, clear //from pre_process_all.do
xtset bvdid_code year

******************
* Firm  variables
*******************

gen inv = -capitalexpenditures
by bvdid_code: gen ln_assets_lag1 = L.ln_assets

***************************************************************************
* Probit model to estimate the probability of being non-publicly-traded
***************************************************************************

probit stck_exc_ind ln_assets dln_netsales cash_at inv
predict p_score, pr
psmatch2 p_score, neighbor(3) common
pstest ln_assets dln_netsales cash_at inv, graph
gen matched = _treated + _control
keep if matched == 1

save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_psm_2yt_states_complete.dta, replace

