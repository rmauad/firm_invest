import pandas as pd
# import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pyreadr
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from merge_functions import custom_fill
# import sys
# sys.path.append('code/firm_invest/python/psm_did_event/')
# from data_functions import convert_to_datetime

compust_pre_merge = pd.read_feather('data/feather/compust_pre_merge.feather') # from compustat_intan_merge.py 
crsp = pd.read_csv('data/csv/crsp_full.csv')
mkt = pd.read_csv('data/csv/F-F_Research_Data_Factors.CSV')

mkt_rf = mkt[['date', 'Mkt-RF']]
mkt_rf = (mkt_rf
        .assign(date = pd.to_datetime(mkt_rf['date'], format='%Y%m'))
        .assign(year_month = lambda x: x['date'].dt.to_period('M'))
        .rename(columns = {'Mkt-RF': 'mkt_rf'})
        .drop(columns = ['date']))

link_permno_gvkey = pd.read_csv('data/csv/link_permno_gvkey.csv')
link_permno_gvkey = link_permno_gvkey.loc[:,['GVKEY', 'LPERMNO']]
link_permno_gvkey_unique = link_permno_gvkey.drop_duplicates()
link_permno_gvkey_renamed = link_permno_gvkey_unique.rename(columns={'LPERMNO': 'PERMNO'})

####################################################################
# Adapting Compustat (generated for the merge with daily CRSP data) 
# to merge with monthly CRSP data
####################################################################

compust_monthly = (compust_pre_merge
                   #.assign(GVKEY_year_month = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str))
                   .drop(columns = ['year_month', 'GVKEY'])
                   .rename(columns = {'date': 'date_compustat'}))
#compust_monthly.head(50)
####################
# Merging CRSP data
####################
crsp_sel = crsp[['PERMNO', 'date', 'RET', 'PRC', 'SHROUT']]
# crsp_sel.head(50)
crsp_clean = (crsp_sel
                   .assign(PERMNO = lambda x: x['PERMNO'].astype(int))
                   #.assign(date = lambda x: x['date'].astype(int))
                   .assign(date = pd.to_datetime(crsp["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
                   .assign(year_month = lambda x: x['date'].dt.to_period('M'))
                   #.assign(year = lambda x: x['date'].dt.year.astype('Int64'))
                   #.query('1997 <= year <= 2005')
                   )
# crsp_clean.shape
crsp_link = (pd.merge(crsp_clean, link_permno_gvkey_renamed, how = 'left', on = 'PERMNO'))
# crsp_link.shape

# crsp_d_df_link = (crsp_link
#                   .assign(GVKEY = lambda x: x['GVKEY'].astype('Int64')))

# sample_crsp_d_df_link = crsp_d_df_link.sample(frac = 0.001, random_state = 42)
# crsp_link.head(50)

crsp_pre_merge = (crsp_link
                    #.assign(day = lambda x: x['date'].dt.day.astype('Int64'))             
                    #.assign(month = lambda x: x['date'].dt.month.astype('Int64'))
                    .assign(GVKEY = lambda x: x['GVKEY'].astype('Int64'))
                    .assign(GVKEY_year_month = lambda x: x['GVKEY'].astype(str) + '_' + x['year_month'].astype(str))
                    )


crsp_pre_merge = (pd.merge(crsp_pre_merge, mkt_rf, how = 'left', on = 'year_month'))
# crsp_pre_merge.head(50)

crsp_pre_merge_no_dup = crsp_pre_merge[~crsp_pre_merge.duplicated('GVKEY_year_month', keep='first')]
# crsp_pre_merge.shape
# crsp_pre_merge_no_dup.shape

crsp_merge = (crsp_pre_merge_no_dup
           .rename(columns = {'date': 'date_ret'})
           .drop(columns = ['PERMNO']))
# crsp_merge.head(50)
# compust_monthly.head(50)

ccm_monthly = (pd.merge(crsp_merge, compust_monthly, how = 'left', on = 'GVKEY_year_month'))
# ccm_monthly.shape
ccm_monthly_no_dup = ccm_monthly[~ccm_monthly.duplicated('GVKEY_year_month', keep='first')]
# ccm_monthly_no_dup.shape
    
# ccm_monthly.columns
# ccm_monthly.shape
# ccm_monthly_no_dup.head(50)

# ccm_monthly_no_dup.set_index(['GVKEY', 'year_month'], inplace=True)
columns_fill = ['atq', 'ceqq', 'dlttq', 'dlcq', 'niq', 'sic', 'state']

# Fill forward the missing values within each group
ccm_monthly_filled = ccm_monthly_no_dup.copy()
ccm_monthly_filled[columns_fill] = ccm_monthly_filled.groupby('GVKEY')[columns_fill].transform(lambda x: x.ffill())
# ccm_monthly_filled.shape
# ccm_monthly.head(50)
# ccm_monthly_no_dup[['GVKEY', 'year_month', 'atq', 'sic', 'dlttq']][ccm_monthly_no_dup['GVKEY'] == 11217]
# ccm_monthly_filled[['GVKEY', 'year_month', 'atq', 'sic', 'dlttq']][ccm_monthly_filled['GVKEY'] == 11217]

# Save dataframe
ccm_monthly_filled.to_feather('data/feather/ccm_monthly_filled.feather')

#####################
# Data visualization
#####################

# sorted_columns = sorted(df_merge.columns)
# print(sorted_columns)
# df_intan_sel_pre_merge.shape
# compust.shape
# crsp_d_df_clean.shape
# crsp_d_df_link.shape
# crsp_d_df.head(50)
# first_occurrence_df['GVKEY_date'].nunique()
# duplicates_df = compustat_sel_pre_merge[compustat_sel_pre_merge.duplicated('GVKEY_date', keep=False)]
# first_occurrence_df = compustat_sel_pre_merge[~compustat_sel_pre_merge.duplicated('GVKEY_date', keep='first')]
# compust_no_na[['GVKEY_date', 'atq', 'atq_intan']].head(50)
# first_occurrence_df.shape
# compust.shape
# duplicates_df.head(50)
# compustat_sel_pre_merge[['date', 'GVKEY_date']].head(50)
# df_intan_sel_pre_merge['year'].dtype
# compustat_sel_pre_merge['year'].dtype
# df_intan_sel['atq_intan'].isna().sum()