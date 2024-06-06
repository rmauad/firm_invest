# This code runs a propensity score matching to get a control group for firms in TX and LA

import pandas as pd
import numpy as np
# import matplotlib.pyplot as plt
# import os
# import sys
# sys.path.append('code/firm_invest/python/')
# from data_functions import convert_to_datetime
# import requests as rq

# Load the data
db_did = pd.read_csv('data/csv/db_did.csv') # created by prep_db_did.py

# Generating variables "debt issuance"
db_did['debt_issuance'] = db_did['dltisy'] - db_did['dltry'] + db_did['dlcchy']

# Only changing name (this is the variable that will be used in the PSM)
db_did_na_clean = db_did

# Generating tercile of intangible/assets (but this is ready from R: intangible/total capital)
# db_did_na_clean['intan_at'] = db_did_na_clean['org_cap_comp'] / db_did_na_clean['atq']
# db_did_na_clean['ter'] = db_did_na_clean.groupby(['year_q'])['intan_at'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))

# Generate a dummy = 1 for firms in all affected states
db_did_na_clean['treated_TX_LA'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'TX') | (db_did_na_clean['state'] == 'LA'), 'treated_TX_LA'] = 1

db_did_na_clean['treated_AL'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'AL'), 'treated_AL'] = 1

db_did_na_clean['treated_DE'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'DE'), 'treated_DE'] = 1

db_did_na_clean['treated_SD'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'SD'), 'treated_SD'] = 1

db_did_na_clean['treated_VA'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'VA'), 'treated_VA'] = 1

db_did_na_clean['treated_NV'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'NV'), 'treated_NV'] = 1


# Generate the metrics to be used in the PSM 
# (average of investment growth, investment level, 
# size, leverage, cash/assets ratio, and Tobin's Q )

# Generate the log change between quarters for each firm

db_did_na_clean['dln_inv'] = db_did_na_clean.groupby(['GVKEY'])['capxy'].transform(lambda x: np.log(x) - np.log(x.shift(1)))
db_did_na_clean['dln_inv'] = db_did_na_clean['dln_inv'].apply(lambda x: x if x != float('inf') else 0)
db_did_na_clean['dln_inv'] = db_did_na_clean['dln_inv'].apply(lambda x: x if x != float('-inf') else 0)
db_did_na_clean['dln_inv'] = db_did_na_clean['dln_inv'].apply(lambda x: x if x != float('nan') else 0)

# Generate Tobin's Q
db_did_na_clean['tobin_q'] = ((db_did_na_clean['cshoq']*db_did_na_clean['prccq']) + db_did_na_clean['atq'] - db_did_na_clean['ceqq']) / db_did_na_clean['atq']

# Generate the average of the metrics by quarter (before 1997:Q1)
#metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']
#metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'ceqq', 'sales_gr', 'ltdebt_at']
#metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'ceqq', 'sales_gr']
#metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'sales_gr']
#metrics = ['dln_inv', 'capxy', 'atq', 'debt_at']
metrics = ['capxy', 'atq', 'debt_at']
# metrics = ['capxy', 'atq', 'debt_at', 'ceqq', 'ltdebt_at']
#metrics = ['capxy', 'atq', 'debt_at', 'ceqq']
filtered_db = db_did_na_clean[db_did_na_clean['year_q'] < '1996Q4']
mean_values = filtered_db.groupby('GVKEY')[metrics].mean()
db_did_merge = db_did_na_clean.merge(mean_values, on='GVKEY', how='left', suffixes=('', '_mean'))

#region Generate the propensity score
from sklearn.linear_model import LogisticRegression
#metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'cash_at_mean', 'tobin_q_mean']
#metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'sales_gr_mean', 'ltdebt_at_mean']
#metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'sales_gr_mean']
#metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'sales_gr_mean']
#metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean']
metrics_mean = ['capxy_mean', 'atq_mean', 'debt_at_mean']
# metrics_mean = ['capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'ltdebt_at_mean']
#metrics_mean = ['capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean']
db_did_clean = db_did_merge.dropna(subset=metrics_mean).copy() # .copy() guarantees that a new independent dataframe is created
X = db_did_clean[metrics_mean]  # the financial metrics
y_tx_la = db_did_clean['treated_TX_LA']  # treatment indicator
y_al = db_did_clean['treated_AL']  # treatment indicator
y_de = db_did_clean['treated_DE']  # treatment indicator
y_sd = db_did_clean['treated_SD']  # treatment indicator
y_va = db_did_clean['treated_VA']  # treatment indicator
y_nv = db_did_clean['treated_NV']  # treatment indicator

# Fit the logistic regression model
logistic = LogisticRegression()

logistic.fit(X, y_tx_la)
db_did_clean.loc[:, 'propensity_score_tx_la'] = logistic.predict_proba(X)[:, 1]

