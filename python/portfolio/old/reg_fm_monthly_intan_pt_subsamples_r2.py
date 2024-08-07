import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from report_functions import add_stars

# Read the data from the feather file
df = pd.read_feather('data/feather/df_intan_pt.feather') #from compustat_pt_merge.py
betas = pd.read_feather('data/feather/df_reg_beta.feather') #from calc_beta.py

df = (df
      .assign(year = df['date_ret'].dt.year)
      .query('year >= 1980 and ceqq > 0'))
# df.shape
df = (pd.merge(df, betas, how = 'left', on = ['GVKEY', 'year_month']))
df['debt_at'] = (df['dlttq'] + df['dlcq']) / df['atq']
df['intan_pt_at'] = df['intan_pt'] / df['atq']
df['roe'] = df['niq'] / df['ceqq']
df['roa'] = df['niq'] / df['atq']

# Change book-to-market ratio
df = (df
      .assign(ceqq_lag1 = df.groupby('GVKEY')['ceqq'].shift(1))
      .assign(bm = lambda x: x['ceqq_lag1']*1000 / (np.abs(x['PRC'])*x['SHROUT'])) #ceqq is in millions and shrout is in thousands
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      )

# df[['GVKEY', 'year_month', 'ceqq', 'ceqq_lag1', 'PRC', 'SHROUT', 'bm']].tail(50)

df['year_month'] = df['year_month'].dt.to_timestamp()
df.set_index(['GVKEY', 'year_month'], inplace=True)

df['terc_lev'] = df.groupby('year_month')['debt_at'].transform(
    lambda x: pd.qcut(x, 3, labels=['Low', 'Medium', 'High'])
)

# df['ter_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
#     lambda x: pd.qcut(x, 3, labels=[1, 2, 3]) 
# )

df['med_intan'] = pd.qcut(df['intan_pt_at'], 2, labels=[1, 2])
df['ter_intan'] = pd.qcut(df['intan_pt_at'], 3, labels=[1, 2, 3])
df['qua_intan'] = pd.qcut(df['intan_pt_at'], 4, labels=[1, 2, 3, 4])

df['quart_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
    lambda x: pd.qcut(x, 4, labels=[1, 2, 3, 4]) 
)

df['dec_intan'] = df.groupby('year_month')['intan_pt_at'].transform(
    lambda x: pd.qcut(x, 10, labels=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) 
)

# df[['intan_pt_at', 'quart_intan']].head(50)
df_new = (df
      .assign(ret_aux = 1 + df['RET'])
      .assign(ret_aux_lead1 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-1))
      .assign(ret_aux_lead2 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-2))
      .assign(ret_2mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']) - 1)
      .assign(ret_2mo_lead1 = lambda x: x.groupby('GVKEY')['ret_2mo'].shift(-1))
      .assign(ret_3mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']*x['ret_aux_lead2']) - 1)
      .assign(ret_3mo_lead1 = lambda x: x.groupby('GVKEY')['ret_3mo'].shift(-1))
      .assign(hlev = lambda x: x['terc_lev'] == 'High')
      .assign(llev = lambda x: x['terc_lev'] == 'Low')
      .assign(hint = lambda x: x['qua_intan'] == 4)
      .assign(lint = lambda x: x['qua_intan'] == 1)                
      .drop(columns=['ret_aux', 'ret_aux_lead1', 'ret_aux_lead2'])       
      )

#df_new[['RET', 'ret_aux', 'ret_aux_lead1', 'ret_aux_lead2', 'ret_3mo', 'ret_3mo_lead1']].head(50)
# df_new[['hint', 'quart_intan']][df_new['quart_intan'] == 4].tail(50)
df_int = df_new.query('lint == True')

df_int['RET_lead1'] = df_int.groupby('GVKEY')['RET'].shift(-1)
df_int['debt_at_lag1'] = df_int.groupby('GVKEY')['debt_at'].shift(1)
df_int['d_debt_at'] = df_int['debt_at'] - df_int['debt_at_lag1']
df_int['roe_lag1'] = df_int.groupby('GVKEY')['roe'].shift(1)
df_int['d_roe'] = df_int['roe'] - df_int['roe_lag1']
#df_int['dummyXdebt_at'] = df_int['debt_at'] * df_int['lint']

df_clean = df_int.copy()
df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
# df_reset = df_clean.reset_index()
# df_clean_no_na = df_reset.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])
# df_clean_no_na['year_month'].nunique()
# df_clean_no_na['year_month'].max()
# save = df_clean.to_feather('data/feather/df_fm.feather')

###################################
# Running Fama MacBeth regressions
###################################

dep_vars = ['RET_lead1', 'ret_2mo_lead1', 'ret_3mo_lead1']
# dep = df_clean_no_na['ret_2mo_lead1']*100
indep_vars = ['d_debt_at', 'ln_ceqq', 'roa', 'RET', 'beta']

# Create a dictionary for variable labels
variable_labels = {
    'd_debt_at': 'Leverage Change',
    'debt_at': 'Leverage',
    'dummyXd_debt_at': 'Low intan/at X Leverage Change',
    'dummyXdebt_at': 'Low intan/at X Leverage',    
    'hlev': 'High Leverage dummy',    
    'llev': 'Low Leverage dummy',
    'hint': 'High intangible/assets dummy',
    'lint': 'Low intangible/assets dummy',
    'ln_ceqq': 'Log of Equity',
    'roa': 'Return on Assets',
    'RET': 'Previous month return',
    'beta': 'Beta',
    'bm': 'Book-to-Market Ratio'
}

results = {}
obs_counts = {}
firm_counts = {}
r_squared = {}

for dep_var in dep_vars:
    df_clean_no_na = df_clean.dropna(subset=[dep_var] + indep_vars)
    dep = df_clean_no_na[dep_var] * 100
    indep = df_clean_no_na[indep_vars]
    mod = FamaMacBeth(dep, indep)
    res = mod.fit()
    results[dep_var] = res
    obs_counts[dep_var] = res.nobs
    df_reset = df_clean_no_na.reset_index()
    firm_counts[dep_var] = df_reset['GVKEY'].nunique()
    r_squared[dep_var] = res.rsquared

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

# Add rows for number of observations, number of unique firms, and R-squared
obs_firms_data = [
    ['Observations'] + [obs_counts[dep_var] for dep_var in dep_vars],
    ['Number of Firms'] + [firm_counts[dep_var] for dep_var in dep_vars],
    ['R-squared'] + [round(r_squared[dep_var], 3) for dep_var in dep_vars]
]

# Combine all rows
all_rows = rows + obs_firms_data

# Generate LaTeX table
latex_table = tabulate(all_rows, headers=['Variable'] + dep_vars, tablefmt='latex_raw', showindex=False)

# Print LaTeX table
print(latex_table)