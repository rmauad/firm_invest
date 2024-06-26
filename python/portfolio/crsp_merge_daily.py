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

df_intan = pd.read_csv('data/csv/db_did.csv') # created by prep_db_did.py
compustat_sel = pd.read_csv('data/csv/compustat_sel.csv')
crsp_d = pyreadr.read_r('data/rdata/stoxda_around2000.Rdata')
#print(crsp_d.keys())
crsp_d_df = crsp_d['stoxda_around2000'] # converting the R object to a pandas dataframe

link_permno_gvkey = pd.read_csv('data/csv/link_permno_gvkey.csv')
link_permno_gvkey = link_permno_gvkey.loc[:,['GVKEY', 'LPERMNO']]
link_permno_gvkey_unique = link_permno_gvkey.drop_duplicates()
link_permno_gvkey_renamed = link_permno_gvkey_unique.rename(columns={'LPERMNO': 'PERMNO'})

###################################################################################
# Merging original Compustat with the dataframe with the intangible capital measure
###################################################################################

df_intan_sel = df_intan[['datadate', 'GVKEY',  'org_cap_comp', 'atq']]
df_intan_sel_pre_merge = (df_intan_sel
    .assign(date = pd.to_datetime(df_intan_sel["datadate"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    .assign(day = lambda x: x['date'].dt.day.astype('Int64'))
    .assign(month = lambda x: x['date'].dt.month.astype('Int64'))
    .assign(year = lambda x: x['date'].dt.year.astype('Int64'))
    .assign(GVKEY_date = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
    .query('year >= 1997 and year <= 2005')
    .rename(columns = {'atq': 'atq_intan'})
)
df_intan_sel_pre_merge = df_intan_sel_pre_merge.drop(columns = ['datadate', 'GVKEY', 'date', 'day', 'month', 'year'])


compustat_sel_pre_merge = (compustat_sel
    .assign(date = pd.to_datetime(compustat_sel["datadate"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    .assign(day = lambda x: x['date'].dt.day)
    .assign(month = lambda x: x['date'].dt.month)
    .assign(year = lambda x: x['date'].dt.year)
    .assign(GVKEY_date = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
    .drop(columns = ['datadate'])
)
compustat_sel_pre_merge = compustat_sel_pre_merge[~compustat_sel_pre_merge.duplicated('GVKEY_date', keep='first')]

compust = (pd.merge(compustat_sel_pre_merge, df_intan_sel_pre_merge, how = 'left', on = 'GVKEY_date'))
# compust_no_na = compust.dropna(subset = ['atq_intan'])

###################################################################
# Changing the date on Compustat to merge with CRSP (release date)
###################################################################

compust = compust.drop(columns = ['year', 'month', 'day', 'GVKEY_date'])

compust_pre_merge = (compust
    .assign(rdq = pd.to_datetime(compust["rdq"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    .assign(day = lambda x: x['rdq'].dt.day.astype('Int64'))
    .assign(month = lambda x: x['rdq'].dt.month.astype('Int64'))
    .assign(year = lambda x: x['rdq'].dt.year.astype('Int64'))
    .assign(GVKEY_rdq = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
    .drop(columns = ['GVKEY'])
)

####################
# Merging CRSP data
####################

crsp_d_df_clean = (crsp_d_df
                   .assign(PERMNO = lambda x: x['PERMNO'].astype(int))
                   #.assign(date = lambda x: x['date'].astype(int))
                   )

crsp_d_df_link = (pd.merge(crsp_d_df_clean, link_permno_gvkey_renamed, how = 'left', on = 'PERMNO'))
crsp_d_df_link = (crsp_d_df_link
                  .assign(GVKEY = lambda x: x['GVKEY'].astype('Int64')))

# sample_crsp_d_df_link = crsp_d_df_link.sample(frac = 0.001, random_state = 42)

crsp_d_pre_merge = (crsp_d_df_link
                    .assign(date = pd.to_datetime(crsp_d_df_clean["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
                    .assign(day = lambda x: x['date'].dt.day.astype('Int64'))             
                    .assign(month = lambda x: x['date'].dt.month.astype('Int64'))
                    .assign(year = lambda x: x['date'].dt.year.astype('Int64'))
                    .assign(GVKEY_rdq = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
                    )

crsp_d_pre_merge_no_dup = crsp_d_pre_merge[~crsp_d_pre_merge.duplicated('GVKEY_rdq', keep='first')]
crsp_97 = crsp_d_pre_merge_no_dup.query('year == 1997')
crsp_97 = (crsp_97
           .rename(columns = {'date': 'date_ret'})
           .drop(columns = ['PERMNO', 'day', 'month', 'year']))
compust_97 = compust_pre_merge.query('year == 1997')

crsp_97.head(50)
ccm_97.head(50)
ccm_97 = (pd.merge(crsp_97, compust_97, how = 'left', on = 'GVKEY_rdq'))
# ccm_no_na = ccm.dropna(subset = ['rdq'])
# ccm_no_na.columns
# ccm_no_na = ccm_no_na.drop(columns = ['GVKEY', 'year', 'month', 'day'])
# ccm_no_na.head(50)

# Save dataframe
ccm_97.to_feather('data/feather/ccm_97.feather')

#####################
# Data visualization
#####################

sorted_columns = sorted(df_merge.columns)
print(sorted_columns)
df_intan_sel_pre_merge.shape
compust.shape
crsp_d_df_clean.shape
crsp_d_df_link.shape
crsp_d_df.head(50)
first_occurrence_df['GVKEY_date'].nunique()
duplicates_df = compustat_sel_pre_merge[compustat_sel_pre_merge.duplicated('GVKEY_date', keep=False)]
first_occurrence_df = compustat_sel_pre_merge[~compustat_sel_pre_merge.duplicated('GVKEY_date', keep='first')]
compust_no_na[['GVKEY_date', 'atq', 'atq_intan']].head(50)
first_occurrence_df.shape
compust.shape
duplicates_df.head(50)
compustat_sel_pre_merge[['date', 'GVKEY_date']].head(50)
df_intan_sel_pre_merge['year'].dtype
compustat_sel_pre_merge['year'].dtype
df_intan_sel['atq_intan'].isna().sum()