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
macro_q = pd.read_csv('data/csv/Macro_controls_q.csv')

##################################
# Selecting and treating variables
##################################

# Compustat
compustat['datadate'] = pd.to_datetime(compustat['datadate'])
comp_sel_q = (
    compustat
    .filter(items=['GVKEY', 'datadate', 'fqtr', 'sic', 'xsgaq', 
                   'atq', 'ceqq', 'dlcq', 'dlttq', 
                   'ppegtq', 'ppentq', 'cheq',
                   'saleq', 'capxy', 'state'])
    .assign(
        gvkey_year_q=lambda x: x['GVKEY'].astype(int) * 100000 + x['datadate'].dt.year * 10 + x['fqtr'],
        gvkey_year=lambda x: x['GVKEY'].astype(int) * 10000 + x['datadate'].dt.year
    )
)


# CRSP-Compustat link
link_cc = link_cc.rename(columns={'LPERMNO': 'PERMNO'})

# CRSP
crsp['date'] = pd.to_datetime(crsp['date'], format='%Y%m%d')
crsp_sel_q = crsp[['PERMNO', 'date', 'SHRCD', 'EXCHCD']]
crsp_sel_q = crsp_sel_q.assign(
    month=lambda x: x['date'].dt.month
)

# Filtering rows where month is March, June, September, or December
crsp_sel_q = crsp_sel_q[crsp_sel_q['month'].isin([3, 6, 9, 12])]

# Creating 'quarter' column based on 'month'
crsp_sel_q = crsp_sel_q.assign(
    quarter=lambda x: np.select(
        [x['month'] == 3, x['month'] == 6, x['month'] == 9, x['month'] == 12],
        [1, 2, 3, 4],
        default=0  # Default can actually never be hit because of the filter above
    )
)

# Joining with link_sel DataFrame
crsp_sel_q = pd.merge(crsp_sel_q, link_cc, on='PERMNO')

# More mutations
crsp_sel_q = crsp_sel_q.assign(
    gvkey_year_q=lambda x: (x['GVKEY'].astype(int) * 100000 + x['date'].dt.year * 10 + x['quarter']).astype('float64'),
    year_q=lambda x: x['date'].dt.year * 10 + x['quarter']
)

# Final selection of columns
crsp_sel_q = crsp_sel_q[['gvkey_year_q', 'SHRCD', 'EXCHCD', 'year_q']]

# Show the result
print(crsp_sel_q.head())
crsp_sel_q.shape

# Merge with compustat
ccm_q = pd.merge(comp_sel_q, crsp_sel_q, on='gvkey_year_q', how='inner')

#############################
# Macro variables for control
##############################

macro_q['DATE'] = pd.to_datetime(macro_q['DATE'])

# Use .assign() to create all columns in one go
macro_q = macro_q.assign(
    quarter=lambda x: np.select(
        [x['DATE'].dt.month == 1, x['DATE'].dt.month == 4, x['DATE'].dt.month == 7, x['DATE'].dt.month == 10],
        [1, 2, 3, 4],
        default=4  # Handles other months for the 4th quarter - shouldn't be any
    ),
    year_q=lambda x: x['DATE'].dt.year * 10 + x['quarter'],
    dln_RGDP=lambda x: np.log(x['RGDP']) - np.log(x['RGDP'].shift(1)),
    d_Ind_prod=lambda x: x['Ind_prod'] / (x['Ind_prod'].shift(1) * 100)
).pipe(lambda x: x.assign(
    year_q=lambda x: x['DATE'].dt.year * 10 + x['quarter']
))

ccm_macro_q = pd.merge(ccm_q, macro_q, on='year_q', how='inner')
ccm_macro_q = ccm_macro_q.assign(
    GVKEY=lambda x: pd.to_numeric(x['GVKEY'], errors='coerce')
)

# Drop the 'DATE' column and rename datadate to 'date'
ccm_macro_q = ccm_macro_q.drop(columns='DATE')
ccm_macro_q = ccm_macro_q.rename(columns={'datadate': 'date'})

ccm_macro_q.to_feather("data/feather/ccm_q.feather")

##########################
# Visualize the DataFrame
##########################
ccm_macro_q.shape
macro_q.shape
ccm_q.shape
comp_sel_q.shape
crsp_sel_q.shape
# How many missing values in gvkey_year_q?
comp_sel_q['gvkey_year_q'].isna().sum()
crsp_sel_q['gvkey_year_q'].isna().sum()
crsp_sel_q['gvkey_year_q'].head()
comp_sel_q['gvkey_year_q'].head()

# find the type of gvkey_year_q
comp_sel_q['gvkey_year_q'].dtype
crsp_sel_q['gvkey_year_q'].dtype
ccm_macro_q['GVKEY'].dtype

# number of firms
compustat['GVKEY'].nunique()
ccm_macro_q['GVKEY'].nunique()