logistic.fit(X, y_al)
db_did_clean.loc[:, 'propensity_score_al'] = logistic.predict_proba(X)[:, 1]

logistic.fit(X, y_de)
db_did_clean.loc[:, 'propensity_score_de'] = logistic.predict_proba(X)[:, 1]

logistic.fit(X, y_sd)
db_did_clean.loc[:, 'propensity_score_sd'] = logistic.predict_proba(X)[:, 1]

logistic.fit(X, y_va)
db_did_clean.loc[:, 'propensity_score_va'] = logistic.predict_proba(X)[:, 1]

logistic.fit(X, y_nv)
db_did_clean.loc[:, 'propensity_score_nv'] = logistic.predict_proba(X)[:, 1]

# Matching the treated and control groups
from sklearn.neighbors import NearestNeighbors

treatment_tx_la = db_did_clean[db_did_clean['treated_TX_LA'] == 1]
control_tx_la = db_did_clean[db_did_clean['treated_TX_LA'] == 0]

treatment_al = db_did_clean[db_did_clean['treated_AL'] == 1]
control_al = db_did_clean[db_did_clean['treated_AL'] == 0]

treatment_de = db_did_clean[db_did_clean['treated_DE'] == 1]
control_de = db_did_clean[db_did_clean['treated_DE'] == 0]

treatment_sd = db_did_clean[db_did_clean['treated_SD'] == 1]
control_sd = db_did_clean[db_did_clean['treated_SD'] == 0]

treatment_va = db_did_clean[db_did_clean['treated_VA'] == 1]
control_va = db_did_clean[db_did_clean['treated_VA'] == 0]

treatment_nv = db_did_clean[db_did_clean['treated_NV'] == 1]
control_nv = db_did_clean[db_did_clean['treated_NV'] == 0]

#print unique firms in the treatment and control groups
print(treatment_tx_la['GVKEY'].nunique()) #540
print(control_tx_la['GVKEY'].nunique()) #4415

print(treatment_al['GVKEY'].nunique()) #29
print(control_al['GVKEY'].nunique()) #4926

print(treatment_de['GVKEY'].nunique()) #15
print(control_de['GVKEY'].nunique()) #4940

print(treatment_sd['GVKEY'].nunique()) #5
print(control_sd['GVKEY'].nunique()) #4950

print(treatment_va['GVKEY'].nunique()) #113
print(control_va['GVKEY'].nunique()) #4842

print(treatment_nv['GVKEY'].nunique()) #60
print(control_nv['GVKEY'].nunique()) #4895

print(db_did['GVKEY'].nunique()) #9930 (total number of firms)

#endregion

# Initialize an empty list to hold the matched DataFrames
matched_pairs_list = []

# Get unique time periods
unique_quarter = np.sort(db_did_clean['year_q'].unique())

