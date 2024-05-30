## This code replicates Eisfeldt and Papanikolaou (2013) in calculating intangible capital from SG&A.

library(stats)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(reshape2)
library(dplyr)
library(readxl)

load('data/rdata/ccm_q.RData')

cpi <- read_xls("data/excel/CPI.xls", sheet = "data")
cpi <- cpi %>%
  mutate(date = year(ymd(date))) %>%
  rename(year = date)

init <- 1975
end_sample <- 2020

#Treating the database and calculating the growth of SG&A by firm

data_new <- ccm_macro_q %>% 
  mutate(GVKEY = floor(gvkey_year_q/100000),
         year = floor(year_q/10)) %>%
  filter(year >= init & year <= end_sample, !(sic >= 6000 & sic <= 6799), !is.na(sic), SHRCD == 10 | SHRCD == 11, EXCHCD == 1 | EXCHCD == 2 | EXCHCD ==  3) %>%#filtering as in the data construction appendix of EPK 2013
  group_by(GVKEY) %>%
  mutate(diff_sgaq = xsgaq - dplyr::lag(xsgaq),
         perc_gr = diff_sgaq/dplyr::lag(xsgaq),
         perc_gr_clean = perc_gr)

  data_new$perc_gr_clean[is.infinite(data_new$perc_gr_clean)] <- NA

data_new <- inner_join(data_new, cpi, by = 'year')

sga_avr_gr <- mean(data_new$perc_gr_clean, na.rm = TRUE)
#sga_avr_gr <- 0.1
#delta_init <- 0.20
delta_init <- 0.15

#Calculating organization capital like EPK, but in nominal terms

source("code/R/merge/org_init.R")
source("code/R/merge/org_cap_ar.R")
data_new <- data_new %>% group_by(GVKEY) %>%
  mutate(sga = 0.3*coalesce(xsgaq,0),#30% of SG&A is considered to be investment in intangible capital
         org_cap = org_init(sga, delta_init, sga_avr_gr),
        org_cap_comp = org_cap_ar(org_cap, sga, cpi, delta_init))
  
  data_intan_q <- data_new %>% #select(GVKEY, cusip, year, sic, xsga, sga, intan, at, ceq, dlc, dltt, ppegt, revt, che, org_cap_comp, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xint, CPI, GDP, Ind_prod, fatb) %>%
  filter(org_cap_comp > 0)
  
# Check intangible capital measure - FIX THIS MEASURE
  
  plot_data <- data_intan_q %>% 
    group_by(year) %>%
    summarise(total_ok = sum(org_cap_comp),
           total_ppent = sum(ppentq, na.rm = TRUE)) %>%
   mutate(plot_series = (total_ok/total_ppent)/0.06855837)
  
plot(plot_data$year, plot_data$plot_series, type = "l")
#write.csv(data_intan, file = "data_intan_mar25.csv")
#save(data_intan_q, file = "data/rdata/intan_epk_q.RData")
  



