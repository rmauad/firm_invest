# Regressions with intangibles (from prep_data_stata_20230226.R)

library(tidyverse)
library(foreign)
library(dplyr)
library(readxl)
library(lubridate)

load('data/rdata/intan_epk_q.RData')
load('data/rdata/ir.RData')
source('code/R/prep_dta/ff_ind.R')

#ExPanD(db_reg_comp)

#Treing the data
data_intan_q <- data_intan_q %>% # select(GVKEY, cusip, year, sic, xsgaq, sga, intanq, atq, ceqq, dlcq, dlttq, ppegtq, revtq, cheq, org_cap_comp, ltq, cshoq, prccq, saleq, ibq, dpq, ppentq, capxy, pstkq, invtq, xintq, CPI, RGDP, Ind_prod) %>%
  mutate(ff_indust = sapply(sic,ff_ind)) %>%
  mutate(total_debt = dlcq + dlttq) %>%
  mutate(debt_at = total_debt/atq) %>%
  mutate(ltdebt_at = dlttq/atq) %>%
  mutate(tang_at = ppegtq/atq) %>%
  mutate(debt_ceq = total_debt/ceqq) %>%
  mutate(cash_at = cheq/atq) %>%
  mutate(intan_at = org_cap_comp/atq) %>% 
  mutate(inter_ltdebt = xintq/dlttq) %>% 
  mutate(inter_debt = xintq/total_debt) %>%
  group_by(GVKEY) %>%
  mutate(gdp_g = (RGDP - dplyr::lag(RGDP,1))/dplyr::lag(RGDP,1)) %>%
  mutate(ip_g = (Ind_prod - dplyr::lag(Ind_prod,1))/dplyr::lag(Ind_prod,1)) %>%  
  mutate(log_cpi = log(CPI)) %>%
  mutate(inv_tang = ppegtq - dplyr::lag(ppegtq,1)) %>%
  mutate(inv_tang_perc = (ppegtq - dplyr::lag(ppegtq,1))/dplyr::lag(ppegtq,1)) %>%
  mutate(sales_gr = log(saleq) - log(dplyr::lag(saleq,1))) %>%
  mutate(cash_flow = cheq - dplyr::lag(cheq,1)) %>%
  mutate(d_cash_rev = cash_flow/revtq) %>%
  mutate(d_cash_at = cash_at - dplyr::lag(cash_at,1)) %>%
  mutate(d_log_assets = log(atq/dplyr::lag(atq,1))) %>%
  mutate(inv_intan = org_cap_comp - dplyr::lag(org_cap_comp)) %>%
  mutate(inv_intan_perc = (org_cap_comp - dplyr::lag(org_cap_comp))/dplyr::lag(org_cap_comp)) %>%
  mutate(debt_flow = total_debt - dplyr::lag(total_debt)) %>%
  mutate(d_debt_rev = debt_flow/revtq) %>%
  mutate(d_debt_at = debt_at - dplyr::lag(debt_at,1)) %>%
  mutate(ltdebt_flow = dlttq - dplyr::lag(dlttq)) %>%
  mutate(d_ltdebt_rev = ltdebt_flow/revtq) %>% 
  mutate(d_ltdebt_at = ltdebt_at - dplyr::lag(ltdebt_at,1)) %>%
  mutate(inter_flow = xintq - dplyr::lag(xintq)) %>%
  mutate(d_inter_ltdebt = inter_flow/ltdebt_flow) %>% 
  mutate(inv_tot = inv_tang + inv_intan) %>%
  mutate(inv_tot_perc =  (inv_tot - dplyr::lag(inv_tot))/dplyr::lag(inv_tot)) %>%
  mutate(inv_tang_rev = inv_tang/revtq,
         inv_tang_at = inv_tang/atq,
         inv_intan_at = inv_intan/atq) %>%
  mutate(inv_intan_rev = inv_intan/revtq) %>%
  mutate(inv_tot_rev = inv_tot/revtq) %>%
  mutate(inv_tot_at = inv_tot/atq) %>%
  mutate(inv_tot_ppe = inv_tot/dplyr::lag(ppentq)) %>%
 # mutate(emp_g = (emp - dplyr::lag(emp,1))/dplyr::lag(emp,1)) %>%
  mutate(#cre_ppe = fatb/dplyr::lag(ppentq),  #corporate real estate/lagged ppe
         #cre_at = fatb/dplyr::lag(atq),
         capx_ppe = capxy/dplyr::lag(ppentq),
         capx_ppe_perc = (capx_ppe - dplyr::lag(capx_ppe))/dplyr::lag(capx_ppe),
         mb = (cshoq*prccq + atq - ceqq - txdbq)/atq,
         cf = (ibq + dpq)/dplyr::lag(ppentq),
        # intan_cre_at = (org_cap_comp + fatb)/atq,
         inter_debt_perc = (inter_debt - dplyr::lag(inter_debt)/dplyr::lag(inter_debt)),
         ltdebt_issue_at = dltisy/atq,
         bankruptcy = 0,
         bankruptcy = c(bankruptcy[-n()],1)) %>%
  #  summarise(nyears = n())
 # mutate(dep_hv = dpacb/fatb) %>% #accumulated depreciation/historical value of buildings
  ungroup() %>%
  group_by(year_q) %>%
  mutate(bankruptcy = ifelse(year_q == 20204,0,bankruptcy))

