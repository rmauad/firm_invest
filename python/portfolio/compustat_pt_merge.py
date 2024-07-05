import pandas as pd
import pyreadr
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from merge_functions import custom_fill
# import sys
# sys.path.append('code/firm_invest/python/psm_did_event/')
# from data_functions import convert_to_datetime

df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
pt_intan = pd.read_csv('data/csv/peterstaylor.csv')
# comp_annual.shape
# pt_intan.head(50)

#########################################################################################
# Merging original annual Compustat with the Peters and Taylor intangible capital measure
#########################################################################################
df = (df
      .assign(year = df['date_ret'].dt.year)
      .assign(month = df['date_ret'].dt.month))

df['date_compustat_filled'] = df.apply(
    lambda row: f"{row['year']-1}-12-31" if pd.isna(row['date_compustat']) and row['month'] in [1, 2, 3] else row['date_compustat'],
    axis=1
)

# Convert the new column to datetime format
df['date_compustat_filled'] = pd.to_datetime(df['date_compustat_filled'])
# df[['GVKEY', 'date_ret', 'date_compustat', 'date_compustat_filled']].head(50)
# df_test = df.dropna(subset = ['date_compustat_filled'])
pt_intan_sel = pt_intan[['gvkey', 'datadate', 'K_int']]
# pt_intan_sel.head(50)
pt_intan_sel['date_compustat_filled'] = pd.to_datetime(pt_intan_sel['datadate'], format='%Y%m%d', errors='coerce')
pt_intan_sel = (pt_intan_sel
                .drop(columns=['datadate'])
                .rename(columns={'K_int': 'intan_pt', 'gvkey': 'GVKEY'}))
# pt_intan_sel.head(50)

df_intan = pd.merge(df, pt_intan_sel, how = 'left', on = ['GVKEY', 'date_compustat_filled'])
# df.shape
# df_intan.shape

df_intan['intan_pt_interp'] = df_intan.groupby('GVKEY')['intan_pt'].transform(lambda x: x.interpolate())
df_intan_pt = (df_intan
            .assign(year = df_intan['date_ret'].dt.year)
            .query('year <= 2017')
            .drop(columns = ['year', 'month']))

#df_intan[['GVKEY', 'date_ret', 'date_compustat_filled', 'intan_pt', 'intan_pt_interp']].tail(50)  

df_intan_pt.to_feather('data/feather/df_intan_pt.feather')
