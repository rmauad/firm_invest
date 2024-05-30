library(tidyr)
library(tidyverse)
library(foreign)
library(plm)
library(quantreg)
library(stargazer)
library(dplyr)
library(statar)
library(Hmisc)
library(readxl)


ipo_dates <- read_excel("IPO-age.xlsx")
ipo_dates <- ipo_dates %>% select("CRSP permanent ID", "Founding") %>%
  na.omit()
save(ipo_dates, file = "ipo_dates.Rdata")