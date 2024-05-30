# Merging CRSP and Compustat to get the columns EXCHCD and SHRCD

# library(tidyr)
# library(tidyverse)
# library(foreign)
# library(plm)
# library(quantreg)
# library(stargazer)
library(dplyr)
# library(statar)
# library(Hmisc)
library(lubridate)
# library(purrr)

##################################
# Loading and importing databases
##################################

load('data/rdata/crsp_full.RData') # original monthly CRSP
load('data/rdata/link_cc.RData') #link between CRSP and Compustat
load('data/rdata/comp_fundq.Rdata') # original quarterly Compustat
macro_q <- read.table("data/csv/Macro_controls_q.csv",sep = ",",header = TRUE)

##################################
# Selecting and treating variables
##################################

# Compustat
comp_sel_q <- comp_fundq %>% 
  select(GVKEY, datadate, fqtr, sic, xsgaq, 
                     atq, ceqq, dlcq, dlttq, 
                     ppegtq, ppentq, cheq,
                     saleq, capxy, state) %>%
  mutate(gvkey_year_q = as.numeric(GVKEY)*100000 + year(datadate)*10 + fqtr,
         gvkey_year = as.numeric(GVKEY)*10000 + year(datadate))
  
# CRSP-Compustat link
link_sel <- link_sel %>%
  rename(PERMNO = LPERMNO)
  
# CRSP
crsp_sel_q <- crsp_full %>%
  select(PERMNO, date, SHRCD, EXCHCD) %>%
  mutate(month = floor((date - floor(date/10000)*10000)/100)) %>%
  filter(month == 3 | month == 6 | month == 9 | month == 12) %>%
  mutate(quarter = ifelse(month == 3, 1,
                          ifelse(month == 6, 2,
                                 ifelse(month == 9, 3, 4)))) %>%
  inner_join(link_sel, by = 'PERMNO') %>%
  mutate(gvkey_year_q = GVKEY*100000 + floor(date/10000)*10 + quarter,
         year_q = floor(date/10000)*10 + quarter) %>%
  select(gvkey_year_q, SHRCD, EXCHCD, year_q)

# Converting to integers, not double (float)
comp_sel_q$gvkey_year_q <- as.double(comp_sel_q$gvkey_year_q)
crsp_sel_q$gvkey_year_q <- as.double(crsp_sel_q$gvkey_year_q)

# Merge CRSP and Compustat at the quarterly frequency
ccm_q <- inner_join(comp_sel_q, crsp_sel_q, by = 'gvkey_year_q')

# Macro variables
macro_q <- macro_q %>%
  mutate(quarter = ifelse(month(DATE) == 1,1,
                          ifelse(month(DATE) == 4,2,
                                 ifelse(month(DATE) == 7,3,4))),
         year_q = year(DATE)*10 + quarter) %>%
  mutate(dln_RGDP = log(RGDP) - dplyr::lag(log(RGDP)),
         d_Ind_prod = Ind_prod/(dplyr::lag(Ind_prod)*100))

ccm_macro_q <- inner_join(ccm_q, macro_q, by = 'year_q') %>%
  mutate(GVKEY = as.numeric(GVKEY))


# Saving the database
save(ccm_macro_q, file = "data/rdata/ccm_q.RData")

