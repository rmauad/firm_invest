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
compustat_sel = pd.read_csv('data/csv/compustat_sel.csv') # from compustat_sel.R

###################################################################################
# Merging original Compustat with the dataframe with the intangible capital measure
###################################################################################

df_intan_sel = df_intan[['datadate', 'GVKEY',  'org_cap_comp', 'atq']]

df_intan_sel_pre_merge = (df_intan_sel
    .assign(date = pd.to_datetime(df_intan_sel["datadate"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    # .assign(day = lambda x: x['date'].dt.day.astype('Int64'))
    # .assign(month = lambda x: x['date'].dt.month.astype('Int64'))
    # .assign(year = lambda x: x['date'].dt.year.astype('Int64'))
    .assign(year_quarter = lambda x: x['date'].dt.to_period('Q'))
    #.assign(GVKEY_quarter = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
    .assign(GVKEY_year_quarter = lambda x: x['GVKEY'].astype(str) + '_' + x['year_quarter'].astype(str))
    #.query('year >= 1997 and year <= 2005')
    .rename(columns = {'atq': 'atq_intan'})
)
# df_intan_sel.head(50)
#df_intan_sel_pre_merge.head(50)

df_intan_sel_pre_merge = df_intan_sel_pre_merge.drop(columns = ['datadate', 'GVKEY', 'date', 'year_quarter'])

compustat_sel_pre_merge = (compustat_sel
    .assign(date = pd.to_datetime(compustat_sel["datadate"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    # .assign(day = lambda x: x['date'].dt.day)
    # .assign(month = lambda x: x['date'].dt.month)
    # .assign(year = lambda x: x['date'].dt.year)
    .assign(year_quarter = lambda x: x['date'].dt.to_period('Q'))
    .assign(GVKEY_year_quarter = lambda x: x['GVKEY'].astype(str) + '_' + x['year_quarter'].astype(str))
    # .assign(GVKEY_date = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
    .drop(columns = ['datadate'])
    # .query('year >= 1997 and year <= 2005')
    .query('~(sic >= 6000 and sic < 7000) and ~(sic >= 4900 and sic < 5000)')
)
# compustat_sel_pre_merge.head(50)

# compustat_sel_pre_merge['GVKEY'].nunique()
# compustat_sel['GVKEY'].nunique()
compustat_sel_pre_merge = compustat_sel_pre_merge[~compustat_sel_pre_merge.duplicated('GVKEY_year_quarter', keep='first')]
#compustat_sel_pre_merge.shape

compust = (pd.merge(compustat_sel_pre_merge, df_intan_sel_pre_merge, how = 'left', on = 'GVKEY_year_quarter'))
# compust_no_na = compust.dropna(subset = ['atq_intan'])
# compust.head(50)
###################################################################
# Changing the date on Compustat to merge with CRSP (release date)
###################################################################

compust = compust.drop(columns = ['GVKEY_year_quarter', 'year_quarter'])

compust_pre_merge = (compust
    .assign(rdq = pd.to_datetime(compust["rdq"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
    # .assign(day = lambda x: x['rdq'].dt.day.astype('Int64'))
    # .assign(month = lambda x: x['rdq'].dt.month.astype('Int64'))
    # .assign(year = lambda x: x['rdq'].dt.year.astype('Int64'))
    .assign(year_month = lambda x: x['rdq'].dt.to_period('M'))
    .assign(GVKEY_year_month = lambda x: x['GVKEY'].astype(str) + '_' + x['year_month'].astype(str))
    #.drop(columns = ['GVKEY'])
)
# compust.shape
# compust_pre_merge.head(50)
# compust_pre_merge.shape

compust_pre_merge.to_feather('data/feather/compust_pre_merge.feather')
