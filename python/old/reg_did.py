import pandas as pd
import statsmodels.formula.api as smf
import statsmodels.api as sm

df = pd.read_csv('data/csv/psm_clean.csv')
df_tang = df[df['ter'] == 1].copy()
df_intan = df[df['ter'] == 3].copy()

# Create a dummy 'post' for periods after 1997:Q1
df_tang['post'] = (df_tang['year_q'] > '1997Q1').astype(int)
df_tang['treatment_post'] = df_tang['treated'] * df_tang['post']
df_intan['post'] = (df_intan['year_q'] > '1997Q1').astype(int)
df_intan['treatment_post'] = df_intan['treated'] * df_intan['post']

#region DiD for tangible firms
model_tang = smf.ols('debt_issuance ~ treated + post + treatment_post', data=df_tang).fit()
model_intan = smf.ols('debt_issuance ~ treated + post + treatment_post', data=df_intan).fit()

#print(model_tang.summary())

###############################################
#########         Latex tables      ###########
###############################################

import sys
sys.path.append('code/firm_invest/python/functions/')
import tables

# Format summaries for both models
df_tang_formatted = tables.format_model_summary(model_tang)
df_intan_formatted = tables.format_model_summary(model_intan)

# Save the results as a latex table
latex_table = model_tang.summary().as_latex()
# print(latex_table)
with open('output/tex/did_tang.tex', 'w') as f:
    f.write(latex_table)
#endregion

#region DiD for intangible firms
model_intan = smf.ols('debt_issuance ~ treated + post + treatment_post', data=df_intan).fit()
#print(model_intan.summary())

# Save the results as a latex table
latex_table_intan = model_intan.summary().as_latex()
# print(latex_table)
with open('output/tex/did_intan.tex', 'w') as f:
    f.write(latex_table_intan)
#endregion

# Save the cleaned tables for both models
# save_latex_table(df_tang_formatted, 'output/tex/cleaned_did_tang.tex', 'Regression Results for Tangible Firms', 'tab:tangible_firms')
# save_latex_table(df_intan_formatted, 'output/tex/cleaned_did_intan.tex', 'Regression Results for Intangible Firms', 'tab:intangible_firms')



# print(df['post'].describe())
# # Print 'post' variable between 1996:Q1 and 1998:Q1
# print(df['post'].loc[(df['year_q'] > '1996Q1') & (df['year_q'] < '1998Q1')])
