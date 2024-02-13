#Analyzing number of firms in the database

load('data/rdata/db_reg.RData')
load('data/rdata/comp_funda2.RData')
load('data/rdata/intan_epk.RData')
load('data/rdata/ccm.RData')



a <- unique(db_reg$GVKEY)
comp_funda2_sel <- comp_funda2 %>% filter(fyear >= 1990)
comp_funda2_sel <- comp_funda2_sel %>% mutate(GVKEY_num = as.numeric(GVKEY))
b <- unique(comp_funda2_sel$GVKEY_num)
c <- unique(data_intan$GVKEY)

ccm_macro_sel <- ccm_macro %>% filter(fyear >= 1990)
ccm_macro_sel <- ccm_macro_sel %>% mutate(GVKEY_num = as.numeric(GVKEY))

d <- unique(ccm_macro_sel$GVKEY_num)

ccm_macro_sel <- ccm_macro %>% filter(fyear >= 1990)
ccm_macro_sel <- ccm_macro_sel %>% mutate(GVKEY_num = as.numeric(GVKEY))

d <- unique(ccm_macro_sel$GVKEY_num)