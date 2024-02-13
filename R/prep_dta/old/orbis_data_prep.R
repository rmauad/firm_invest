# Code to run on the ORBIS database.
# This code tests whether intangible-intensive firms in ORBIS are more financially constrained than traditional companies.

# Following Altamonte et al. (2021) - Markups, intangible capital and heterogeneous financial frictions. - I measure intangible capital as the firms' total fixed costs.
# SG&A is not available in the ORBIS database.

library(tidyverse)
library(dplyr)
library(foreign)

source('ff_ind.R')

# assuming the database is called orbis

db_reg <- orbis %>%
  filter(cnty == USA) %>%
  mutate(intan = netsales - operatingplebit, #intan is equal to fixed costs, which is FC = net revenue - operating profit.
         intan_at = intan/totalassets,
         inv_at = investmentnet/totalassets,
         ccre_ppe = buildings/netpropertyplantequipment,
         ff_indust = sapply(ussicprimarycodes,ff_ind)) %>%
  group_by(year & ff_indust) %>%
  mutate(med = ntile(intan_at,2),
         tercile = ntile(intan_at,3),
         quartile = ntile(intan_at,4),
         quintile = ntile(intan_at,5),
         decile = ntile(intan_at,10),
         d_med_only_1989 = ifelse(med == 2 & year == 1989, 1, 0),
         d_terc_only_1989 = ifelse(tercile == 3 & year == 1989, 1, 0),
         d_quar_only_1989 = ifelse(quartile == 4 & year == 1989, 1, 0),
         d_quin_only_1989 = ifelse(quintile == 5 & year == 1989, 1, 0),
         d_dec_only_1989 = ifelse(decile == 10 & year == 1989, 1, 0),
         med_only_1989 = ifelse(year == 1989, med, 0),
         terc_only_1989 = ifelse(year == 1989, tercile, 0),
         quar_only_1989 = ifelse(year == 1989, quartile, 0),
         quin_only_1989 = ifelse(year == 1989, quintile, 0),
         dec_only_1989 = ifelse(year == 1989, decile, 0),
         d_2terc_only_1989 = ifelse(tercile == 2 | tercile == 3 & year == 1989, 1, 0),
         d_3quar_only_1989 = ifelse(quartile == 2 | quartile == 3 | quartile == 4 & year == 1989, 1, 0),
         d_2quin_only_1989 = ifelse(quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_3quin_only_1989 = ifelse(quintile == 3 | quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_4quin_only_1989 = ifelse(quintile == 2 | quintile == 3 | quintile == 4 | quintile == 5 & year == 1989, 1, 0),
         d_2dec_only_1989 = ifelse(decile == 9 | decile == 10 & year == 1989, 1, 0)) %>%
  ungroup()

d_1989 <- db_reg %>% filter(year == 1989) %>%
  select(GVKEY, med_only_1989, terc_only_1989, quar_only_1989, quin_only_1989, dec_only_1989,
         d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989,
         d_2terc_only_1989, d_3quar_only_1989, d_2quin_only_1989, d_3quin_only_1989, d_4quin_only_1989, d_2dec_only_1989) %>%
  rename(med_1989 = med_only_1989, terc_1989 = terc_only_1989, quar_1989 = quar_only_1989, quin_1989 = quin_only_1989, dec_1989 = dec_only_1989,
         d_med_1989 = d_med_only_1989, d_terc_1989 = d_terc_only_1989, d_quar_1989 = d_quar_only_1989, d_quin_1989 = d_quin_only_1989, d_dec_1989 = d_dec_only_1989,
         d_2terc_1989 = d_2terc_only_1989, d_3quar_1989 = d_3quar_only_1989, d_2quin_1989 = d_2quin_only_1989, d_3quin_1989 = d_3quin_only_1989, d_4quin_1989 = d_4quin_only_1989, d_2dec_1989 = d_2dec_only_1989)

db_reg_1989 <- left_join(d_1989, db_reg, by = "ussicprimarycodes")

write.dta(db_reg_1989, "db_reg_1989_only.dta") #only firms in 1989

