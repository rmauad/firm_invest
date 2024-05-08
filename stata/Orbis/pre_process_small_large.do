
use /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_all_2yt_states_complete.dta, clear //from pre_process_all.do
xtset bvdid_code year

******************
* Size median
*******************

egen med_size = median(totalassets)
gen large = totalassets >= med_size

egen med_cash_at = median(cash_at)
gen cash_high = cash_at >= med_cash_at

save /homes/nber/mauadr/bulk/orbis.work/intan_mp/data/dta/db_reg_orbis_median_2yt_states_complete.dta, replace

