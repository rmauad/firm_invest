import pandas as pd
import numpy as np
from linearmodels.panel import PanelOLS

# COME BACK TO THIS CODE WITH A MEASURE OF INTANGIBLE CAPITAL.
# THE IMPACT OF LEVERAGE VARIATION ON STOCK RETURN IS NOT IMPACTED BY THE IMPLEMENATION OF ANTI-RECHARACTERIZATION LAWS.

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
betas = pd.read_feather('data/feather/df_reg_beta.feather') #from calc_beta.py

# df.shape
# df.head(50)
# df.shape
# df_test = df.dropna(subset=['atq'])
# df_test.shape
# df_test.head(50)
# Generate leverage and drop NAs based on the leverage
df = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1975 and ceqq > 0')
      .assign(tang_at = df['ppentq']/df['atq']))


# df.shape
df = (pd.merge(df, betas, how = 'left', on = ['GVKEY', 'year_month']))
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df['roe'] = df['niq'] / df['ceqq']
df['roa'] = df['niq'] / df['atq']
df_new = (df
      #.assign(GVKEY = df['GVKEY'].astype('Int64'))
      .assign(bm = df['ceqq']*1000 / (np.abs(df['PRC'])*df['SHROUT'])) #ceqq is in millions and shrout is in thousands
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      #.assign(d_tx_la_97_03 = (df['state'] == 'TX') | (df['state'] == 'LA') & (df['year'] >= 1997) & (df['year'] <= 2003))
      .assign(d_tx_97 = lambda x: (x['state'] == 'TX') & (x['year_month'] >= '1997-01') & (x['year_month']<= '2003-12'))
      #.assign(d_tx_97 = lambda x: (x['state'] == 'TX') & (x['year_month'] >= '2003-12'))
)

# df[['GVKEY', 'year_month', 'bm']].head(50)

# df[['date_ret', 'year_month',  'RET']].head(50)
df_new['year_month'] = df_new['year_month'].dt.to_timestamp()

# Creating terciles based on physical capital over total assets
def create_terciles(group):
    group['tercile'] = pd.qcut(group['tang_at'], q=3, labels=[1, 2, 3])
    return group

df_quantiles = df_new.groupby('year_month').apply(create_terciles)
df_quantiles = df_quantiles.reset_index(drop=True)
df_quantiles = (df_quantiles
                .assign(hpk = (df_quantiles['tercile'] == 3))
                )
# df_quantiles[['GVKEY', 'year_month', 'hpk', 'tercile']].head(50)
# df_sorted = df_quantiles.sort_values(by=['year_month', 'tercile'])
# df_sorted[['GVKEY', 'year_month', 'tang_at', 'tercile']].head(50)

# Creating variables for the regressions
df_quantiles.set_index(['GVKEY', 'year_month'], inplace=True)
df_quantiles['RET_lead1'] = df_quantiles.groupby('GVKEY')['RET'].shift(-1)
# df.head(50)
df_quantiles['debt_at_lag1'] = df_quantiles.groupby('GVKEY')['debt_at'].shift(1)
df_quantiles['d_debt_at'] = df_quantiles['debt_at'] - df_quantiles['debt_at_lag1']
df_quantiles['roe_lag1'] = df_quantiles.groupby('GVKEY')['roe'].shift(1)
df_quantiles['d_roe'] = df_quantiles['roe'] - df_quantiles['roe_lag1']
df_quantiles['dummy'] = df_quantiles['d_tx_97'] * df_quantiles['hpk']
#df_clean = df.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq'])
# df_clean = df.replace([np.inf, -np.inf], np.nan)
# df.head(50)

# df_reset = df.reset_index()
# df_reset.loc[
#     (df_reset['year_month'] == '1997-02') & (df_reset['state'] == 'TX'),
#     ['year_month', 'GVKEY', 'state', 'dummyXd_debt_at', 'd_debt_at']
# ].head(50)

df_clean = df_quantiles.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
df_clean_no_na = df_clean.dropna(subset=['dummy', 'RET_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])

# df_clean_no_na.head(50)
# df_clean_no_na['d_roe'].isna().sum()
# num_infs = np.isinf(df_clean['d_roe']).sum()
# print(num_infs)

###################################
# Running Panel OLS regressions
###################################

dep = df_clean_no_na['RET_lead1']*100
indep = df_clean_no_na[['hpk', 'ln_ceqq', 'roa', 'RET', 'beta', 'bm']]
# df_reset = df_clean_no_na.reset_index()
# df_reset['GVKEY'].nunique()
# df_reset['year_month'].min()
# df_reset.columns

# Create the model and fit it
mod = PanelOLS(dep, indep)
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