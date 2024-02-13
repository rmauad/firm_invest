# Regressions with intangibles (from prep_data_stata_20230226.R)

library(tidyverse)
library(foreign)
library(dplyr)
library(readxl)
library(lubridate)

load('data/rdata/intan_epk_q.RData')
load('data/rdata/ir.RData')
source('code/R/prep_dta/ff_ind.R')

# CREATING NEW VARIABLES ####

data_intan_q_new <- data_intan_q %>% select(GVKEY, cusip, year, year_q, sic, atq, ceqq, dlcq, dlttq, 
                                            ppegtq, cheq, org_cap_comp, 
                                            saleq, ibq, dpq, 
                                            ppentq, CPI, RGDP, Ind_prod, dltisy, emp, capxy) %>%
  mutate(ff_indust = sapply(sic,ff_ind)) %>%
  mutate(total_debt = dlcq + dlttq) %>%
  mutate(debt_at = total_debt/atq) %>%
  mutate(ltdebt_at = dlttq/atq) %>%
  mutate(cash_at = cheq/atq) %>%
  mutate(intan_at = org_cap_comp/atq) %>% 
  group_by(GVKEY) %>%
  mutate(gdp_g = (RGDP - dplyr::lag(RGDP,1))/dplyr::lag(RGDP,1)) %>%
  mutate(ip_g = (Ind_prod - dplyr::lag(Ind_prod,1))/dplyr::lag(Ind_prod,1)) %>%  
  mutate(log_cpi = log(CPI)) %>%
  mutate(sales_gr = log(saleq) - log(dplyr::lag(saleq,1))) %>%
  mutate(inv_intan = org_cap_comp - dplyr::lag(org_cap_comp)) %>%
  mutate(inv_tot = capxy + inv_intan) %>% #INCLUDE SEVERAL LAGS HERE? OR IN STATA?
  mutate(inv_tot_at = inv_tot/atq) %>%
  mutate(dln_emp = log(emp) - dplyr::lag(log(emp))) %>%
  mutate(ltdebt_issue_at = dltisy/atq,
         bankruptcy = 0,
         bankruptcy = c(bankruptcy[-n()],1)) %>%
  ungroup() %>%
  group_by(year_q) %>%
  mutate(bankruptcy = ifelse(year_q == 20204,0,bankruptcy))

data_intan_q_new <- data_intan_q_new[!is.infinite(data_intan_q_new$intan_at) & !is.na(data_intan_q_new$intan_at), ]

# CREATING QUANTILES OF INTANGIBILITY
db_reg <- data_intan_q_new %>%
  group_by(year_q) %>%
  mutate(med = ntile(intan_at,2)) %>%
  mutate(tercile = ntile(intan_at,3)) %>%
  mutate(quartile = ntile(intan_at,4)) %>%
  mutate(quintile = ntile(intan_at,5)) %>%
  mutate(decile = ntile(intan_at,10)) %>%
  ungroup() %>%
  na.omit() %>% #THIS DROPS TOO MANY OBSERVATIONS. SEE WHY.
  filter_all(all_vars(!is.infinite(.)))


# MERGING WITH THE MONETARY POLICY SHOCKS ####
init <- 1990
end_sample <- 2020

ffrate <- read.table("data/csv/r_data.csv",sep = ",",header = TRUE)
ns <- read_excel("data/excel/MPshocksAcosta.xlsx", sheet = 'shocks')
rogers <- read.table("data/csv/FromRogers1.csv", sep = ",",header = TRUE)
swanson <- read.table("data/csv/FromSwanson.csv", sep = ",",header = TRUE)


# Nakamura and Steinson shocks
ns_sel <- ns %>%
  select(fomc, ns) %>%
  mutate(quarter = ifelse(month(fomc) <= 3, 1,
                          ifelse(month(fomc) > 3 & month(fomc) <= 6, 2,
                                 ifelse(month(fomc) > 6 & month(fomc) <= 9, 3, 4))),
         year_q = year(fomc)*10 + quarter,
         aux = (1 + ns/100)) %>%
  group_by(year_q) %>%
  summarise(ns_q = 100*(exp(mean(log(aux)))-1))

# John Rogers shocks
rogers_sel <- rogers %>%
  select(-c(MP_ns)) %>%
  mutate(rm = ifelse(is.na(MP_brw) & is.na(MP_JKff3), 1, 0)) %>%
  filter(rm != 1) %>%
  mutate(quarter = ifelse(month <= 3, 1,
                          ifelse(month > 3 & month <= 6, 2,
                                 ifelse(month > 6 & month <= 9, 3, 4))),
         year_q = year*10 + quarter,
         brw_q = (1 + MP_brw/100),
         JKff3_q = (1 + MP_JKff3/100)) %>%
  group_by(year_q) %>%
  summarise(brw_q = 100*(exp(mean(log(brw_q), na.rm = TRUE))-1),
         JKff3_q = 100*(exp(mean(log(JKff3_q), na.rm = TRUE))-1))

# Swason shocks

swanson_sel <- swanson %>%
  mutate(quarter = ifelse(month(as.Date(Date, format = "%m/%d/%y")) <= 3, 1,
                          ifelse(month(as.Date(Date, format = "%m/%d/%y")) > 3 & month(as.Date(Date, format = "%m/%d/%Y")) <= 6, 2,
                                 ifelse(month(as.Date(Date, format = "%m/%d/%y")) > 6 & month(as.Date(Date, format = "%m/%d/%Y")) <= 9, 3, 4))),
         year_q = year(as.Date(Date, format = "%m/%d/%y"))*10 + quarter)


db_reg <- inner_join(db_reg, ir, by = 'year')
db_reg <- inner_join(db_reg, ns_sel, by = 'year_q')
db_reg <- inner_join(db_reg, rogers_sel, by = 'year_q')
db_reg <- inner_join(db_reg, swanson_sel, by = 'year_q')
db_reg <- inner_join(db_reg, ffrate, by = 'year') %>%
  filter(year >= init & year <= end_sample) #, ff_indust != 6) #removing tech firms and others

db_reg <- db_reg %>% group_by(GVKEY, year_q) %>% filter(row_number()==1) #keep just the first observation

# SAVING ####
save(db_reg, file = "data/rdata/db_reg_ml.RData")
# write.dta(db_reg_comp, "db_reg_20220806.dta")
#write.dta(db_reg_1989, "data/dta/db_reg_1989_only.dta") #only firms in 1989
#write.dta(db_reg, "data/dta/db_reg_q.dta") #all firms
#write.dta(db_reg_1980, "db_reg_1980.dta") #using only firms from 1980