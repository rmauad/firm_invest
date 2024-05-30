## This code replicates Eisfeldt and Papanikolaou (2013) in calculating intangible capital from SG&A.

library(stats)
library(tidyverse)
library(lubridate)
library(ggplot2)
library(reshape2)
library(dplyr)
library(readxl)

load('data/rdata/ccm.RData')
cpi <- read_xls("data/excel/CPI.xls", sheet = "data")
cpi <- cpi %>%
  mutate(date = year(ymd(date))) %>%
  rename(year = date)
  

init <- 1970
end_sample <- 2008
#Couldn't select columns shrcd and exchcd (any other name for these columns?)
# cpi = read.table("cpi_1960.csv",sep = ",",header = TRUE)
# 
# cpi <- cpi %>% mutate(year = year(DATE)) %>%
#   mutate(cpi = FPCPITOTLZGUSA) %>%
#   select(year, cpi) %>%
#   filter(year >= init & year <= end_sample)
# source("index.R")
# 
# cpi_ind = cpi %>% mutate(cpi_aux = (1+cpi/100)) %>%
#   select(year, cpi_aux)
# cpi_index = index(cpi)

#Treating the database and calculating the growth of SG&A by firm

data_new <- ccm_macro %>% mutate(GVKEY = floor(gvkey_year/10000)) %>%
  mutate(year = gvkey_year - GVKEY*10000) %>%
  filter(year >= init & year <= end_sample,fyr == 12, !(sic >= 6000 & sic <= 6799), !is.na(sic), SHRCD == 10 | SHRCD == 11, EXCHCD == 1 | EXCHCD == 2 | EXCHCD ==  3) %>%#filtering as in the data construction appendix of EPK 2013, but I do not filter out firms with fiscal year ending in December fyr == 12
  
# data_new <- merge(data, cpi_index, by = "year") %>%
  #mutate(real_sga = xsga/cum_index) %>%
 # mutate(real_sga = xsga) %>%
  group_by(GVKEY) %>%
  mutate(diff_sga = xsga - dplyr::lag(xsga)) %>%
  mutate(perc_gr = diff_sga/dplyr::lag(xsga)) %>%
  mutate(perc_gr_clean = perc_gr)

data_new <- inner_join(data_new, cpi, by = "year")

  data_new$perc_gr_clean[is.infinite(data_new$perc_gr_clean)] <- NA

  

sga_avr_gr <- mean(data_new$perc_gr_clean, na.rm = TRUE)
sga_avr_gr <- 0.1
#delta_init <- 0.20
delta_init <- 0.20

#Calculating organization capital like EPK, but in nominal terms

source("code/R/merge/org_init.R")
source("code/R/merge/org_cap_ar.R")
source("code/R/prep_dta/ff_5ind.R")
data_new <- data_new %>% group_by(GVKEY) %>%
  filter(!is.na(xsga)) %>%
  #mutate(sga = coalesce(xsga,0)) %>% #replacing NAs with zeros
  mutate(org_cap = org_init(xsga, delta_init, sga_avr_gr),
         org_cap_comp = org_cap_ar(org_cap, xsga, cpi, delta_init),
         ff_5ind = ff_5ind(sic))
  
  data_intan <- data_new %>% #select(GVKEY, cusip, year, sic, xsga, sga, intan, at, ceq, dlc, dltt, ppegt, revt, che, org_cap_comp, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xint, CPI, GDP, Ind_prod, fatb) %>%
  filter(org_cap_comp > 0) #%>%
  #mutate(Founding = ifelse(Founding <=0, NA, Founding))
  
#write.csv(data_intan, file = "data_intan_mar25.csv")
#save(data_intan, file = "data/rdata/intan_epk.RData")
  



