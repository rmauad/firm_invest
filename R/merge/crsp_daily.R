library(arrow)
library(dplyr)
library(lubridate)
library(readr)

load('data/rdata/comp_fundq.Rdata')
load('data/rdata/stoxda_around2000.Rdata')

compustat_sel <- comp_fundq %>%
  select(datadate, rdq, GVKEY, atq, dlcq, dlttq, ceqq) %>%
  mutate(year = year(datadate)) %>%
  filter(year >= 1997 & year <= 2005)
  
#crsp_daily_sel <- stoxda_around2000

write_csv(compustat_sel, 'data/csv/compustat_sel.csv')

