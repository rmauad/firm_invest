import pandas as pd
import statsmodels.formula.api as smf
import statsmodels.api as sm
import numpy as np

df = pd.read_csv('data/csv/psm_clean.csv')
df_tang = df[df['ter'] == 1].copy()
df_intan = df[df['ter'] == 3].copy()

# Creating delta leverage
def log_change(data, col_name):
    data['d_' + col_name] = np.log(data[col_name] / data[col_name].shift(1))
    return data

# Aggregate the database by year
df_tang['debt_iss_adj'] = df_tang['debt_issuance'] + np.finfo(float).eps
df_tang = df_tang.groupby('GVKEY').apply(lambda x: log_change(x, 'debt_iss_adj'))
#df_year_tang = df_tang.groupby(['GVKEY', 'year']).agg({'d_debt_at_adj': 'sum', 'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_tang['d_debt_iss_adj'].quantile(0.98)
df_tang_trim = df_tang[df_tang['d_debt_iss_adj'] < percentile_98]

# Create a dummy 'post' for periods after 1997:Q1
df_tang_trim['post'] = (df_tang_trim['year_q'] > '1997Q2').astype(int)
df_tang_trim['treatment_post'] = df_tang_trim['treated'] * df_tang_trim['post']
df_intan['post'] = (df_intan['year_q'] > '1997Q1').astype(int)
df_intan['treatment_post'] = df_intan['treated'] * df_intan['post']

#region DiD for tangible firms
model_tang = smf.ols('d_debt_iss_adj ~ treated + post + treatment_post', data=df_tang_trim).fit()
model_intan = smf.ols('d_debt_iss_adj ~ treated + post + treatment_post', data=df_intan).fit()

print(model_tang.summary())
# Print the min and max quarter for df_tang
print(df_tang['year_q'].max())

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
