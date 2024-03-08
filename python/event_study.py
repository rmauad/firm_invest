import pandas as pd
import statsmodels.formula.api as smf
import linearmodels as lm
import statsmodels.api as sm
import sys
sys.path.append('code/firm_invest/python/')
from data_functions import convert_to_datetime

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
df['year_q'] = df['year_q'].apply(convert_to_datetime)
df_tang = df[df['ter'] == 1].copy()
df_intan = df[df['ter'] == 3].copy()

#############################################
# Creating time dummies for the event study #
#############################################

event_quarter = pd.to_datetime('1997-01-01')
df_tang['quarters_from_event'] = ((df_tang['year_q'] - event_quarter).dt.days / (365.25 / 4)).round().astype(int)
df_intan['quarters_from_event'] = ((df_intan['year_q'] - event_quarter).dt.days / (365.25 / 4)).round().astype(int)

# Filter to only include quarters within the 8-quarter window around the event
window_filter = df_tang['quarters_from_event'].between(-8, 8)
window_filter_intan = df_intan['quarters_from_event'].between(-8, 8)

# Generate dummy variables for the filtered DataFrame
dummies = pd.get_dummies(df_tang.loc[window_filter, 'quarters_from_event'], prefix='Q')
dummies_intan = pd.get_dummies(df_intan.loc[window_filter_intan, 'quarters_from_event'], prefix='Q')

# Join the dummy variables back to the original DataFrame and replace missing values with zeros.
df_tang = df_tang.join(dummies)
df_tang[dummies.columns] = df_tang[dummies.columns].fillna(0)
df_tang_treated = df_tang[df_tang['treated'] == 1]
df_tang_treated = df_tang_treated.set_index(['GVKEY', 'year_q'])

df_intan = df_intan.join(dummies_intan)
df_intan[dummies.columns] = df_intan[dummies.columns].fillna(0)
df_intan_treated = df_intan[df_intan['treated'] == 1]
df_intan_treated = df_intan_treated.set_index(['GVKEY', 'year_q'])

######################################################
# PLAY WITH THE MODEL SPECIFICATION ##################
######################################################
# INCLUDE TIME FE, TRY VARIABLES IN CHANGE, THINK ABOUT THE CONTROL VARIABLES, ETC

#region Event study panel regression for tangible firms
X = df_tang_treated[['ceqq','Q_-8', 'Q_-7', 'Q_-6', 'Q_-5', 'Q_-4', 'Q_-3', 'Q_-2', 'Q_-1', 'Q_0',
             'Q_1', 'Q_2', 'Q_3', 'Q_4', 'Q_5', 'Q_6', 'Q_7', 'Q_8']] # Include all control and dummy variables here
X = sm.add_constant(X)  # Adds a constant term to the predictor
y = df_tang_treated['debt_issuance']

model_tang = lm.PanelOLS(y, X, entity_effects=True).fit()

#region Event study panel regression for intangible firms
X_intan = df_intan_treated[['ceqq','Q_-8', 'Q_-7', 'Q_-6', 'Q_-5', 'Q_-4', 'Q_-3', 'Q_-2', 'Q_-1', 'Q_0',
             'Q_1', 'Q_2', 'Q_3', 'Q_4', 'Q_5', 'Q_6', 'Q_7', 'Q_8']] # Include all control and dummy variables here
X_intan = sm.add_constant(X_intan)  # Adds a constant term to the predictor
y_intan = df_intan_treated['debt_issuance']

model_intan = lm.PanelOLS(y_intan, X_intan, entity_effects=True).fit()

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
