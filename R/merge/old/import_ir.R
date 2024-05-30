library(tidyverse)
library(dplyr)
library(lubridate)

ir_2y <- read.table("data/csv/RIFLGFCY02NA.csv",sep = ",",header = TRUE)
ir_10y <- read.table("data/csv/RIFLGFCY10NA.csv",sep = ",",header = TRUE)

ir <- inner_join(ir_10y, ir_2y, by = "DATE")

ir <- ir %>% rename(ir_10y = RIFLGFCY10NA, ir_2y = RIFLGFCY02NA) %>%
  mutate(ir_diff_10y_2y = ((1+ir_10y/100)/(1+ir_2y/100)-1)*100,
         ir_diff_delta = ((1+ir_diff_10y_2y/100)/(1+dplyr::lag(ir_diff_10y_2y/100))-1)*100,
         year = year(DATE)) %>%
  select(year, ir_diff_10y_2y, ir_diff_delta)
  

save(ir, file = 'data/rdata/ir.Rdata')
  
