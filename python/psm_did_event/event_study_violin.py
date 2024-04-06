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
df['intan_top'] = df['ter'].apply(lambda x: 1 if x == 3 else 0)
df_tang = df[df['ter'] == 1].copy()
df_intan = df[df['ter'] == 3].copy()

def log_change(data, col_name):
    data['d_' + col_name] = np.log(data[col_name] / data[col_name].shift(1))
    return data

# Tangible
df_tang['category'] = df_tang['tercile'].apply(lambda x: 'Tangible' if x == 1 else ('Intangible' if x == 3 else 'other'))
df_tang['group'] = df_tang['treated'].map({1: 'Treated', 0: 'Control'})
df_year_tang = df_tang.groupby(['GVKEY', 'year']).agg({'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_year_tang['debt_at'].quantile(0.98)
df_year_tang_filtered = df_year_tang[(df_year_tang['year'] >= 1995) & (df_year_tang['year'] <= 1999) & (df_year_tang['category'] != 'other') & (df_year_tang['debt_at'] < percentile_98)]

# Intangible
df_intan['category'] = df_intan['tercile'].apply(lambda x: 'Tangible' if x == 1 else ('Intangible' if x == 3 else 'other'))
df_intan['group'] = df_intan['treated'].map({1: 'Treated', 0: 'Control'})
df_year_intan = df_intan.groupby(['GVKEY', 'year']).agg({'debt_at': 'mean', 'category': 'first', 'group': 'first'}).reset_index()
percentile_98 = df_year_intan['debt_at'].quantile(0.98)
df_year_intan_filtered = df_year_intan[(df_year_intan['year'] >= 1995) & (df_year_intan['year'] <= 1999) & (df_year_intan['category'] != 'other') & (df_year_intan['debt_at'] < percentile_98)]



########################################################################  
  # Create violin plots of leverage for tangible and intangible firms
########################################################################

# Tangible firms
plt.figure(figsize=(12, 6))
sns.violinplot(x='year', y='debt_at', hue = 'group', data=df_year_tang_filtered, split=True)
plt.title('Debt/assets by Year for Tangible Firms')
plt.xlabel('Years')
plt.ylabel('Debt/assets')
plt.show()
#plt.savefig('output/graphs/debt_issuance_violin.png')

# Intangible firms
plt.figure(figsize=(12, 6))
#ax = sns.violinplot(x='year', y='debt_issuance', hue = 'group', data=df_year_intan_filtered, split=True)
sns.violinplot(x='year', y='debt_at', hue = 'group', data=df_year_intan_filtered, split=True)
plt.title('Debt/assets by Year for Intangible Firms')
plt.xlabel('Years')
plt.ylabel('Debt/assets')
#ax.set_ylim(-10000, 20000)
plt.tight_layout()
plt.show()

