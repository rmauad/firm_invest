import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from linearmodels.panel import PanelOLS

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_all.feather') #from crsp_merge_daily.py

# Generate leverage and drop NAs based on the leverage
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df = (df
      #.assign(GVKEY = df['GVKEY'].astype('Int64'))
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce')))

df.set_index(['GVKEY', 'date_ret'], inplace=True)
df['RET_lead1'] = df.groupby('GVKEY')['RET'].shift(-1)
# df.head(50)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['d_debt_at'] = df['debt_at'] - df['debt_at_lag1']

df_clean = df.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_reset = df_clean.reset_index()
df_reset = df_reset.dropna(subset=['GVKEY', 'date_ret', 'debt_at', 'ln_ceqq', 'RET'])
df_clean = df_reset.set_index(['GVKEY', 'date_ret'])
#df_clean = df.replace([np.inf, -np.inf], np.nan)

###################################
# Running Panel OLS regressions
###################################
dep = df_clean['RET_lead1']
indep = df_clean[['d_debt_at', 'ln_ceqq']]

df_reset = df_clean.reset_index()
print(df_reset['date_ret'].isna().sum())
infinite_values = df_reset[np.isinf(df_reset['ln_ceqq'])]
print(infinite_values)

# # Calculate VIF for each independent variable
# vif_data = pd.DataFrame()
# vif_data['feature'] = indep.columns
# vif_data['VIF'] = [variance_inflation_factor(indep.values, i) for i in range(indep.shape[1])]
# print(vif_data)

# Create the model and fit it
mod = PanelOLS(dep, indep)
res = mod.fit()

# Print the results
print(res)