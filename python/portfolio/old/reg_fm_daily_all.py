import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from linearmodels.asset_pricing import LinearFactorModel
from linearmodels.panel.model import FamaMacBeth
from statsmodels.stats.outliers_influence import variance_inflation_factor

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
df.head(50)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['d_debt_at'] = df['debt_at'] - df['debt_at_lag1']
#df_clean = df.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq'])
# df_clean = df.replace([np.inf, -np.inf], np.nan)

##############################################################
# Cleaning the dataframe for Fama MacBeth regressions 
#(removing inf, NA, firms with one single observation, etc.)
##############################################################

df_clean = df.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean = df_clean.dropna(subset=['debt_at', 'RET', 'ln_ceqq'])

df_clean['RET'].isna().sum()
num_infs = np.isinf(df_clean['ln_ceqq']).sum()
print(num_infs)

# Creating variables
# df['RET_lag1'] = df.groupby('GVKEY')['RET'].shift(1)
constant_within_firms = df_clean.groupby(['GVKEY'])['RET'].nunique().reset_index()
constant_firms = constant_within_firms[constant_within_firms['RET'] == 1]
if not constant_firms.empty:
    print("Firms with constant returns within time periods:")
    print(constant_firms)

df_clean_reset = df_clean.reset_index()
#df_clean_reset[['GVKEY', 'date_ret', 'RET', 'debt_at']][df_clean_reset['GVKEY'] == 1278].head(50)

# Drop firms with a single observation
observation_counts = df_clean_reset.groupby('GVKEY').size()
single_observation_firms_count = (observation_counts == 1).sum()
print(f"Number of firms with a single observation: {single_observation_firms_count}")

single_observation_firms = observation_counts[observation_counts == 1].index
#print(f"Firms with a single observation: {single_observation_firms.tolist()}")
df_clean_drop_1obs = df_clean_reset[~df_clean_reset['GVKEY'].isin(single_observation_firms)]
print(df_clean_drop_1obs['GVKEY'].nunique())
print(df_clean_reset['GVKEY'].nunique())

df_clean_drop_1obs.head(50)
# df_clean_drop_1obs.set_index(['GVKEY', 'date_ret'], inplace=True)
constant_within_firms = df_clean_drop_1obs.groupby(['GVKEY'])['RET'].nunique().reset_index()
constant_firms = constant_within_firms[constant_within_firms['RET'] == 1]
if not constant_firms.empty:
    print("Firms with constant returns within time periods:")
    print(constant_firms)

# See constant returns for a specific firm
df_clean_drop_1obs = df_clean_drop_1obs.reset_index()
df_clean_drop_1obs[['GVKEY', 'date_ret', 'RET']][df_clean_drop_1obs['GVKEY'] == 3779].head()

# Drop firms with constant returns
constant_firm_keys = constant_firms['GVKEY'].tolist()
df_clean_drop_cte = df_clean_drop_1obs[~df_clean_drop_1obs['GVKEY'].isin(constant_firm_keys)]

###################################
# Running Fama MacBeth regressions
###################################
df_clean_drop_cte.set_index(['GVKEY', 'date_ret'], inplace=True)

# dep = df_clean['RET_lead1']
# indep = df_clean[['d_debt_at', 'ln_ceqq']]
dep = df_clean_drop_cte['RET']
indep = df_clean_drop_cte[['debt_at']]

#indep['dummy_tx_la_97'] = indep['dummy_tx_la_97'].astype(int)

# # Calculate VIF for each independent variable
# vif_data = pd.DataFrame()
# vif_data['feature'] = indep.columns
# vif_data['VIF'] = [variance_inflation_factor(indep.values, i) for i in range(indep.shape[1])]
# print(vif_data)

#dep = dep.loc[indep.index]

# Create the model and fit it
mod = FamaMacBeth(dep, indep)
res = mod.fit()

# Print the results
print(res)

##########
# TX only
##########

df['dummy_tx_97'] = ((df['state'] == 'TX') & (df['year'] >= 1997))
df['lev_x_dummy_tx_97'] = df['debt_at_lag1'] * df['dummy_tx_97']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_tx_97', 'lev_x_dummy_tx_97']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

##########
# LA only
##########

df['dummy_la_97'] = ((df['state'] == 'LA') & (df['year'] >= 1997))
df['lev_x_dummy_la_97'] = df['debt_at_lag1'] * df['dummy_la_97']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_la_97', 'lev_x_dummy_la_97']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

######
# AL
######

df['dummy_al_01'] = ((df['state'] == 'AL') & (df['year'] >= 2001))
df['lev_x_dummy_al_01'] = df['debt_at_lag1'] * df['dummy_al_01']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_al_01', 'lev_x_dummy_al_01']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

######
# DE
######

df['dummy_de_02'] = ((df['state'] == 'DE') & (df['year'] >= 2002))
df['lev_x_dummy_de_02'] = df['debt_at_lag1'] * df['dummy_de_02']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_de_02', 'lev_x_dummy_de_02']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

######
# SD
######

df['dummy_sd_03'] = ((df['state'] == 'SD') & (df['year'] >= 2003))
df['lev_x_dummy_sd_03'] = df['debt_at_lag1'] * df['dummy_sd_03']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_sd_03', 'lev_x_dummy_sd_03']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

######
# VA
######

df['dummy_va_04'] = ((df['state'] == 'VA') & (df['year'] >= 2004))
df['lev_x_dummy_va_04'] = df['debt_at_lag1'] * df['dummy_va_04']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_va_04', 'lev_x_dummy_va_04']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)

######
# NV
######

df['dummy_nv_05'] = ((df['state'] == 'NV') & (df['year'] >= 2005))
df['lev_x_dummy_nv_05'] = df['debt_at_lag1'] * df['dummy_nv_05']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_nv_05', 'lev_x_dummy_nv_05']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)