for quarter in unique_quarter:
    # Filter treatment and control groups for the current time period
    treatment_period_tx_la = db_did_clean[(db_did_clean['treated_TX_LA'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_tx_la = db_did_clean[(db_did_clean['treated_TX_LA'] == 0) & (db_did_clean['year_q'] == quarter)]

    treatment_period_al = db_did_clean[(db_did_clean['treated_AL'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_al = db_did_clean[(db_did_clean['treated_AL'] == 0) & (db_did_clean['year_q'] == quarter)]

    treatment_period_de = db_did_clean[(db_did_clean['treated_DE'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_de = db_did_clean[(db_did_clean['treated_DE'] == 0) & (db_did_clean['year_q'] == quarter)]

    treatment_period_sd = db_did_clean[(db_did_clean['treated_SD'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_sd = db_did_clean[(db_did_clean['treated_SD'] == 0) & (db_did_clean['year_q'] == quarter)]

    treatment_period_va = db_did_clean[(db_did_clean['treated_VA'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_va = db_did_clean[(db_did_clean['treated_VA'] == 0) & (db_did_clean['year_q'] == quarter)]

    treatment_period_nv = db_did_clean[(db_did_clean['treated_NV'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period_nv = db_did_clean[(db_did_clean['treated_NV'] == 0) & (db_did_clean['year_q'] == quarter)]

    # Perform matching if both treatment and control groups are non-empty
    if not treatment_period_tx_la.empty and not control_period_tx_la.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_tx_la[['propensity_score_tx_la']])
        distances, indices_tx_la = nn.kneighbors(treatment_period_tx_la[['propensity_score_tx_la']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_tx_la = control_period_tx_la.iloc[indices_tx_la.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_tx_la = pd.concat([treatment_period_tx_la, matched_control_tx_la])
        matched_pairs_list.append(matched_pairs_tx_la)

    if not treatment_period_al.empty and not control_period_al.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_al[['propensity_score_al']])
        distances, indices_al = nn.kneighbors(treatment_period_al[['propensity_score_al']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_al = control_period_al.iloc[indices_al.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_al = pd.concat([treatment_period_al, matched_control_al])
        matched_pairs_list.append(matched_pairs_al)
    

    if not treatment_period_de.empty and not control_period_de.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_de[['propensity_score_de']])
        distances, indices_de = nn.kneighbors(treatment_period_de[['propensity_score_de']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_de = control_period_de.iloc[indices_de.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_de = pd.concat([treatment_period_de, matched_control_de])
        matched_pairs_list.append(matched_pairs_de)

    if not treatment_period_sd.empty and not control_period_sd.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_sd[['propensity_score_sd']])
        distances, indices_sd = nn.kneighbors(treatment_period_sd[['propensity_score_sd']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_sd = control_period_sd.iloc[indices_sd.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_sd = pd.concat([treatment_period_sd, matched_control_sd])
        matched_pairs_list.append(matched_pairs_sd)

    if not treatment_period_va.empty and not control_period_va.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_va[['propensity_score_va']])
        distances, indices_va = nn.kneighbors(treatment_period_va[['propensity_score_va']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_va = control_period_va.iloc[indices_va.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_va = pd.concat([treatment_period_va, matched_control_va])
        matched_pairs_list.append(matched_pairs_va)

    if not treatment_period_nv.empty and not control_period_nv.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period_nv[['propensity_score_nv']])
        distances, indices_nv = nn.kneighbors(treatment_period_nv[['propensity_score_nv']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control_nv = control_period_nv.iloc[indices_nv.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs_nv = pd.concat([treatment_period_nv, matched_control_nv])
        matched_pairs_list.append(matched_pairs_nv)


# Concatenate all matched pairs across time periods
matched_db = pd.concat(matched_pairs_list)

# Save the database
#matched_db.to_csv('data/csv/psm_clean_all_states.csv', index=False)

###########################################################
# Checking the balance between treated and control groups
###########################################################

from statsmodels.stats.weightstats import CompareMeans, DescrStatsW
from matplotlib import pyplot as plt

# def calculate_smd(group1, group2, covariate):
#     cm = CompareMeans.from_data(group1[covariate], group2[covariate])
#     std_pool = np.sqrt((group1[covariate].var() + group2[covariate].var()) / 2)
#     smd = cm.mean_diff / std_pool
#     return smd

def calculate_smd(group1, group2, covariate):
    # Create DescrStatsW objects for each group for the specified covariate
    desc1 = DescrStatsW(group1[covariate].dropna())
    desc2 = DescrStatsW(group2[covariate].dropna())

    # Calculate the mean difference manually
    mean_diff = desc1.mean - desc2.mean

    # Calculate the pooled standard deviation for the SMD
    # Pooled standard deviation is calculated using the sample sizes and standard deviations of the groups
    n1 = desc1.nobs
    n2 = desc2.nobs
    std1 = desc1.std
    std2 = desc2.std
    pooled_std = np.sqrt(((n1 - 1) * std1**2 + (n2 - 1) * std2**2) / (n1 + n2 - 2))

    # Calculate the Standardized Mean Difference
    smd = mean_diff / pooled_std
    return smd

treated_tx_la = matched_db[matched_db['treated_TX_LA'] == 1]
control_tx_la = matched_db[matched_db['treated_TX_LA'] == 0]

treated_al = matched_db[matched_db['treated_AL'] == 1]
control_al = matched_db[matched_db['treated_AL'] == 0]

treated_de = matched_db[matched_db['treated_DE'] == 1]
control_de = matched_db[matched_db['treated_DE'] == 0]

treated_sd = matched_db[matched_db['treated_SD'] == 1]
control_sd = matched_db[matched_db['treated_SD'] == 0]

treated_va = matched_db[matched_db['treated_VA'] == 1]
control_va = matched_db[matched_db['treated_VA'] == 0]

treated_nv = matched_db[matched_db['treated_NV'] == 1]
control_nv = matched_db[matched_db['treated_NV'] == 0]



# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']}
# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'sales_gr_mean', 'ltdebt_at_mean']}

# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'sales_gr_mean']}

# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'sales_gr_mean']}

# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean']}

smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

smds_al = {covariate: calculate_smd(treated_al, control_al, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

smds_de = {covariate: calculate_smd(treated_de, control_de, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

smds_sd = {covariate: calculate_smd(treated_sd, control_sd, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

smds_va = {covariate: calculate_smd(treated_va, control_va, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

smds_nv = {covariate: calculate_smd(treated_nv, control_nv, covariate) 
        for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean']}

# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'ltdebt_at_mean']}

# smds = {covariate: calculate_smd(treated_tx_la, control_tx_la, covariate) 
#         for covariate in ['capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean']}

smd_df = pd.DataFrame(list(smds.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()

smd_df = pd.DataFrame(list(smds_al.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()

smd_df = pd.DataFrame(list(smds_de.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()

smd_df = pd.DataFrame(list(smds_sd.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()

smd_df = pd.DataFrame(list(smds_va.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()

smd_df = pd.DataFrame(list(smds_nv.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Standardized Mean Differences of Covariates')
plt.xlabel('Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Changed from axhline to axvline
plt.xlim(-0.2, 1)
plt.show()


##############################################################
# Calculated the weighted standardized mean difference (SMD)
##############################################################

matched_db['weight_tx_la'] = matched_db.apply(lambda x: 1 / x['propensity_score_tx_la'] if x['treated_TX_LA'] == 1 else 1 / (1 - x['propensity_score_tx_la']), axis=1)

def weighted_mean(x, w):
    return np.sum(x * w) / np.sum(w)

def weighted_std(x, w):
    mean = weighted_mean(x, w)
    variance = np.sum(w * (x - mean) ** 2) / np.sum(w)
    return np.sqrt(variance)

def calculate_weighted_smd(group1, group2, covariate, weight_col):
    # Extract the covariate and weight
    x1 = group1[covariate]
    w1 = group1[weight_col]
    x2 = group2[covariate]
    w2 = group2[weight_col]

    # Calculate weighted means and standard deviations
    mean1 = weighted_mean(x1, w1)
    mean2 = weighted_mean(x2, w2)
    std1 = weighted_std(x1, w1)
    std2 = weighted_std(x2, w2)

    # Pooled standard deviation
    pooled_std = np.sqrt(((np.sum(w1) - 1) * std1**2 + (np.sum(w2) - 1) * std2**2) / (np.sum(w1) + np.sum(w2) - 2))

    # Calculate SMD
    smd = (mean1 - mean2) / pooled_std
    return smd

treated_tx_la = matched_db[matched_db['treated_TX_LA'] == 1]
control_tx_la = matched_db[matched_db['treated_TX_LA'] == 0]

# smds = {covariate: calculate_weighted_smd(treated_tx_la, control_tx_la, covariate, 'weight_tx_la') 
#         for covariate in ['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']}
smds = {covariate: calculate_weighted_smd(treated_tx_la, control_tx_la, covariate, 'weight_tx_la') 
        for covariate in ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'ceqq_mean', 'sales_gr_mean', 'ltdebt_at_mean']}

smd_df = pd.DataFrame(list(smds.items()), columns=['Covariate', 'SMD'])
smd_df.set_index('Covariate', inplace=True)
smd_df.plot(kind='barh', legend=False, color='skyblue')  # Added color for better visualization
plt.title('Weighted Standardized Mean Differences of Covariates')
plt.xlabel('Weighted Standardized Mean Difference')  # Changed from ylabel to xlabel
plt.axvline(x=0, color='red', linestyle='--')  # Use axvline since it's a horizontal plot
plt.show()

########################
# Vizualizing the data
########################

import seaborn as sns

# Propensity score distribution
# plt.figure(figsize=(10, 6))
# sns.histplot(matched_db['propensity_score_tx_la'], kde=True, stat="density", linewidth=0)
# plt.title('Distribution of Propensity Scores')
# plt.xlabel('Propensity Score')
# plt.ylabel('Density')
# plt.show()

# plt.figure(figsize=(10, 6))
# sns.histplot(matched_db['propensity_score_tx_la'], kde=True, stat="density", linewidth=0, binwidth=0.05)
# plt.xlim(0, 1)  # Ensuring the x-axis covers the range from 0 to 1
# plt.title('Distribution of Propensity Scores')
# plt.xlabel('Propensity Score')
# plt.ylabel('Density')
# plt.show()

plt.figure(figsize=(10, 6))
plt.hist(matched_db['propensity_score_tx_la'].dropna(), bins=20, density=True)
plt.title('Distribution of Propensity Scores')
plt.xlabel('Propensity Score')
plt.ylabel('Density')
plt.show()

summary_stats = matched_db['propensity_score_tx_la'].describe()
print(summary_stats)

print(matched_db['propensity_score_tx_la'].dtype)
print(matched_db['propensity_score_tx_la'].isna().sum())
print(np.isinf(matched_db['propensity_score_tx_la']).sum())
print(matched_db['propensity_score_tx_la'].sample(10))


print(matched_db['treated'].value_counts())
print(matched_db[matched_db['treated'] == 1]['GVKEY'].nunique())
print(matched_db[matched_db['treated'] == 0]['GVKEY'].nunique())

print(unique_quarter)
sorted_columns = sorted(db_did_na_clean.columns)
print(sorted_columns)
matched_db.columns
# print(matched_control['GVKEY'].nunique())
# print(db_did_clean['propensity_score'].describe())
# print(db_did_clean['year_q'].describe())

matched_db.shape

print(matched_db[['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']].describe())

