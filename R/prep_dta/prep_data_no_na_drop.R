# Regressions with intangibles (from prep_data_stata_20230226.R)

library(tidyverse)
library(foreign)
library(dplyr)
library(readxl)
library(lubridate)

load('data/rdata/intan_epk_q.RData') #from intan_epk_q.R ("merge" folder)
source('code/firm_invest/R/prep_dta/ff_ind.R')

# CREATING NEW VARIABLES ####

data_intan_q_new <- data_intan_q %>% select(DATE, rdq, GVKEY, cusip, year, year_q, sic, atq, ceqq, dlcq, dlttq, 
                                            ppegtq, cheq, org_cap_comp, 
                                            saleq, ibq, dpq, 
                                            ppentq, CPI, RGDP, Ind_prod, dln_RGDP, d_Ind_prod, dltisy, capxy, cshoq, prccq, xrdq, xsgaq) %>%
  mutate(ff_indust = sapply(sic,ff_ind)) %>%
  mutate(total_debt = dlcq + dlttq) %>%
  mutate(debt_at = total_debt/atq) %>%
  mutate(ltdebt_at = dlttq/atq) %>%
  mutate(cash_at = cheq/atq) %>%
  mutate(intan_at = org_cap_comp/atq,
         intan_cap = org_cap_comp/(org_cap_comp + ppegtq)) %>% 
  group_by(GVKEY) %>%
  mutate(log_cpi = log(CPI)) %>%
  mutate(sales_gr = log(saleq) - log(dplyr::lag(saleq,1))) %>%
  mutate(inv_intan = org_cap_comp - dplyr::lag(org_cap_comp)) %>%
  mutate(inv_tot = capxy + inv_intan) %>%
  mutate(inv_tot_at = inv_tot/atq) %>%
  #mutate(dln_emp = log(emp) - dplyr::lag(log(emp))) %>%
  mutate(ltdebt_issue_at = dltisy/atq,
         bankruptcy = 0,
         bankruptcy = c(bankruptcy[-n()],1),
         cf = (ibq + dpq)/dplyr::lag(ppentq)) %>%
  ungroup() %>%
  group_by(year_q) %>%
  mutate(bankruptcy = ifelse(year_q == 20204,0,bankruptcy))

# data_intan_q_new <- data_intan_q_new[!is.infinite(data_intan_q_new$intan_at) & !is.na(data_intan_q_new$intan_at), ]
# data_intan_q_new <- data_intan_q_new[!is.infinite(data_intan_q_new$intan_cap) & !is.na(data_intan_q_new$intan_cap), ]

# CREATING QUANTILES OF INTANGIBILITY
db_reg <- data_intan_q_new %>%
  group_by(year_q, ff_indust) %>%
  mutate(med = ntile(intan_cap,2)) %>%
  mutate(tercile = ntile(intan_cap,3)) %>%
  mutate(quartile = ntile(intan_cap,4)) %>%
  mutate(quintile = ntile(intan_cap,5)) %>%
  mutate(decile = ntile(intan_cap,10)) %>%
  ungroup() #%>%
  #na.omit() %>%
  #filter_all(all_vars(!is.infinite(.)))


# MERGING WITH THE MONETARY POLICY SHOCKS ####

treas_2y <- read_excel('data/excel/Treasury_2y.xls', sheet = "data")

# 2-year Treasury

treas_2y_sel <- treas_2y %>%
  mutate(quarter = ifelse(month(as.Date(date, format = "%m/%d/%y")) <= 3, 1,
                          ifelse(month(as.Date(date, format = "%m/%d/%y")) > 3 & month(as.Date(date, format = "%m/%d/%Y")) <= 6, 2,
                                 ifelse(month(as.Date(date, format = "%m/%d/%y")) > 6 & month(as.Date(date, format = "%m/%d/%Y")) <= 9, 3, 4))),
         year_q = year(as.Date(date, format = "%m/%d/%y"))*10 + quarter) %>%
  group_by(year_q) %>%
  summarise(treas_2y_q = 100*(exp(mean(log(1+treas_2y/100), na.rm = TRUE))-1)) %>%
  mutate(d_treas_2y_q = 100*(exp(log(1+treas_2y_q/100) - dplyr::lag(log(1+treas_2y_q/100)))-1))


db_reg <- inner_join(db_reg, treas_2y_sel, by = 'year_q')

db_reg <- db_reg %>% group_by(GVKEY, year_q) %>% filter(row_number()==1) #keep just the first observation

# SAVING ####
write.dta(db_reg, "data/dta/db_reg_2yt.dta")
save(db_reg, file = "data/rdata/db_reg_2yt.rdata")