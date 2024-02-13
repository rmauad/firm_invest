# Regressions with intangibles - use variation of debt/revenue

#install.packages("ExPanDaR")
#library(ROCR)
library(stats)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(reshape2)
library(plm)
library(tidyr)
library(tidyverse)
library(foreign)
library(plm)
library(quantreg)
library(stargazer)
library(dplyr)
library(statar)
library(Hmisc)
library(sandwich)
library(clubSandwich)
library(SparseM)
library(lmtest)
library(multiwayvcov)
library(prediction)
library(ExPanDaR)

load('intan_epk.RData')
source('ff_ind.R')

#ExPanD(db_reg_comp)

#Treating the data
data_intan <- data_intan %>% select(GVKEY, cusip, year, sic, xsga, sga, intan, at, ceq, dlc, dltt, ppegt, revt, che, org_cap_comp, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xint, CPI, GDP, Ind_prod, fatb, dpacb, Founding) %>%
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
  mutate(inv_tang_rev = inv_tang/revt) %>%
  mutate(inv_intan_rev = inv_intan/revt) %>%
  mutate(inv_tot_rev = inv_tot/revt) %>%
  mutate(emp_g = (emp - dplyr::lag(emp,1))/dplyr::lag(emp,1)) %>%
  mutate(cre_at = fatb/at) %>% #corporate real estate/assets
  mutate(dep_hv = dpacb/fatb) %>% #accumulated depreciation/historical value of buildings
  ungroup()

data_intan <- data_intan[!is.infinite(data_intan$intan_at) & !is.na(data_intan$intan_at), ]

db_reg <- data_intan %>%
  group_by(year & ff_indust) %>%
  mutate(med = ntile(intan_at,2)) %>%
  mutate(tercile = ntile(intan_at,3)) %>%
  mutate(quartile = ntile(intan_at,4)) %>%
  mutate(quintile = ntile(intan_at,5)) %>%
  mutate(decile = ntile(intan_at,10)) %>%
  mutate(d_med_only_1985 = ifelse(med == 2 & year == 1985, 1, 0)) %>%
  mutate(d_terc_only_1985 = ifelse(tercile == 3 & year == 1985, 1, 0)) %>%
  mutate(d_quar_only_1985 = ifelse(quartile == 4 & year == 1985, 1, 0)) %>%
  mutate(d_quin_only_1985 = ifelse(quintile == 5 & year == 1985, 1, 0)) %>%
  mutate(d_dec_only_1985 = ifelse(decile == 10 & year == 1985, 1, 0)) %>%
  ungroup() %>%
  mutate(gvkey_year = as.numeric(GVKEY)*10000 + year) %>%
  na.omit() %>%
  filter_all(all_vars(!is.infinite(.)))

#db_reg <- db_reg[rowSums(is.na(db_reg)) != ncol(db_reg), ]

d_1985 <- db_reg %>% filter(year == 1985) %>%
  select(GVKEY, d_med_only_1985, d_terc_only_1985, d_quar_only_1985, d_quin_only_1985, d_dec_only_1985) %>%
rename(d_med_1985 = d_med_only_1985, d_terc_1985 = d_terc_only_1985, d_quar_1985 = d_quar_only_1985, d_quin_1985 = d_quin_only_1985, d_dec_1985 = d_dec_only_1985)

db_reg_d_1985 <- left_join(d_1985, db_reg, by = "GVKEY")

init <- 1986
end_sample <- 2020

ffrate <- read.table("r_data.csv",sep = ",",header = TRUE)
db_reg_1985 <- inner_join(db_reg_d_1985, ffrate, by = 'year') %>%
  filter(year >= init & year <= end_sample)
#save(db_reg_comp, file = "db_reg_20220831.RData")
# write.dta(db_reg_comp, "db_reg_20220806.dta")
#write.dta(db_reg_1985, "db_reg_1985_only.dta") #only firms in 1985
#write.dta(db_reg_1980, "db_reg_1980.dta") #using only firms from 1980