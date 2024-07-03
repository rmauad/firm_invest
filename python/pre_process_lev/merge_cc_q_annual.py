import pandas as pd
import numpy as np
import pyreadr
# import os
# print(os.getcwd())

##################################
# Loading and importing dataframes (import one at a time)
##################################

compustat = pyreadr.read_r('data/rdata/comp_funda2.Rdata')
# print(compustat.keys())
comp_annual = compustat['comp_funda2'] # converting the R object to a pandas dataframe
crsp = pd.read_feather('data/feather/crsp_full.feather')
link_cc = pd.read_feather('data/feather/link_cc.feather')

##################################
# Selecting and treating variables
##################################
filtered = comp_annual[comp_annual['rdp'].notna()]['rdp'].head(50)
filtered = comp_annual.dropna(subset=['rdipd'])['rdipd']
print(filtered)
# Compustat
comp_sel_q = comp_annual[['GVKEY', 'rdp', 'datadate', 'sic', 'xsga', 
                   'at', 'ceq', 'dlc', 'dltt', 
                   'ppegt', 'ppent', 'che',
                   'sale', 'capxy', 'state', 'fyr']]
sorted_columns = sorted(comp_annual.columns)
print(sorted_columns)
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
