import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from report_functions import add_stars

# Read the data from the feather file
df = pd.read_feather('data/feather/df_intan_pt.feather') #from compustat_pt_merge.py
betas = pd.read_feather('data/feather/df_reg_beta.feather') #from calc_beta.py
# df.shape
df = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1980 and ceqq > 0')) #and ltq >= 0
# df.shape
df = (pd.merge(df, betas, how = 'left', on = ['GVKEY', 'year_month']))
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df['lev'] = df['ltq'] / df['atq']
df['intan_pt_at'] = df['intan_pt'] / df['atq']
df['roe'] = df['niq'] / df['ceqq']
df['roa'] = df['niq'] / df['atq']

# Change book-to-market ratio
df = (df
      #.assign(ceqq_lag1 = df.groupby('GVKEY')['ceqq'].shift(1))
      .assign(me = (np.abs(df['PRC'])*df['SHROUT'])/1000000))# convert to billions
df = (df
      .assign(bm = df['ceqq'] / (df['me']*1000)) #ceqq is in millions and me is in billions
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(ln_me = np.log(df['me']))      
      .assign(ln_at = np.log(df['atq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      )

# Removing outliers based on book-to-market ratio
lower_bound = df['bm'].quantile(0.01)
upper_bound = df['bm'].quantile(0.99)
df = df[(df['bm'] >= lower_bound) & (df['bm'] <= upper_bound)]

# df[['GVKEY', 'year_month', 'ceqq', 'ceqq_lag1', 'PRC', 'SHROUT', 'bm']].tail(50)

df['year_month'] = df['year_month'].dt.to_timestamp()
df.set_index(['GVKEY', 'year_month'], inplace=True)

df['terc_lev'] = df.groupby('year_month')['lev'].transform(
    lambda x: pd.qcut(x, 3, labels=['Low', 'Medium', 'High'])
)

# df['ter_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 3, labels=[1, 2, 3]) 
# )

# df['med_intan'] = pd.qcut(df['intan_pt_at'], 2, labels=[1, 2])
#df['ter_intan'] = pd.qcut(df['intan_pt_at'], 3, labels=[1, 2, 3])
# df['qua_intan'] = pd.qcut(df['intan_pt_at'], 4, labels=[1, 2, 3, 4])
# df['qui_intan'] = pd.qcut(df['intan_pt_at'], 5, labels=[1, 2, 3, 4, 5])

# df['med_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 2, labels=[1, 2]) 
# )

# df['ter_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 3, labels=[1, 2, 3]) 
# )

df['qua_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
    lambda x: pd.qcut(x, 4, labels=[1, 2, 3, 4]) 
)

# df['qui_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 5, labels=[1, 2, 3, 4, 5]) 
# )

# df['dec_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 10, labels=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) 
# )

# df[['intan_pt_at', 'quart_intan']].head(50)
df_new = (df
      .assign(ret_aux = 1 + df['RET'])
      .assign(one_year_cum_return = lambda x: x.groupby('GVKEY')['ret_aux'].rolling(window=12, min_periods=12).apply(np.prod, raw=True).reset_index(level=0, drop=True) - 1)
      #.assign(one_year_cum_return = lambda x: x.groupby('GVKEY')['cum_return'].shift(-11))  # Align with current date
      .assign(ret_aux_lead1 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-1))
      .assign(ret_aux_lead2 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-2))
      .assign(ret_2mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']) - 1)
      .assign(ret_2mo_lead1 = lambda x: x.groupby('GVKEY')['ret_2mo'].shift(-1))
      .assign(ret_3mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']*x['ret_aux_lead2']) - 1)
      .assign(ret_3mo_lead1 = lambda x: x.groupby('GVKEY')['ret_3mo'].shift(-1))
      .assign(hlev = lambda x: x['terc_lev'] == 'High')
      .assign(llev = lambda x: x['terc_lev'] == 'Low')
      .assign(hint = lambda x: x['qua_intan'] == 4)
      .assign(lint = lambda x: x['qua_intan'] == 1)                
      .drop(columns=['ret_aux', 'ret_aux_lead1', 'ret_aux_lead2'])       
      )

# df_new[['RET', 'one_year_cum_return']].head(50)
#df_new[['RET', 'ret_aux', 'ret_aux_lead1', 'ret_aux_lead2', 'ret_3mo', 'ret_3mo_lead1']].head(50)
# df_new[['hint', 'quart_intan']][df_new['quart_intan'] == 4].tail(50)
# df_int = df_new.query('hint == True')

df_new['RET_lead1'] = df_new.groupby('GVKEY')['RET'].shift(-1)
df_new['debt_at_lag1'] = df_new.groupby('GVKEY')['debt_at'].shift(1)
df_new['d_debt_at'] = df_new['debt_at'] - df_new['debt_at_lag1']
df_new['d_ln_debt_at'] = np.log(df_new['debt_at']) - np.log(df_new['debt_at_lag1'])
df_new['lev_lag1'] = df_new.groupby('GVKEY')['lev'].shift(1)
df_new['d_lev'] = df_new['lev'] - df_new['lev_lag1']
df_new['d_ln_lev'] = np.log(df_new['lev']) - np.log(df_new['lev_lag1'])
df_new['roe_lag1'] = df_new.groupby('GVKEY')['roe'].shift(1)
df_new['d_roe'] = df_new['roe'] - df_new['roe_lag1']

#df_int['dummyXdebt_at'] = df_int['debt_at'] * df_int['lint']

df_clean = df_new.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean['ln_me'] = df_clean['ln_me'].replace([np.inf, -np.inf], np.nan)
df_clean['ln_at'] = df_clean['ln_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_ln_debt_at'] = df_clean['d_ln_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_lev'] = df_clean['d_lev'].replace([np.inf, -np.inf], np.nan)
df_clean['d_ln_lev'] = df_clean['d_ln_lev'].replace([np.inf, -np.inf], np.nan)
df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
# df_reset = df_clean.reset_index()
# df_clean_no_na = df_reset.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])
# df_clean_no_na['year_month'].nunique()
# df_clean_no_na['year_month'].max()

save = df_clean.to_feather('data/feather/df_fm.feather')
