import pandas as pd
import numpy as np
# import os
# print(os.getcwd())

##################################
# Loading and importing dataframes (import one at a time)
##################################

compustat = pd.read_feather("data/feather/comp_fundq.feather")
crsp = pd.read_feather('data/feather/crsp_full.feather')
link_cc = pd.read_feather('data/feather/link_cc.feather')

##################################
# Selecting and treating variables
##################################

# Compustat
comp_sel_q = compustat[['GVKEY', 'rdq', 'datadate', 'sic', 'xsgaq', 
                   'atq', 'ceqq', 'dlcq', 'dlttq', 
                   'ppegtq', 'ppentq', 'cheq',
                   'saleq', 'capxy', 'state', 'fyr']]

comp_sel_q = (comp_sel_q
              .assign(rdq = pd.to_datetime(compustat['rdq']))
              .assign(year_month=lambda x: x['rdq'].dt.to_period('M'))
              .assign(year=lambda x: x['rdq'].dt.year)
              .assign(GVKEY = lambda x: x['GVKEY'].astype(int))
              .assign(fyr = lambda x: x['fyr'].astype(int))
              .query('year >= 1970 and fyr == 12')
)

# CRSP
crsp['date'] = pd.to_datetime(crsp['date'], format='%Y%m%d', errors='coerce')
crsp_sel_q = crsp[['PERMNO', 'date', 'SHRCD', 'EXCHCD']]

crsp_sel_q = (crsp_sel_q
              .assign(year_month=lambda x: x['date'].dt.to_period('M'))
              .rename(columns={'date': 'date_ret'})
)

link_cc = link_cc.rename(columns={'LPERMNO': 'PERMNO'})
crsp_link = pd.merge(crsp_sel_q, link_cc, on='PERMNO', how='inner')

# Merge with compustat
ccm_q = pd.merge(comp_sel_q, crsp_link, on=['GVKEY', 'year_month'], how='left')

ccm_q_no_dup = (ccm_q
            .drop_duplicates(subset=['GVKEY', 'year_month'])
            .drop(columns=['PERMNO'])
    )

ccm_q_no_dup.to_feather('data/feather/ccm_q_lev.feather')
