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

load('data/rdata/comp_funda2.RData')
load('data/rdata/crsp_full.RData')
load('data/rdata/link_cc.RData')
load('data/rdata/ipo_dates.RData')
#DON'T FORGET TO LOAD THE LINK FILE ON ICLOUD AS WELL

#Compustat
#comp_full <- read.table("CRSP-Compustat Merged-Fundamentals-Annual-qtly.csv",sep = ",",header = TRUE)
macro <- read.table("data/csv/Macro_controls.csv",sep = ",",header = TRUE)
#comp_sel <- select(comp_funda2, GVKEY, cusip, datadate, fyr, sic, xsga, intan, at, ceq, dlc, dltt, ppegt, revt, che, lt, csho, prcc_f, sale, ib, dp, ppent, capx, pstkl, invt, emp, xintd, xint, fatb)
comp_sel <- comp_funda2
comp_sel <- comp_sel %>%
  mutate(gvkey_year = as.numeric(GVKEY)*10000 + floor(datadate/10000)) %>%
  mutate(year = floor(datadate/10000))
  #subset(select = -c(GVKEY, datadate))

# comp_sel <- select(comp_full, GVKEY, datadate, fyr, sic, xsga, intan, at, ceq, dlc, dltt, ppegt, revt, che)
# comp_sel <- comp_sel %>%
#   mutate(gvkey_year = as.numeric(GVKEY)*10000 + floor(datadate/10000)) %>%
#   subset(select = -c(GVKEY, datadate))

#save(comp_sel, file = "comp_sel.RData")

#CRSP
#crsp_full <- read.table("CRSP Monthly Stock.csv",sep = ",",header = TRUE)
link <- read.csv(file = "data/csv/link_permno_gvkey.csv",sep = ",", header = TRUE)[,1:2]
link_sel <- link[!duplicated(link$GVKEY), ]
colnames(link_sel) <- c('GVKEY', 'PERMNO')
crsp_sel <- crsp_full %>%
  select(PERMNO, date, SHRCD, EXCHCD, PRC)
# ipo_dates <- ipo_dates %>%
#   rename(PERMNO = "CRSP permanent ID")
# permno <- as.numeric(unlist(ipo_dates$PERMNO))
# ipo_dates <- cbind(permno, ipo_dates)
# ipo_dates <- ipo_dates %>%
#   select(permno, Founding) %>%
#   rename(PERMNO = permno)

# crsp_sel <- crsp_sel %>%
#   inner_join(ipo_dates, by = 'PERMNO')
  
crsp_sel <- crsp_sel %>%
  mutate(month = floor((date - floor(date/10000)*10000)/100)) %>%
  filter(month == 12) %>%
  inner_join(link_sel, by = 'PERMNO')

crsp_sel <- crsp_sel %>% 
  mutate(gvkey_year = GVKEY*10000 + floor(date/10000)) %>%
  select(gvkey_year, SHRCD, EXCHCD, PRC)

ccm <- inner_join(comp_sel, crsp_sel, by = 'gvkey_year')

ccm_macro <- inner_join(ccm, macro, by = 'year')
#save(link_sel, file = "link_cc.RData")
#save(crsp_full, file = "crsp_full.RData")
#save(ccm_macro, file = "data/rdata/ccm.RData")
