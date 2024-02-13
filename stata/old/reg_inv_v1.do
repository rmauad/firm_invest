//Regress total investment on MP shock*dummy 1985 (classification of intangible in 1985 - only firms existing in 1985).

//cd "/Users/robertomauad/Library/Mobile Documents/com~apple~CloudDocs/2021/PhD/Paper_intangibles_mp_20220704/Empirical_monetary/Stata/Post_QE"
use db_reg_1985_only.dta
winsor2 debt_at, replace cut(1 99) trim

// Volume of debt
xtset GVKEY year

// Labeling variables
label variable debt_at   "Debt/Assets"
label variable ffrate_zlb   "Moneraty policy"
label variable sales_gr   "Sales growth(-1)"
label variable cash_at   "Cash/Assets"
label variable d_med_1985   "Pre-sample D median"
label variable d_terc_1985   "Pre-sample D tercile"
label variable d_quar_1985   "Pre-sample D quartile"
label variable d_quin_1985   "Pre-sample D quintile"
label variable d_dec_1985   "Pre-sample D decile"

gen lag_ppe = L.ppegt
// With sales_gr as a control variable, dummy created in 1980 - MP is negative and significant. Interaction with dummy is negative and close to significant
//eststo clear

xtreg inv_tot c.fatb##d_med_1985 c.L.sales_gr c.cash_at i.year if year >= 1986,fe cluster(ff_indust) 
//outreg2 using debt_at.tex, replace label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
xtreg inv_tot c.fatb##d_terc_1985 c.L.sales_gr c.cash_at i.year if year >= 1986,fe cluster(ff_indust) 
// outreg2 using debt_at.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
xtreg inv_tot c.fatb##d_quar_1985 c.L.sales_gr c.cash_at i.year if year >= 1986,fe cluster(ff_indust) 
// outreg2 using debt_at.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
xtreg inv_tot c.fatb##d_quin_1985 c.L.sales_gr c.cash_at i.year if year >= 1986,fe cluster(ff_indust) 
// outreg2 using debt_at.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)
xtreg inv_tot c.fatb##d_dec_1985 c.L.sales_gr c.cash_at i.year if year >= 1986,fe cluster(ff_indust)
//outreg2 using debt_at.tex, append label drop(i.year) dec(3) nocons alpha(0.01, 0.05, 0.1, 0.15) symbol(***, **, *, +)


//esttab using ex1.tex, se ar2 stats(N r2) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) drop(*.ff_indust)
//outreg2 using ex1.tex, replace drop(*.ff_indust)






