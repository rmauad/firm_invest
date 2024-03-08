# This code runs a propensity score matching to get a control group for firms in TX and LA

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/jmp_github/python/')
from data_functions import convert_to_datetime

# Load the data
db_did = pd.read_csv('data/csv/db_did.csv')
# db_did['date'] = db_did['year_q'].apply(convert_to_datetime)
# db_did['date'] = pd.to_datetime(db_did['date'])

# Generating variables "debt issuance"
db_did['debt_issuance'] = db_did['dltisy'] - db_did['dltry'] + db_did['dlcchy']

# drop nas based on debt_issuance
db_did_clean = db_did.dropna(subset = ['debt_issuance'])

# Select firms in the states of TX and LA
db_did['intan_at'] = db_did['org_cap_comp'] / db_did['atq']
db_did['ter'] = db_did.groupby(['year_q'])['intan_at'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
#db_did['ter'] = pd.qcut(db_did['intan_at'], 3, labels = [1, 2, 3])

# Generate a dummy = 1 for firms in TX and LA
db_did['treated'] = 0
db_did.loc[(db_did['state'] == 'TX') | (db_did['state'] == 'LA'), 'treated'] = 1


# Generate the metrics to be used in the PSM 
# (average of investment growth, investment level, 
# size, leverage, cash/assets ratio, and Tobin's Q )

# Generate the log change between quarters for each firm

db_did['dln_inv'] = db_did.groupby(['GVKEY'])['capxy'].transform(lambda x: np.log(x) - np.log(x.shift(1)))
# db_did['dln_inv'] = db_did['dln_inv'].apply(lambda x: x if x < 1 else 1)
# db_did['dln_inv'] = db_did['dln_inv'].apply(lambda x: x if x > -1 else -1)
db_did['dln_inv'] = db_did['dln_inv'].apply(lambda x: x if x != float('inf') else 0)
db_did['dln_inv'] = db_did['dln_inv'].apply(lambda x: x if x != float('-inf') else 0)
db_did['dln_inv'] = db_did['dln_inv'].apply(lambda x: x if x != float('nan') else 0)


# Generate Tobin's Q
db_did['tobin_q'] = ((db_did['cshoq']*db_did['prccq']) + db_did['atq'] - db_did['ceqq']) / db_did['atq']

# Generate the average of the metrics by quarter (before 1997:Q1)
metrics = ['dln_inv', 'capxy', 'atq', 'debt_at', 'cash_at', 'tobin_q']
filtered_db = db_did[db_did['year_q'] < '1996Q4']
mean_values = filtered_db.groupby('GVKEY')[metrics].mean()
db_did_merge = db_did.merge(mean_values, on='GVKEY', how='left', suffixes=('', '_mean'))

# %% Generate the propensity score
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


nn = NearestNeighbors(n_neighbors=1, algorithm='ball_tree').fit(control[['propensity_score']])
distances, indices = nn.kneighbors(treatment[['propensity_score']])

matched_control = control.iloc[indices.flatten()]
matched_db = pd.concat([treatment, matched_control])


# Initialize an empty list to hold the matched DataFrames
matched_pairs_list = []

# Get unique time periods
unique_quarter = db_did_clean['year_q'].unique()

for quarter in unique_quarter:
    # Filter treatment and control groups for the current time period
    treatment_period = db_did_clean[(db_did_clean['treated'] == 1) & (db_did_clean['year_q'] == quarter)]
    control_period = db_did_clean[(db_did_clean['treated'] == 0) & (db_did_clean['year_q'] == quarter)]

    # Perform matching if both treatment and control groups are non-empty
    if not treatment_period.empty and not control_period.empty:
        nn = NearestNeighbors(n_neighbors=1, algorithm='ball_tree').fit(control_period[['propensity_score']])
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
matched_db.to_csv('data/csv/psm.csv', index=False)


print(treatment['GVKEY'].nunique())

treatment1 = matched_db[matched_db['treated'] == 1]
control1 = matched_db[matched_db['treated'] == 0]
print(treatment1.shape)

print(control1['GVKEY'].nunique())
# print(db_did_clean['propensity_score'].describe())
# print(db_did_clean['year_q'].describe())


