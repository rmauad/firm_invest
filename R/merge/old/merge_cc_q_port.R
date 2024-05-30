# Merging CRSP and Compustat to get the columns EXCHCD and SHRCD

library(tidyr)
library(tidyverse)
library(foreign)
library(plm)
library(quantreg)
library(dplyr)
library(statar)
library(Hmisc)
library(lubridate)
library(purrr)

load('data/rdata/crsp_full.RData')
load('data/rdata/link_cc.RData')
load('data/rdata/comp_fundq.Rdata')

comp_sel_q <- select(comp_fundq, GVKEY, cusip, datadate, fqtr, sic, xsgaq, intanq, atq, ceqq, dlcq, dlttq, ppegtq, revtq, cheq, ltq, cshoq, prccq, saleq, ibq, dpq, ppentq, capxy, pstkq, invtq, xintq, dltisy, txdbq, xrdq)

comp_sel_q <- comp_sel_q %>%
  mutate(gvkey_year_q = as.numeric(GVKEY)*100000 + year(datadate)*10 + fqtr,
         gvkey_year = as.numeric(GVKEY)*10000 + year(datadate))


colnames(link_sel) <- c('GVKEY', 'PERMNO')
crsp_sel_q <- crsp_full %>%
  select(PERMNO, date, SHRCD, EXCHCD, PRC)
  
crsp_sel_q <- crsp_sel_q %>%
  mutate(month = floor((date - floor(date/10000)*10000)/100)) %>%
  filter(month == 3 | month == 6 | month == 9 | month == 12) %>%
  mutate(quarter = ifelse(month == 3, 1,
                          ifelse(month == 6, 2,
                                 ifelse(month == 9, 3, 4)))) %>%
  inner_join(link_sel, by = 'PERMNO')



crsp_sel_q <- crsp_sel_q %>% 
  mutate(gvkey_year_q = GVKEY*100000 + floor(date/10000)*10 + quarter,
         year_q = floor(date/10000)*10 + quarter) %>%
  select(gvkey_year_q, SHRCD, EXCHCD, PRC, year_q)

ccm_q <- inner_join(comp_sel_q, crsp_sel_q, by = 'gvkey_year_q')


#save(link_sel, file = "link_cc.RData")
#save(crsp_full, file = "crsp_full.RData")
save(ccm_q, file = "data/rdata/ccm_q.RData")
write.csv(comp_fundq, "data/csv/comp_fundq.csv")

