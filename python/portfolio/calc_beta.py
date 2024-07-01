import pandas as pd
import numpy as np
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from calc_beta_functions import rolling_regression

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
rf = pd.read_csv('data/csv/TB3MS.csv')
# df.columns
# df['RET'].head(50)
# df.columns
df_short = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1975'))

df_sel = df_short[['year_month', 'GVKEY', 'RET', 'mkt_rf']]


rf_monthly = (rf
              .assign(date_ret = pd.to_datetime(rf['DATE'], format='%Y-%m-%d', errors = "coerce"))
              .assign(year_month = lambda x: x['date_ret'].dt.to_period('M'))
              .assign(rf_annual = lambda x: pd.to_numeric(x['TB3MS'], errors = "coerce"))
              .assign(rf_monthly = lambda x: ((1 + x['rf_annual']/100)**(1/12)) - 1)
              .drop(columns= ['DATE', 'date_ret', 'TB3MS', 'rf_annual'])
              )
#rf_monthly['rf_annual'].dtype
#rf_monthly[rf_monthly['year_month'] == '2023-12'].head(50)
#rf_monthly.head(50)
# df.columns
# df['mkt_rf'].isna().sum()

df_beta = (pd.merge(df_sel, rf_monthly, how = 'left', on = 'year_month'))
# rf_monthly.columns
# df_sel.columns
# df_beta.head(50)
# df_sel.shape
df_reg = (df_beta
          .assign(RET = pd.to_numeric(df_beta['RET'], errors = 'coerce'))
          .assign(ret_rf = lambda x: x['RET'] - x['rf_monthly'])
          .assign(mkt_rf = df_beta['mkt_rf']/100)
          #.assign(mkt_rf = pd.to_numeric(df_beta['mkt_rf'], errors = 'coerce'))
          .drop(columns = ['RET', 'rf_monthly'])   
)
# df_reg.head(50)
########################################################
# Run a rolling window OLS regression to calculate beta
########################################################

df_reg = df_reg.sort_values(by=['GVKEY', 'year_month'])

# Apply the rolling regression with a 2-year window (24 months)
rolling_results = rolling_regression(df_reg, 24)

# print(rolling_results)
# rolling_results.shape
# rolling_results_no_na = rolling_results.dropna(subset = ['mkt_rf'])
# rolling_results_no_na.shape
betas = rolling_results[['year_month', 'GVKEY', 'mkt_rf']]
betas = betas.rename(columns = {'mkt_rf': 'beta'})
# betas.head(50)

# Merge the betas with the original dataframe
df_reg_beta = df_reg.merge(betas, on=['year_month', 'GVKEY'], how='left')
# df_reg_beta.shape
# df_reg.shape
df_reg_beta = df_reg_beta[['year_month', 'GVKEY', 'beta']]

df_reg_beta.to_feather('data/feather/df_reg_beta.feather')
