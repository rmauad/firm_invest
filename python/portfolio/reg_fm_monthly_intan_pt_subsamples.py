import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from report_functions import add_stars

# Read the data from the feather file
df = pd.read_feather('data/feather/df_fm.feather') #from prep_fm.py
# df_test = df.dropna(subset=['lev'])
# df.shape
# df_test.shape
###################################
# Running Fama MacBeth regressions
###################################

dep_vars = ['RET_lead1', 'ret_2mo_lead1', 'ret_3mo_lead1']
# dep = df_clean_no_na['ret_2mo_lead1']*100
# indep_vars = ['d_lev', 'lev', 'beta', 'ln_me', 'bm', 'roe', 'one_year_cum_return', 'RET']
#indep_vars = ['d_debt_at', 'debt_at', 'beta', 'ln_me', 'bm', 'roe', 'one_year_cum_return', 'RET']
#indep_vars = ['d_ln_debt_at', 'ln_ceqq', 'roa', 'RET', 'beta']
#indep_vars = ['d_debt_at', 'ln_ceqq', 'roa', 'RET', 'beta']
indep_vars = ['d_ln_debt_at', 'ln_ceqq', 'roa', 'RET', 'bm']

# Create a dictionary for variable labels
variable_labels = {
    'd_debt_at': 'Debt/assets Change',
    'd_ln_debt_at': 'Debt/assets log change',
    'debt_at': 'Debt/assets',
    'd_ln_lev': 'Leverage log change',
    'd_lev': 'Leverage Change',
    'lev': 'Leverage',
    'dummyXd_debt_at': 'Low intan/at X Leverage Change',
    'dummyXdebt_at': 'Low intan/at X Leverage',    
    'hlev': 'High Leverage dummy',    
    'llev': 'Low Leverage dummy',
    'hint': 'High intangible/assets dummy',
    'lint': 'Low intangible/assets dummy',
    'ln_ceqq': 'Log Equity',
    'ln_me': 'Log Market Value of Equity',
    'ln_at': 'Log Assets',
    'd_roe': 'Return on Equity Change',
    'roe': 'Return on Equity',    
    'roa': 'Return on Assets',
    'one_year_cum_return': 'Previous one-year return',
    'RET': 'Previous month return',
    'beta': 'Beta',
    'bm': 'Book-to-Market Ratio'
}

results = {}
obs_counts = {}
firm_counts = {}

for dep_var in dep_vars:
    df_clean_no_na = df.dropna(subset=[dep_var] + indep_vars)
    dep = df_clean_no_na[dep_var] * 100
    indep = df_clean_no_na[indep_vars]
    mod = FamaMacBeth(dep, indep)
    res = mod.fit()
    results[dep_var] = res
    obs_counts[dep_var] = res.nobs
    df_reset = df_clean_no_na.reset_index()
    firm_counts[dep_var] = df_reset['GVKEY'].nunique()

# Extract coefficients and t-stats into a DataFrame
data = {'Variable': indep_vars}
for dep_var, res in results.items():
    coeffs = res.params.round(2).astype(str) + res.tstats.apply(add_stars)
    tstats = res.tstats.round(2).astype(str)
    data[f'{dep_var}_Coeff'] = coeffs
    data[f'{dep_var}_t'] = tstats

dataframe = pd.DataFrame(data)
dataframe['Variable'] = dataframe['Variable'].map(variable_labels)

# Generate rows for coefficients and t-stats
rows = []
for _, row in dataframe.iterrows():
    rows.append([row['Variable']] + [row[f'{dep_var}_Coeff'] for dep_var in dep_vars])
    rows.append([''] + [f"({row[f'{dep_var}_t']})" for dep_var in dep_vars])

# Add rows for number of observations and number of unique firms
obs_firms_data = [
    ['Observations'] + [obs_counts[dep_var] for dep_var in dep_vars],
    ['Number of Firms'] + [firm_counts[dep_var] for dep_var in dep_vars]
]

# Combine all rows
all_rows = rows + obs_firms_data

# Generate LaTeX table
latex_table = tabulate(all_rows, headers=['Variable'] + dep_vars, tablefmt='latex_raw', showindex=False)

# Print LaTeX table
print(latex_table)