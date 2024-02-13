# Regressions with intangibles - use variation of debt/revenue

#install.packages("ExPanDaR")
#library(ROCR)
# library(stats)
# library(tidyverse)
# library(lubridate)
# library(ggplot2)
# library(reshape2)
# library(plm)
# library(tidyr)
library(tidyverse)
library(foreign)
# library(plm)
# library(quantreg)
# library(stargazer)
library(dplyr)
# library(statar)
# library(Hmisc)
# library(sandwich)
# library(clubSandwich)
# library(SparseM)
# library(lmtest)
# library(multiwayvcov)
# library(prediction)
# library(ExPanDaR)

load('data/rdata/intan_epk.RData')
source('code/R/prep_dta/ff_ind.R')

#ExPanD(db_reg_comp)

#Treating the data
data_intan <- data_intan %>% select(GVKEY, cusip, year, sic, xsga, sga, intan, at, ceq, dlc, dltt, ppegt, revt, che, org_cap_comp, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xint, CPI, GDP, Ind_prod, fatb, Founding, prcc_c, txdb, ppent, ib, dp, ppent, dltis) %>%
  mutate(ff_indust = sapply(sic,ff_ind)) %>%
  mutate(total_debt = dlc + dltt) %>%
  mutate(debt_at = total_debt/at) %>%
  mutate(ltdebt_at = dltt/at) %>%
  mutate(tang_at = ppegt/at) %>%
  mutate(debt_ceq = total_debt/ceq) %>%
  mutate(cash_at = che/at) %>%
  mutate(intan_at = org_cap_comp/at) %>% 
  mutate(inter_ltdebt = xint/dltt) %>% 
  mutate(inter_debt = xint/total_debt) %>%
  group_by(GVKEY) %>%
  mutate(gdp_g = (GDP - dplyr::lag(GDP,1))/dplyr::lag(GDP,1)) %>%
  mutate(ip_g = (Ind_prod - dplyr::lag(Ind_prod,1))/dplyr::lag(Ind_prod,1)) %>%  
  mutate(log_cpi = log(CPI)) %>%
  mutate(inv_tang = ppegt - dplyr::lag(ppegt,1)) %>%
  mutate(inv_tang_perc = (ppegt - dplyr::lag(ppegt,1))/dplyr::lag(ppegt,1)) %>%
  mutate(sales_gr = log(sale) - log(dplyr::lag(sale,1))) %>%
  mutate(cash_flow = che - dplyr::lag(che,1)) %>%
  mutate(d_cash_rev = cash_flow/revt) %>%
  mutate(d_cash_at = cash_at - dplyr::lag(cash_at,1)) %>%
  mutate(d_log_assets = log(at/dplyr::lag(at,1))) %>%
  mutate(inv_intan = org_cap_comp - dplyr::lag(org_cap_comp)) %>%
  mutate(inv_intan_perc = (org_cap_comp - dplyr::lag(org_cap_comp))/dplyr::lag(org_cap_comp)) %>%
  mutate(debt_flow = total_debt - dplyr::lag(total_debt)) %>%
  mutate(d_debt_rev = debt_flow/revt) %>%
  mutate(d_debt_at = debt_at - dplyr::lag(debt_at,1)) %>%
  mutate(ltdebt_flow = dltt - dplyr::lag(dltt)) %>%
  mutate(d_ltdebt_rev = ltdebt_flow/revt) %>% 
  mutate(d_ltdebt_at = ltdebt_at - dplyr::lag(ltdebt_at,1)) %>%
  mutate(inter_flow = xint - dplyr::lag(xint)) %>%
  mutate(d_inter_ltdebt = inter_flow/ltdebt_flow) %>% 
  mutate(inv_tot = inv_tang + inv_intan) %>%
  mutate(inv_tot_perc =  (inv_tot - dplyr::lag(inv_tot))/dplyr::lag(inv_tot)) %>%
  mutate(inv_tang_rev = inv_tang/revt,
         inv_tang_at = inv_tang/at,
         inv_intan_at = inv_intan/at) %>%
  mutate(inv_intan_rev = inv_intan/revt) %>%
  mutate(inv_tot_rev = inv_tot/revt) %>%
  mutate(inv_tot_at = inv_tot/at) %>%
  mutate(inv_tot_ppe = inv_tot/dplyr::lag(ppent)) %>%
  mutate(emp_g = (emp - dplyr::lag(emp,1))/dplyr::lag(emp,1)) %>%
  mutate(cre_ppe = fatb/dplyr::lag(ppent),  #corporate real estate/lagged ppe
         cre_at = fatb/dplyr::lag(at),
         capx_ppe = capx/dplyr::lag(ppent),
         capx_ppe_perc = (capx_ppe - dplyr::lag(capx_ppe))/dplyr::lag(capx_ppe),
         mb = (csho*prcc_c + at - ceq - txdb)/at,
         cf = (ib + dp)/dplyr::lag(ppent),
         intan_cre_at = (org_cap_comp + fatb)/at,
         inter_debt_perc = (inter_debt - dplyr::lag(inter_debt)/dplyr::lag(inter_debt)),
         ltdebt_issue_at = dltis/at) %>%
 # mutate(dep_hv = dpacb/fatb) %>% #accumulated depreciation/historical value of buildings
  ungroup()

