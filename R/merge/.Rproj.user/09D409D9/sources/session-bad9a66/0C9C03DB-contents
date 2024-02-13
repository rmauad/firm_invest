# Merging CRSP and Compustat to get the columns EXCHCD and SHRCD

library(tidyr)
library(tidyverse)
library(foreign)
library(plm)
library(quantreg)
library(stargazer)
library(dplyr)
library(statar)
library(Hmisc)
library(lubridate)

load('data/rdata/crsp_full.RData')
load('data/rdata/link_cc.RData')
#load('data/rdata/ipo_dates.RData')
load('data/rdata/comp_fundq.Rdata')
load('data/rdata/comp_funda2.Rdata') #loading the annual database to merge with quarterly database and include employment in the quarterly frequency.
#DON'T FORGET TO LOAD THE LINK FILE ON ICLOUD AS WELL


## COMMENT THIS OUT AFTER MERGING WITH ANNUAL DATABASE TO INCLUDE EMP ##
########################################################################
comp_funda2_sel <- comp_funda2 %>%
  mutate(year = year(ymd(datadate)),
         gvkey_year = as.numeric(GVKEY)*10000 + year) %>%
  select(gvkey_year, emp)
########################################################################


macro_q <- read.table("data/csv/Macro_controls_q.csv",sep = ",",header = TRUE)

#comp_sel <- select(comp_funda2, GVKEY, cusip, datadate, fyr, sic, xsga, intan, at, ceq, dlc, dltt, ppegt, revt, che, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xintd, xint, fatb)
comp_sel_q <- select(comp_fundq, GVKEY, cusip, datadate, fqtr, sic, xsgaq, intanq, atq, ceqq, dlcq, dlttq, ppegtq, revtq, cheq, ltq, cshoq, prccq, saleq, ibq, dpq, ppentq, capxy, pstkq, invtq, xintq, dltisy, txdbq)

comp_sel_q <- comp_sel_q %>%
  mutate(gvkey_year_q = as.numeric(GVKEY)*1000000 + year(datadate)*10 + fqtr,
         gvkey_year = as.numeric(GVKEY)*10000 + year(datadate))


## COMMENT THIS OUT AFTER MERGING WITH ANNUAL DATABASE TO INCLUDE EMP ##
########################################################################
comp_sel_q <- inner_join(comp_sel_q, comp_funda2_sel, by = 'gvkey_year')
########################################################################

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
  mutate(gvkey_year_q = GVKEY*1000000 + floor(date/10000)*10 + quarter,
         year_q = floor(date/10000)*10 + quarter) %>%
  select(gvkey_year_q, SHRCD, EXCHCD, PRC, year_q)

ccm_q <- inner_join(comp_sel_q, crsp_sel_q, by = 'gvkey_year_q')

macro_q <- macro_q %>%
  mutate(quarter = ifelse(month(DATE) == 1,1,
                          ifelse(month(DATE) == 4,2,
                                 ifelse(month(DATE) == 7,3,4))),
         year_q = year(DATE)*10 + quarter)
        

ccm_macro_q <- inner_join(ccm_q, macro_q, by = 'year_q')
#save(link_sel, file = "link_cc.RData")
#save(crsp_full, file = "crsp_full.RData")
save(ccm_macro_q, file = "data/rdata/ccm_q.RData")