## This block is to only keep companies that operate for at least 6 years in the sample ####

# nyears <- data_intan_q %>% group_by(GVKEY) %>%summarise(nyears = n())
# 
# data_intan_q <- inner_join(data_intan_q, nyears, by = 'GVKEY')
# 
# data_intan_q <- data_intan_q %>% filter(nyears >= 6)
# 
# data_intan_q <- data_intan_q[!is.infinite(data_intan_q$intan_at) & !is.na(data_intan_q$intan_at), ]

db_reg <- data_intan_q %>%
  group_by(year_q) %>%
  mutate(med = ntile(intan_at,2)) %>%
  mutate(tercile = ntile(intan_at,3)) %>%
  mutate(quartile = ntile(intan_at,4)) %>%
  mutate(quintile = ntile(intan_at,5)) %>%
  mutate(decile = ntile(intan_at,10)) %>%
  ungroup() %>%
 # mutate(gvkey_year = as.numeric(GVKEY)*10000 + year) %>%
  na.omit() %>% #THIS DROPS TOO MANY OBSERVATIONS. SEE WHY.
  filter_all(all_vars(!is.infinite(.)))


#db_reg <- db_reg[rowSums(is.na(db_reg)) != ncol(db_reg), ]

# d_1989 <- db_reg %>% filter(year == 1989) %>%
#   select(GVKEY, d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989) %>%
# rename(d_med_1989 = d_med_only_1989, d_terc_1989 = d_terc_only_1989, d_quar_1989 = d_quar_only_1989, d_quin_1989 = d_quin_only_1989, d_dec_1989 = d_dec_only_1989)


init <- 1990
end_sample <- 2020

ffrate <- read.table("data/csv/r_data.csv",sep = ",",header = TRUE)
ns <- read_excel("data/excel/MPshocksAcosta.xlsx", sheet = 'shocks')

ns <- ns %>%
  select(fomc, ns) %>%
  mutate(quarter = ifelse(month(fomc) <= 3, 1,
                          ifelse(month(fomc) > 3 & month(fomc) <= 6, 2,
                                 ifelse(month(fomc) > 6 & month(fomc) <= 9, 3, 4))),
   year_q = year(fomc)*10 + quarter,
   aux = (1 + ns/100)) %>%
  group_by(year_q) %>%
  summarise(ns_q = 100*(exp(mean(log(aux)))-1))
  
  

db_reg <- inner_join(db_reg, ir, by = 'year')
db_reg <- inner_join(db_reg, ns, by = 'year_q')
db_reg <- inner_join(db_reg, ffrate, by = 'year') %>%
  filter(year >= init & year <= end_sample) #, ff_indust != 6) #removing tech firms and others


#save(db_reg_comp, file = "db_reg_20220831.RData")
# write.dta(db_reg_comp, "db_reg_20220806.dta")
#write.dta(db_reg_1989, "data/dta/db_reg_1989_only.dta") #only firms in 1989
write.dta(db_reg, "data/dta/db_reg_q.dta") #all firms
#write.dta(db_reg_1980, "db_reg_1980.dta") #using only firms from 1980