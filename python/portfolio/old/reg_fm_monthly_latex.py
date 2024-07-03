import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
betas = pd.read_feather('data/feather/df_reg_beta.feather') #from calc_beta.py

df = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1975 and ceqq > 0'))
# df.shape
df = (pd.merge(df, betas, how = 'left', on = ['GVKEY', 'year_month']))
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df['roe'] = df['niq'] / df['ceqq']
df['roa'] = df['niq'] / df['atq']
df = (df
      .assign(bm = df['ceqq']*1000 / (np.abs(df['PRC'])*df['SHROUT'])) #ceqq is in millions and shrout is in thousands
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      )

df['year_month'] = df['year_month'].dt.to_timestamp()
df.set_index(['GVKEY', 'year_month'], inplace=True)
df = (df
      .assign(ret_aux = 1 + df['RET'])
      .assign(ret_aux_lead1 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-1))
      .assign(ret_aux_lead2 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-2))
      .assign(ret_2mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']) - 1)
      .assign(ret_2mo_lead1 = lambda x: x.groupby('GVKEY')['ret_2mo'].shift(-1))
      .assign(ret_3mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']*x['ret_aux_lead2']) - 1)
      .assign(ret_3mo_lead1 = lambda x: x.groupby('GVKEY')['ret_3mo'].shift(-1))      
      .drop(columns=['ret_aux', 'ret_aux_lead1', 'ret_aux_lead2'])       
      )
# df[['RET', 'ret_aux', 'ret_aux_lead1', 'ret_aux_lead2', 'ret_3mo', 'ret_3mo_lead1']].head(50)

df['RET_lead1'] = df.groupby('GVKEY')['RET'].shift(-1)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['d_debt_at'] = df['debt_at'] - df['debt_at_lag1']
df['roe_lag1'] = df.groupby('GVKEY')['roe'].shift(1)
df['d_roe'] = df['roe'] - df['roe_lag1']

df_clean = df.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
df_clean_no_na = df_clean.dropna(subset=['d_debt_at', 'ret_2mo_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])

###################################
# Running Fama MacBeth regressions
###################################

dep_vars = ['RET_lead1', 'ret_2mo_lead1', 'ret_3mo_lead1']
# dep = df_clean_no_na['ret_2mo_lead1']*100
indep_vars = ['d_debt_at', 'ln_ceqq', 'roa', 'RET', 'beta', 'bm']

# Create a dictionary for variable labels
variable_labels = {
    'd_debt_at': 'Leverage Change',
    'ln_ceqq': 'Log of Equity',
    'roa': 'Return on Assets',
    'RET': 'Previous month return',
    'beta': 'Beta',
    'bm': 'Book to Market Ratio'
}

results = {}

for dep_var in dep_vars:
    dep = df_clean_no_na[dep_var] * 100
    indep = df_clean_no_na[indep_vars]
    mod = FamaMacBeth(dep, indep)
    res = mod.fit()
    results[dep_var] = res

# Extract coefficients and t-stats into a DataFrame
data = {'Variable': indep_vars}
for dep_var, res in results.items():
    coeffs = res.params.round(2).astype(str)
    tstats = res.tstats.round(2).astype(str)
    data[f'{dep_var}_Coeff'] = coeffs
    data[f'{dep_var}_t'] = tstats

dataframe = pd.DataFrame(data)

dataframe['Variable'] = dataframe['Variable'].map(variable_labels)

# Combine coefficients and t-stats into a single column per dependent variable
for dep_var in dep_vars:
    dataframe[dep_var] = dataframe[f'{dep_var}_Coeff'] + ' (' + dataframe[f'{dep_var}_t'] + ')'

# dataframe.head()

# Select only the relevant columns for the LaTeX table
df_latex = dataframe[['Variable'] + dep_vars]

# df_latex.head()

# Generate LaTeX table
latex_table = tabulate(df_latex, headers='keys', tablefmt='latex', showindex=False)

# Print LaTeX table
print(latex_table)