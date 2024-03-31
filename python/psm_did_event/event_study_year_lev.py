import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import statsmodels.formula.api as smf
import linearmodels as lm
import statsmodels.api as sm
import sys
sys.path.append('code/firm_invest/python/')
from data_functions import convert_to_datetime

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
df['eq_at'] = df['ceqq'] / df['atq']
df['year_q'] = df['year_q'].apply(convert_to_datetime)
df_tang = df[df['ter'] == 1].copy()
df_intan = df[df['ter'] == 3].copy()

# sorted_columns = sorted(df.columns) # to see columns names in alphabetical order (it is case sensitive)
# print(sorted_columns)

def log_change(data, col_name):
    data['d_' + col_name] = np.log(data[col_name] / data[col_name].shift(1))
    return data

# Aggregate the database by year
df_tang['category'] = df_tang['tercile'].apply(lambda x: 'Tangible' if x == 1 else ('Intangible' if x == 3 else 'other'))
df_tang['group'] = df_tang['treated'].map({1: 'Treated', 0: 'Control'})
# df_tang['debt_at_adj'] = df_tang['debt_at'] + np.finfo(float).eps
# df_tang = df_tang.groupby('GVKEY').apply(lambda x: log_change(x, 'debt_at_adj'))

# sorted_columns = sorted(df_tang.columns)
# print(df_tang['GVKEY'].nunique())   

