#Import EU KLEMS
#install.packages("matlab")
library(tidyverse)
library(readxl)
library(reshape2)
library(dplyr)
library(matlab)
#eu_klems <- read_excel("AT_output_17ii.xlsx", sheet = "LP1_Q")

eu_klems <- list() # creates a list
eu_klems_va <- list() # creates a list
eu_klems_emp_h <-list() # creates a list
  
listxlsx <- dir(pattern = "*.xlsx") # creates the list of all the csv files in the directory
for (k in 1:length(listxlsx)){
  eu_klems[[k]] <- read_excel(listxlsx[k], sheet = "LP1_Q")
  eu_klems_va[[k]] <- read_excel(listxlsx[k], sheet = "VA_QI")
  eu_klems_emp_h[[k]] <- read_excel(listxlsx[k], sheet = "H_EMP")
}

#Cleaning the databases
names <- c("AUT",	"BEL",	"CZE",	"DEU",	"DNK",	"ESP",	"EST",	
           "FIN",	"FRA",	"GBR",	"GRC",	"HUN",	"IRL",	"ITA",	
           "LTU",	"LUX",	"LVA",	"NLD",	"POL",	"PRT",	"SVK",	
           "SVN",	"SWE",	"USA")
#eu_klems_comp <- matrix(,ncol = 4)
eu_klems_va_comp <- list()
eu_klems_emp_h_comp <- list()

# Value added ####
for(i in 1:length(names)){ 

va <- melt(eu_klems_va[[i]], id = c("desc", "code"))
va_cur <- va %>% dplyr::select("code", "variable", "value") %>%
  filter(code != "TOT", code != "MARKT", code != "C", code != "G", code != "H", code != "J", code != "O-U", code != "R-S", !is.na(value))

COU <- repmat(names[[i]],length(va_cur[[1]]),1)
va_cur <- cbind(va_cur,COU)
# col_names = list('ind','year','lpg','COU')
# colnames(lp_cur) <- c(col_names)
year <- va_cur[["variable"]]
year <- str_sub(year,-4,-1)
va_cur <- va_cur %>% select(-c(variable)) 
va_cur <- cbind(va_cur,year)
#lp_matrix <- matrix(unlist(lp_cur), ncol = length(lp_cur))
#colnames(lp_matrix) <- col_names
eu_klems_va_comp <- rbind(eu_klems_va_comp, va_cur)
}

eu_klems_va_comp <- eu_klems_va_comp %>%
  rename(va = value, ind = code)

# Hours worked ####
for(i in 1:length(names)){ 
  
  emp <- melt(eu_klems_emp_h[[i]], id = c("desc", "code"))
  emp_cur <- emp %>% dplyr::select("code", "variable", "value") %>%
    filter(code != "TOT", code != "MARKT", code != "C", code != "G", code != "H", code != "J", code != "O-U", code != "R-S", !is.na(value))
  
  COU <- repmat(names[[i]],length(emp_cur[[1]]),1)
  emp_cur <- cbind(emp_cur,COU)
  # col_names = list('ind','year','lpg','COU')
  # colnames(lp_cur) <- c(col_names)
  year <- emp_cur[["variable"]]
  year <- str_sub(year,-4,-1)
  emp_cur <- emp_cur %>% select(-c(variable)) 
  emp_cur <- cbind(emp_cur,year)
  #lp_matrix <- matrix(unlist(lp_cur), ncol = length(lp_cur))
  #colnames(lp_matrix) <- col_names
  eu_klems_emp_h_comp <- rbind(eu_klems_emp_h_comp, emp_cur)
}

eu_klems_emp_h_comp <- eu_klems_emp_h_comp %>%
  rename(emp_h = value, ind = code)

# Merging both
eu_klems_va_comp <- eu_klems_va_comp %>%
  mutate(key = paste(COU, year, ind, sep = "_"))

eu_klems_emp_h_comp <- eu_klems_emp_h_comp %>%
  mutate(key = paste(COU, year, ind, sep = "_"))

euk <- merge(x = eu_klems_va_comp, y = eu_klems_emp_h_comp, by = "key")
euk <- euk %>%   subset(select = -c(key, COU.y, year.y, ind.y)) %>%
  rename(ind = ind.x, COU = COU.x, year = year.x)

#euk <- euk %>% mutate(lp = va/emp_h)

save(euk, file = 'euk.Rdata')
#eu_klems[[1]]