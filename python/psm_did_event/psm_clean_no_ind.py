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
db_did = pd.read_csv('data/csv/db_did_no_ind.csv') # created by prep_db_did_no_ind.py

# Generating variables "debt issuance"
db_did['debt_issuance'] = db_did['dltisy'] - db_did['dltry'] + db_did['dlcchy']

# drop nas based on debt_issuance
db_did_na_clean = db_did.dropna(subset = ['debt_issuance'])

# Select firms in the states of TX and LA
db_did_na_clean['intan_at'] = db_did_na_clean['org_cap_comp'] / db_did_na_clean['atq']
db_did_na_clean['ter'] = db_did_na_clean.groupby(['year_q'])['intan_at'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))

# Generate a dummy = 1 for firms in TX and LA
db_did_na_clean['treated'] = 0
db_did_na_clean.loc[(db_did_na_clean['state'] == 'TX') | (db_did_na_clean['state'] == 'LA'), 'treated'] = 1

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
metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']
filtered_db = db_did_na_clean[db_did_na_clean['year_q'] < '1996Q4']
mean_values = filtered_db.groupby('GVKEY')[metrics].mean()
db_did_merge = db_did_na_clean.merge(mean_values, on='GVKEY', how='left', suffixes=('', '_mean'))

#region Generate the propensity score
from sklearn.linear_model import LogisticRegression
metrics_mean = ['dln_inv_mean', 'capxy_mean', 'atq_mean', 'debt_at_mean', 'cash_at_mean', 'tobin_q_mean']
db_did_clean = db_did_merge.dropna(subset=metrics_mean).copy() # .copy() guarantees that a new independent dataframe is created
X = db_did_clean[metrics_mean]  # the financial metrics
y = db_did_clean['treated']  # treatment indicator

logistic = LogisticRegression()
logistic.fit(X, y)
db_did_clean.loc[:, 'propensity_score'] = logistic.predict_proba(X)[:, 1]

# Matching the treated and control groups
from sklearn.neighbors import NearestNeighbors

treatment = db_did_clean[db_did_clean['treated'] == 1]
control = db_did_clean[db_did_clean['treated'] == 0]
#print unique firms in the treatment and control groups
print(treatment['GVKEY'].nunique())
print(control['GVKEY'].nunique())

#endregion

# Initialize an empty list to hold the matched DataFrames
matched_pairs_list = []

# Get unique time periods
unique_quarter = np.sort(db_did_clean['year_q'].unique())

for quarter in unique_quarter:
    # Filter treatment and control groups for the current time period
    treatment_period = db_did_clean[(db_did_clean['treated'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period = db_did_clean[(db_did_clean['treated'] == 0) & (db_did_clean['year_q'] == quarter)]

    # Perform matching if both treatment and control groups are non-empty
    if not treatment_period.empty and not control_period.empty:
        nn = NearestNeighbors(n_neighbors=2, algorithm='ball_tree').fit(control_period[['propensity_score']])
        distances, indices = nn.kneighbors(treatment_period[['propensity_score']])
        
        # Using indices to select matched controls. Ensure indices are used to index within the filtered control DataFrame
        matched_control = control_period.iloc[indices.flatten()]
        
        # Combine the current period's treatment and matched control
        matched_pairs = pd.concat([treatment_period, matched_control])
        
        # Append the combined DataFrame to the list
        matched_pairs_list.append(matched_pairs)

# Concatenate all matched pairs across time periods
matched_db = pd.concat(matched_pairs_list)

# Save the database
matched_db.to_csv('data/csv/psm_clean_no_ind.csv', index=False)

print(matched_db['treated'].value_counts())
print(matched_db[matched_db['treated'] == 1]['GVKEY'].nunique())
print(matched_db[matched_db['treated'] == 0]['GVKEY'].nunique())

print(unique_quarter)
matched_db.columns
# print(matched_control['GVKEY'].nunique())
# print(db_did_clean['propensity_score'].describe())
# print(db_did_clean['year_q'].describe())


