import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from linearmodels.asset_pricing import LinearFactorModel
from statsmodels.stats.outliers_influence import variance_inflation_factor

# Read the data from the CSV file
df = pd.read_feather('data/feather/ccm.feather') #from crsp_merge.py

#df = df.assign(date = pd.to_datetime(df["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
#df['date'] = pd.to_datetime(df['date'], format='%Y%m%d', errors='coerce')

df.set_index(['GVKEY', 'date'], inplace=True)
df = df[~df.index.duplicated(keep='first')]

# Convert the columns to numeric
df['RET'] = pd.to_numeric(df['RET'], errors='coerce')
df['debt_at'] = pd.to_numeric(df['debt_at'], errors='coerce')

# Creating variables
df['RET_lag1'] = df.groupby('GVKEY')['RET'].shift(1)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)


#############################################################
# Running the regressions on all states subject to the laws
#############################################################

############
# TX and LA
############

df['dummy_tx_la_97'] = (((df['state'] == 'TX') | (df['state'] == 'LA')) & (df['year'] >= 1997))
df['lev_x_dummy_tx_la_97'] = df['debt_at_lag1'] * df['dummy_tx_la_97']
df = df.dropna(subset=['RET', 'debt_at_lag1', 'RET_lag1', 'dummy_tx_la_97', 'lev_x_dummy_tx_la_97'])

# # Test the model on a smaller subset of the data
# sample_fraction = 0.01  # Use 1% of the data for a quick test
# data_sample = df.sample(frac=sample_fraction, random_state=0)


dep = df['RET']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_tx_la_97', 'lev_x_dummy_tx_la_97']]
#indep['dummy_tx_la_97'] = indep['dummy_tx_la_97'].astype(int)

# # Calculate VIF for each independent variable
# vif_data = pd.DataFrame()
# vif_data['feature'] = indep.columns
# vif_data['VIF'] = [variance_inflation_factor(indep.values, i) for i in range(indep.shape[1])]
# print(vif_data)

#dep = dep.loc[indep.index]

# Create the model and fit it
mod = LinearFactorModel(dep, indep)
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