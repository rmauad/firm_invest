import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from linearmodels.asset_pricing import LinearFactorModel
from linearmodels.panel.model import FamaMacBeth
from statsmodels.stats.outliers_influence import variance_inflation_factor

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
betas = pd.read_feather('data/feather/df_reg_beta.feather') #from calc_beta.py
#testing changes

# df.shape
# df.head(50)
# df.shape
# df_test = df.dropna(subset=['atq'])
# df_test.shape
# df_test.head(50)
# Generate leverage and drop NAs based on the leverage
df = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1975 and ceqq > 0'))
# df.shape
df = (pd.merge(df, betas, how = 'left', on = ['GVKEY', 'year_month']))
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df['roe'] = df['niq'] / df['ceqq']
df['roa'] = df['niq'] / df['atq']
df = (df
      #.assign(GVKEY = df['GVKEY'].astype('Int64'))
      .assign(bm = df['ceqq']*1000 / (np.abs(df['PRC'])*df['SHROUT'])) #ceqq is in millions and shrout is in thousands
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      )

# df[['GVKEY', 'year_month', 'bm']].head(50)

# df[['date_ret', 'year_month',  'RET']].head(50)
df['year_month'] = df['year_month'].dt.to_timestamp()
df.set_index(['GVKEY', 'year_month'], inplace=True)
df = (df
      .assign(ret_aux = 1 + df['RET'])
      .assign(ret_aux_lead1 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-1))
      .assign(ret_aux_lead2 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-2))
      .assign(ret_2mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']) - 1)
      .assign(ret_2mo_lead1 = lambda x: x.groupby('GVKEY')['ret_2mo'].shift(-1))
      .assign(ret_3mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']*x['ret_aux_lead2']) - 1)
      .assign(ret_3mo_lead1 = lambda x: x.groupby('GVKEY')['ret_3mo'].shift(-1))      
      .drop(columns=['ret_aux', 'ret_aux_lead1', 'ret_aux_lead2'])       
      )
# df[['RET', 'ret_aux', 'ret_aux_lead1', 'ret_aux_lead2', 'ret_3mo', 'ret_3mo_lead1']].head(50)

df['RET_lead1'] = df.groupby('GVKEY')['RET'].shift(-1)
# df.head(50)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['d_debt_at'] = df['debt_at'] - df['debt_at_lag1']
df['roe_lag1'] = df.groupby('GVKEY')['roe'].shift(1)
df['d_roe'] = df['roe'] - df['roe_lag1']
#df_clean = df.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq'])
# df_clean = df.replace([np.inf, -np.inf], np.nan)
# df.head(50)

df_clean = df.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
df_clean_no_na = df_clean.dropna(subset=['d_debt_at', 'ret_2mo_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])

# df_clean_no_na.head(50)
# df_clean_no_na['d_roe'].isna().sum()
# num_infs = np.isinf(df_clean['d_roe']).sum()
# print(num_infs)

###################################
# Running Fama MacBeth regressions
###################################

dep = df_clean_no_na['ret_2mo_lead1']*100
indep = df_clean_no_na[['d_debt_at', 'ln_ceqq', 'roa', 'RET', 'beta', 'bm']]
# df_reset = df_clean_no_na.reset_index()
# df_reset['GVKEY'].nunique()
# df_reset['year_month'].min()
# df_reset.columns

# Create the model and fit it
mod = FamaMacBeth(dep, indep)
res = mod.fit()

# Print the results
print(res)

##############################################################
# Cleaning the dataframe for Fama MacBeth regressions 
#(removing inf, NA, firms with one single observation, etc.)
##############################################################
# # Calculate VIF for each independent variable
# vif_data = pd.DataFrame()
# vif_data['feature'] = indep.columns
# vif_data['VIF'] = [variance_inflation_factor(indep.values, i) for i in range(indep.shape[1])]
# print(vif_data)


# Creating variables
# df['RET_lag1'] = df.groupby('GVKEY')['RET'].shift(1)
# constant_within_firms = df_clean.groupby(['GVKEY'])['RET'].nunique().reset_index()
# constant_firms = constant_within_firms[constant_within_firms['RET'] == 1]
# if not constant_firms.empty:
#     print("Firms with constant returns within time periods:")
#     print(constant_firms)

# df_clean_reset = df_clean.reset_index()
# #df_clean_reset[['GVKEY', 'date_ret', 'RET', 'debt_at']][df_clean_reset['GVKEY'] == 1278].head(50)

# # Drop firms with a single observation
# observation_counts = df_clean_reset.groupby('GVKEY').size()
# single_observation_firms_count = (observation_counts == 1).sum()
# print(f"Number of firms with a single observation: {single_observation_firms_count}")

# single_observation_firms = observation_counts[observation_counts == 1].index
# #print(f"Firms with a single observation: {single_observation_firms.tolist()}")
# df_clean_drop_1obs = df_clean_reset[~df_clean_reset['GVKEY'].isin(single_observation_firms)]
# print(df_clean_drop_1obs['GVKEY'].nunique())
# print(df_clean_reset['GVKEY'].nunique())

# df_clean_drop_1obs.head(50)
# # df_clean_drop_1obs.set_index(['GVKEY', 'date_ret'], inplace=True)
# constant_within_firms = df_clean_drop_1obs.groupby(['GVKEY'])['RET'].nunique().reset_index()
# constant_firms = constant_within_firms[constant_within_firms['RET'] == 1]
# if not constant_firms.empty:
#     print("Firms with constant returns within time periods:")
#     print(constant_firms)

# # See constant returns for a specific firm
# df_clean_drop_1obs = df_clean_drop_1obs.reset_index()
# df_clean_drop_1obs[['GVKEY', 'date_ret', 'RET']][df_clean_drop_1obs['GVKEY'] == 3779].head()

# # Drop firms with constant returns
# constant_firm_keys = constant_firms['GVKEY'].tolist()
# df_clean_drop_cte = df_clean_drop_1obs[~df_clean_drop_1obs['GVKEY'].isin(constant_firm_keys)]