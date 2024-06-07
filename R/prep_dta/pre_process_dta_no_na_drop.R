# Database pre-processing:
 # Generating dln_emp, probability of exiting the database, etc.

library(dplyr)
library(foreign)

load("data/rdata/db_reg_2yt.rdata") # from prep_data_no_na_drop.R
load("data/rdata/state.rdata")

db_reg <- left_join(db_reg, state, by = "GVKEY")
  
db_reg <- db_reg %>%
  group_by(GVKEY) %>%
  mutate(dln_emp = log(emp) - log(dplyr::lag(emp,1)),
         dln_emp1 = log(dplyr::lead(emp,1)) - log(emp),
         dln_emp2 = log(dplyr::lead(emp,2)) - log(emp),
         dln_emp3 = log(dplyr::lead(emp,3)) - log(emp),
         dln_emp4 = log(dplyr::lead(emp,4)) - log(emp),
         dln_emp5 = log(dplyr::lead(emp,5)) - log(emp),
         dln_emp6 = log(dplyr::lead(emp,6)) - log(emp),
         dln_emp7 = log(dplyr::lead(emp,7)) - log(emp),
         dln_emp8 = log(dplyr::lead(emp,8)) - log(emp),
         dln_emp9 = log(dplyr::lead(emp,9)) - log(emp),
         dln_emp10 = log(dplyr::lead(emp,10)) - log(emp),
         dln_emp11 = log(dplyr::lead(emp,11)) - log(emp),
         dln_emp12 = log(dplyr::lead(emp,12)) - log(emp),
         sales_growth_lag1 = dplyr::lag(sales_gr,1),
         d_treas_2y_lag1 = dplyr::lag(d_treas_2y_q/100,1),
         cash_at_lag1 = dplyr::lag(cash_at,1),
         Ind_prod_lag1 = dplyr::lag(Ind_prod,1),
         Inflation_lag1 = dplyr::lag(CPI,1),
         RGDP_lag1 = dplyr::lag(RGDP,1),
         Ind_prod_lag1 = dplyr::lag(Ind_prod,1),
         ln_assets = log(atq),
         dln_RGDP_lag1 = dplyr::lag(dln_RGDP,1),
         d_Ind_prod_lag1 = dplyr::lag(d_Ind_prod,1),
         med_top = ifelse(med == 2, 1, 0),
         ter_top = ifelse(tercile == 3, 1, 0),
         qua_top = ifelse(quartile == 4, 1, 0),
         med_bot = ifelse(med == 1, 1, 0),
         ter_bot = ifelse(tercile == 1, 1, 0),
         qua_bot = ifelse(quartile == 1, 1, 0),
         d_less_const = ifelse((state == "TX" | state == "LA") & 
                                 (year >= 1997 & year <= 2003) | state == "AL" & 
                                 (year >= 2001 & year <= 2003) | state == "DE" & 
                                 (year >= 2002 & year <= 2003), 1, 0),
         inv_at = capxy/atq,
         dln_inv1 = log(dplyr::lead(ppentq,1)) - log(ppentq),
         dln_inv2 = log(dplyr::lead(ppentq,2)) - log(ppentq),
         dln_inv3 = log(dplyr::lead(ppentq,3)) - log(ppentq),
         dln_inv4 = log(dplyr::lead(ppentq,4)) - log(ppentq),
         dln_inv5 = log(dplyr::lead(ppentq,5)) - log(ppentq),
         dln_inv6 = log(dplyr::lead(ppentq,6)) - log(ppentq),
         dln_inv7 = log(dplyr::lead(ppentq,7)) - log(ppentq),
         dln_inv8 = log(dplyr::lead(ppentq,8)) - log(ppentq),
         dln_inv9 = log(dplyr::lead(ppentq,9)) - log(ppentq),
         dln_inv10 = log(dplyr::lead(ppentq,10)) - log(ppentq),
         dln_inv11 = log(dplyr::lead(ppentq,11)) - log(ppentq),
         dln_inv12 = log(dplyr::lead(ppentq,12)) - log(ppentq))

write.dta(db_reg, "data/dta/db_reg_comp.dta")
write.csv(db_reg, "data/csv/db_reg.csv")

