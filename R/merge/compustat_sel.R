# Compustat selected

library(dplyr)
library(lubridate)

load('data/rdata/comp_fundq.Rdata')

compustat_sel <- comp_fundq %>%
  select(datadate, rdq, GVKEY, sic, atq, dlcq, dlttq, ceqq, state, niq, loq)

write.csv(compustat_sel, file = 'data/csv/compustat_sel.csv', row.names = FALSE)
