// Set wd to the root folder
// This code runs the random coefficient model - but I don't understand why I don't get 9 coefficients (since there are 9 industries)

use data/dta/db_reg_1989_only.dta
winsor2 debt_at, replace cut(1 99) trim
xtset GVKEY year

mixed inv_tang_at cre_at || ff_indust: cre_at



