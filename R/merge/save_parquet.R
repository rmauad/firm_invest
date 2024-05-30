# Saving files to transfer to Python
#install.packages('feather')
#library(arrow)
library(feather)

load('data/rdata/crsp_full.RData') # original monthly CRSP
load('data/rdata/comp_fundq.Rdata') # original quarterly Compustat
load('data/rdata/link_cc.Rdata') # CRSP-Compustat link

write_feather(comp_fundq, "data/feather/comp_fundq.feather")
write_feather(crsp_full, "data/feather/crsp_full.feather")
write_feather(link_sel, "data/feather/link_cc.feather")