df_year_tang = df_tang.groupby(['GVKEY', 'year']).agg({'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_year_tang['debt_at'].quantile(0.98)
df_year_tang_filtered = df_year_tang[(df_year_tang['year'] >= 1995) & (df_year_tang['year'] <= 1999) & (df_year_tang['category'] != 'other') & (df_year_tang['debt_at'] < percentile_98)]

# Aggregate the database by year
df_intan['category'] = df_intan['tercile'].apply(lambda x: 'Tangible' if x == 1 else ('Intangible' if x == 3 else 'other'))
df_intan['group'] = df_intan['treated'].map({1: 'Treated', 0: 'Control'})
# df_intan['debt_at_adj'] = df_intan['debt_at'] + np.finfo(float).eps
# df_intan = df_intan.groupby('GVKEY').apply(lambda x: log_change(x, 'debt_at_adj'))
df_year_intan = df_intan.groupby(['GVKEY', 'year']).agg({'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_year_intan['debt_at'].quantile(0.98)
df_year_intan_filtered = df_year_intan[(df_year_intan['year'] >= 1995) & (df_year_intan['year'] <= 1999) & (df_year_intan['category'] != 'other') & (df_year_intan['debt_at'] < percentile_98)]


########################################################################
# Print the debt issuance for 1997 and 1998 from df_year_tang_filtered #
########################################################################

#print(df_year_tang_filtered.loc[df_year_tang_filtered['year'].isin([1997])])
df_1997 = df_year_tang_filtered[df_year_tang_filtered['year'] == 1995]

# Sort the filtered DataFrame by the debt issuance column in descending order and select the top 5
top5_debt_issuance_1997 = df_1997.sort_values(by='debt_issuance', ascending=False).head(5)

# Print the top 5 observations
print(top5_debt_issuance_1997)

########################################################################    
########################################################################

# Create violin plots of debt issuance for tangible firms
plt.figure(figsize=(12, 6))
sns.violinplot(x='year', y='debt_at', hue = 'group', data=df_year_tang_filtered, split=True)
plt.title('Debt/assets by Year for Tangible Firms')
plt.xlabel('Years')
plt.ylabel('Debt/assets')
plt.show()
#plt.savefig('output/graphs/debt_issuance_violin.png')

# Create violin plots of debt issuance for intangible firms
plt.figure(figsize=(12, 6))
#ax = sns.violinplot(x='year', y='debt_issuance', hue = 'group', data=df_year_intan_filtered, split=True)
sns.violinplot(x='year', y='debt_at', hue = 'group', data=df_year_intan_filtered, split=True)
plt.title('Debt/assets by Year for Intangible Firms')
plt.xlabel('Years')
plt.ylabel('Debt/assets')
#ax.set_ylim(-10000, 20000)
plt.tight_layout()
plt.show()


#print(df_year.head())
#############################################
# Creating time dummies for the event study #
#############################################

event_year = 1997
# df_tang['year'] = pd.to_datetime(df_tang['year'])
# df_intan['year'] = pd.to_datetime(df_intan['year'])
df_tang['years_from_event'] = (df_tang['year'] - event_year)
df_intan['years_from_event'] = (df_intan['year'] - event_year)
percentile_98 = df_tang['debt_at'].quantile(0.98)
df_tang_trim = df_tang[df_tang['debt_at'] < percentile_98]

percentile_98 = df_intan['debt_at'].quantile(0.98)
df_intan_trim = df_intan[df_intan['debt_at'] < percentile_98]

#print(df_tang['years_from_event'].min())
      
# Filter to only include quarters within the 8-quarter window around the event
window_filter_tang = df_tang_trim['years_from_event'].between(-2, 2)
window_filter_intan = df_intan_trim['years_from_event'].between(-2, 2)

# Generate dummy variables for the filtered DataFrame
dummies_tang = pd.get_dummies(df_tang_trim.loc[window_filter_tang, 'years_from_event'], prefix='Y')
dummies_intan = pd.get_dummies(df_intan_trim.loc[window_filter_intan, 'years_from_event'], prefix='Y')

# Join the dummy variables back to the original DataFrame and replace missing values with zeros.
df_tang_trim = df_tang_trim.join(dummies_tang)
df_tang_trim[dummies_tang.columns] = df_tang_trim[dummies_tang.columns].fillna(0)
df_tang_treated = df_tang_trim[df_tang_trim['treated'] == 1]
df_tang_treated = df_tang_treated.set_index(['GVKEY', 'year'])

df_intan_trim = df_intan_trim.join(dummies_intan)
df_intan_trim[dummies_intan.columns] = df_intan_trim[dummies_intan.columns].fillna(0)
df_intan_treated = df_intan_trim[df_intan_trim['treated'] == 1]
df_intan_treated = df_intan_treated.set_index(['GVKEY', 'year'])

######################################################
#                   EVENT STUDY                     #
######################################################

#region Event study panel regression for tangible firms
df_tang_treated['lagged_debt_at'] = df_tang_treated.groupby('GVKEY')['debt_at'].shift(1)
df_tang_treated['lagged_debt_iss'] = df_tang_treated.groupby('GVKEY')['debt_issuance'].shift(1)
df_tang_treated['log_emp'] = df_tang_treated.groupby('GVKEY')['emp'].transform(lambda x: np.log(x))
df_tang_treated['log_at'] = df_tang_treated.groupby('GVKEY')['atq'].transform(lambda x: np.log(x))

X = df_tang_treated[['log_emp', 'lagged_debt_at', 'Y_-2', 'Y_-1', 'Y_0', 'Y_1', 'Y_2']] # Include all control and dummy variables here
X = sm.add_constant(X)  # Adds a constant term to the predictor
y = df_tang_treated['debt_at']
model_tang = lm.PanelOLS(y, X, entity_effects=True).fit()

# sorted_columns = sorted(df_tang_treated.columns) # to see columns names in alphabetical order (it is case sensitive)
# print(sorted_columns)



#region Event study panel regression for intangible firms
df_intan_treated['lagged_debt_at'] = df_intan_treated.groupby('GVKEY')['debt_at'].shift(1)
df_intan_treated['lagged_debt_iss'] = df_intan_treated.groupby('GVKEY')['debt_issuance'].shift(1)
df_intan_treated['log_emp'] = df_intan_treated.groupby('GVKEY')['emp'].transform(lambda x: np.log(x))
X_intan = df_intan_treated[['log_emp', 'lagged_debt_at', 'Y_-2', 'Y_-1', 'Y_0', 'Y_1', 'Y_2']] # Include all control and dummy variables here
X_intan = sm.add_constant(X_intan)  # Adds a constant term to the predictor
y_intan = df_intan_treated['debt_at']

model_intan = lm.PanelOLS(y_intan, X_intan, entity_effects=True).fit()

print(model_tang)
print(model_intan)


###############################################
#########         Latex tables      ###########
###############################################


# Save the results as a latex table
latex_table_intan = model_intan.summary().as_latex()
latex_table_tang = model_tang.summary().as_latex()

# print(latex_table)
with open('output/tex/did_intan.tex', 'w') as f:
    f.write(latex_table_intan)

with open('output/tex/did_tang.tex', 'w') as f:
    f.write(latex_table_tang)
#endregion

# Save the cleaned tables for both models
# save_latex_table(df_tang_formatted, 'output/tex/cleaned_did_tang.tex', 'Regression Results for Tangible Firms', 'tab:tangible_firms')
# save_latex_table(df_intan_formatted, 'output/tex/cleaned_did_intan.tex', 'Regression Results for Intangible Firms', 'tab:intangible_firms')



# print(df['post'].describe())
# # Print 'post' variable between 1996:Q1 and 1998:Q1
# print(df['post'].loc[(df['year_q'] > '1996Q1') & (df['year_q'] < '1998Q1')])
