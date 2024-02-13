# This code uses the database from Compustat including intangible capital calculated in intan_epk_v2.R.
# I adjust the buildings at cost by inflation as in Chaney et al. (AER, 2012)
library(tidyverse)
library(lubridate)
library(dplyr)


load('intan_epk.RData')
cpi_h <- read.table("CPIHOSSL.csv",sep = ",",header = TRUE)
cpi <- read.table("CPIAUCSL.csv", sep = ",", header = TRUE)
cpi <- full_join(cpi, cpi_h, by = "DATE")

#Use CPI until Jan 1967, and then use CPI housing (that's when CPI housing becomes available)
cpi <- cpi %>%
  rename(date = DATE, cpi = CPIAUCSL, cpi_h = CPIHOSSL) %>%
  mutate(cpi = ifelse(date <= "1967-01-01", cpi, dplyr::lag(cpi)*(cpi_h/dplyr::lag(cpi_h))),
         month = month(date),
         year = year(date),
         cpi_aux = exp(cumsum(coalesce(log(cpi/dplyr::lag(cpi)),0)))) %>%
  filter(month == 12) %>%
  mutate(cpi_year = cpi_aux/dplyr::lag(cpi_aux)) %>%
  select(year, cpi_year)

data_intan <- left_join(data_intan, cpi, by = "year")
  

# THIS MARKET VALUE OF BUILDINGS IS INCOMPLETE. CHECK THE BEST WAY TO DO THIS.
data_intan <- data_intan %>%
  group_by(GVKEY) %>%
  mutate(capx_ppe = capx/dplyr::lag(ppent),
         mb = (csho*prcc_c + at - ceq - txdb)/at,
         cf = (ib + dp)/dplyr::lag(ppent),
         dep_hv = dpacb/fatb, #depreciation historic value
         dep_hv = ifelse(dep_hv >=1, 1, dep_hv),
         age = 40*dep_hv, #based on a 40-year depreciable life
         mvb = fatb*cumsum(log(cpi_year))) #market value of buildings 

  
  
  