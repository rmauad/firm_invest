import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import statsmodels.formula.api as smf
import linearmodels as lm
import statsmodels.api as sm
import sys
sys.path.append('code/firm_invest/python/psm_did_event/')
from data_functions import convert_to_datetime

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
df['eq_at'] = df['ceqq'] / df['atq']
df['year_q'] = df['year_q'].apply(convert_to_datetime)

# Create a dummy to flag tercile 3
df['dummy_intan'] = df['ter'].apply(lambda x: 1 if x == 3 else 0)
df['dummy_tang'] = df['ter'].apply(lambda x: 1 if x == 1 else 0)
# df_tang = df[df['ter'] == 1].copy()
# df_intan = df[df['ter'] == 3].copy()


# def log_change(data, col_name):
#     data['d_' + col_name] = np.log(data[col_name] / data[col_name].shift(1))
#     return data

# Aggregate the database by year
df['category'] = df['tercile'].apply(lambda x: 'Tangible' if x == 1 else ('Intangible' if x == 3 else 'other'))
df['group'] = df['treated'].map({1: 'Treated', 0: 'Control'})
df_year = df.groupby(['GVKEY', 'year']).agg({'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_year['debt_at'].quantile(0.98)
df_year_filtered = df_year[(df_year['year'] >= 1995) & (df_year['year'] <= 1999) & (df_year['category'] != 'other') & (df_year['debt_at'] < percentile_98)]


#############################################
# Creating time dummies for the event study #
#############################################

event_year = 1997
#df['year'] = pd.to_datetime(df['year'])
#event_year_datetime = pd.to_datetime(str(event_year))
df['years_from_event'] = (df['year'] - event_year)
percentile_98 = df_year_filtered['debt_at'].quantile(0.98)
df_trim = df[df['debt_at'] < percentile_98].copy()
window_filter = df_trim['years_from_event'].between(-2, 2)
dummies = pd.get_dummies(df_trim.loc[window_filter, 'years_from_event'], prefix='Y')

# Join the dummy variables back to the original DataFrame and replace missing values with zeros.
df_trim = df_trim.join(dummies)
df_trim[dummies.columns] = df_trim[dummies.columns].fillna(0)
df_treated = df_trim[df_trim['treated'] == 1]
df_treated = df_treated.set_index(['GVKEY', 'year'])

######################################################
#                   EVENT STUDY                     #
######################################################

#region Event study panel regression
df_treated['lagged_debt_at'] = df_treated.groupby('GVKEY')['debt_at'].shift(1)
df_treated['lagged_debt_iss'] = df_treated.groupby('GVKEY')['debt_issuance'].shift(1)
df_treated['log_emp'] = df_treated.groupby('GVKEY')['emp'].transform(lambda x: np.log(x))
df_treated['log_at'] = df_treated.groupby('GVKEY')['atq'].transform(lambda x: np.log(x))

X = df_treated[['log_emp', 'lagged_debt_at', 'dummy_tang', 'Y_-2', 'Y_-1', 'Y_0', 'Y_1', 'Y_2']] # Include all control and dummy variables here
X['tang_Y_-2'] = X['Y_-2']*X['dummy_tang']
X['tang_Y_-1'] = X['Y_-1']*X['dummy_tang']
X['tang_Y_0'] = X['Y_0']*X['dummy_tang']
X['tang_Y_1'] = X['Y_1']*X['dummy_tang']
X['tang_Y_2'] = X['Y_2']*X['dummy_tang']
X = sm.add_constant(X)  # Adds a constant term to the predictor
y = df_treated['debt_at']
model = lm.PanelOLS(y, X, entity_effects=True).fit()

print(model)
#endregion

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
