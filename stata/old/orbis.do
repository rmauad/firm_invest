// Code to run on the ORBIS database.
// This code tests whether intangible-intensive firms in ORBIS are more financially constrained than traditional companies.

// Following Altamonte et al. (2021) - Markups, intangible capital and heterogeneous financial frictions. - I measure intangible capital as the firms' total fixed costs.
// SG&A is not available in the ORBIS database.

use db_reg_1989_only.dta
xtset bvdidnumber year

// Commercial real estate
xtreg inv_at c.cre_ppe##c.med_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.terc_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.quar_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.quin_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust) 
xtreg inv_at c.cre_ppe##c.dec_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)

// Interest expense
xtreg inv_at c.interestexpenseaverageinterestbe##c.med_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.interestexpenseaverageinterestbe##c.terc_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.interestexpenseaverageinterestbe##c.quar_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.interestexpenseaverageinterestbe##c.quint_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)
xtreg inv_at c.interestexpenseaverageinterestbe##c.dec_1989 c.cashflowoperatingrevenue i.year if year >= 1990,fe cluster(ff_indust)