data_intan <- data_intan[!is.infinite(data_intan$intan_at) & !is.na(data_intan$intan_at), ]

db_reg <- data_intan %>%
  group_by(year & ff_indust) %>%
  mutate(med = ntile(intan_at,2)) %>%
  mutate(tercile = ntile(intan_at,3)) %>%
  mutate(quartile = ntile(intan_at,4)) %>%
  mutate(quintile = ntile(intan_at,5)) %>%
  mutate(decile = ntile(intan_at,10)) %>%
  mutate(d_med_only_1989 = ifelse(med == 2 & year == 1989, 1, 0)) %>%
  mutate(d_terc_only_1989 = ifelse(tercile == 3 & year == 1989, 1, 0)) %>%
  mutate(d_quar_only_1989 = ifelse(quartile == 4 & year == 1989, 1, 0)) %>%
  mutate(d_quin_only_1989 = ifelse(quintile == 5 & year == 1989, 1, 0)) %>%
  mutate(d_dec_only_1989 = ifelse(decile == 10 & year == 1989, 1, 0)) %>%
  mutate(med_only_1989 = ifelse(year == 1989, med, 0),
         terc_only_1989 = ifelse(year == 1989, tercile, 0),
         quar_only_1989 = ifelse(year == 1989, quartile, 0),
         quin_only_1989 = ifelse(year == 1989, quintile, 0),
         dec_only_1989 = ifelse(year == 1989, decile, 0),
         d_2terc_only_1989 = ifelse(tercile == 2 | tercile == 3 & year == 1989, 1, 0),
         d_3quar_only_1989 = ifelse(quartile == 2 | quartile == 3 | quartile == 4 & year == 1989, 1, 0),
         d_2quin_only_1989 = ifelse(quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_3quin_only_1989 = ifelse(quintile == 3 | quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_4quin_only_1989 = ifelse(quintile == 2 | quintile == 3 | quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_2dec_only_1989 = ifelse(decile == 9 | decile == 10 & year == 1989, 1, 0)) %>%
  ungroup() %>%
  mutate(gvkey_year = as.numeric(GVKEY)*10000 + year) %>%
  na.omit() %>%
  filter_all(all_vars(!is.infinite(.)))


#db_reg <- db_reg[rowSums(is.na(db_reg)) != ncol(db_reg), ]

# d_1989 <- db_reg %>% filter(year == 1989) %>%
#   select(GVKEY, d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989) %>%
# rename(d_med_1989 = d_med_only_1989, d_terc_1989 = d_terc_only_1989, d_quar_1989 = d_quar_only_1989, d_quin_1989 = d_quin_only_1989, d_dec_1989 = d_dec_only_1989)

d_1989 <- db_reg %>% filter(year == 1989) %>%
  select(GVKEY, med_only_1989, terc_only_1989, quar_only_1989, quin_only_1989, dec_only_1989,
         d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989,
         d_2terc_only_1989, d_3quar_only_1989, d_2quin_only_1989, d_3quin_only_1989, d_4quin_only_1989, d_2dec_only_1989) %>%
rename(med_1989 = med_only_1989, terc_1989 = terc_only_1989, quar_1989 = quar_only_1989, quin_1989 = quin_only_1989, dec_1989 = dec_only_1989,
       d_med_1989 = d_med_only_1989, d_terc_1989 = d_terc_only_1989, d_quar_1989 = d_quar_only_1989, d_quin_1989 = d_quin_only_1989, d_dec_1989 = d_dec_only_1989,
       d_2terc_1989 = d_2terc_only_1989, d_3quar_1989 = d_3quar_only_1989, d_2quin_1989 = d_2quin_only_1989, d_3quin_1989 = d_3quin_only_1989, d_4quin_1989 = d_4quin_only_1989, d_2dec_1989 = d_2dec_only_1989)


db_reg_d_1989 <- left_join(d_1989, db_reg, by = "GVKEY")

init <- 1990
end_sample <- 2020

ffrate <- read.table("data/csv/r_data.csv",sep = ",",header = TRUE)
db_reg_1989 <- inner_join(db_reg_d_1989, ffrate, by = 'year') %>%
  filter(year >= init & year <= end_sample, ff_indust != 6) #removing tech firms and others


#save(db_reg_comp, file = "db_reg_20220831.RData")
# write.dta(db_reg_comp, "db_reg_20220806.dta")
write.dta(db_reg_1989, "data/dta/db_reg_1989_only.dta") #only firms in 1989
#write.dta(db_reg_1980, "db_reg_1980.dta") #using only firms from 1980