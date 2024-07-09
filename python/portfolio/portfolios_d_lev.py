import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from report_functions import add_stars

df = pd.read_feather('data/feather/df_fm.feather') #from prep_fm.py

################################################################
# Building porfolios based on debt/assets and intangible/assets
################################################################

smallest_non_zero = df.loc[df['d_lev'] > 0, 'd_lev'].min()
print(smallest_non_zero)
epsilon = np.random.uniform(0, smallest_non_zero * 0.1, size=len(df))

smallest_non_zero_lev = df.loc[df['lev'] > 0, 'lev'].min()
print(smallest_non_zero_lev)
epsilon_lev = np.random.uniform(0, smallest_non_zero_lev * 0.1, size=len(df))


# Replace zeros with these small random numbers (otherwise, qcut will not work)
df['d_lev_adj'] = df['d_lev']
df['lev_adj'] = df['lev']
df.loc[df['d_lev'] == 0, 'd_lev_adj'] = epsilon[df['d_lev'] == 0]
df.loc[df['lev'] == 0, 'lev_adj'] = epsilon_lev[df['lev'] == 0]

# df.head(50)

df['qui_d_lev'] = df.groupby('year_month')['d_lev_adj'].transform(
    lambda x: pd.qcut(x, 5, labels=[1, 2, 3, 4, 5])
)

df['qui_lev'] = df.groupby('year_month')['lev_adj'].transform(
    lambda x: pd.qcut(x, 5, labels=[1, 2, 3, 4, 5])
)

grouped = df.groupby(['year_month', 'qui_lev', 'qui_d_lev'])

# Computing the Average Return for Each Group
monthly_avg_returns = grouped['RET'].mean().reset_index()

# Compute the Average Across All Months
overall_avg_returns = monthly_avg_returns.groupby(['qui_lev', 'qui_d_lev'])['RET'].mean().reset_index()

# pivot_df = overall_avg_returns.pivot(index='qui_d_debt_at', columns='qua_intan', values='ret_3mo_lead1')
pivot_df = overall_avg_returns.pivot(index='qui_d_lev', columns='qui_lev', values='RET')

# Calculate the difference between the first and fifth rows
difference_row = pivot_df.iloc[0] - pivot_df.iloc[4]
difference_row.name = '1-5 Difference'

# Step 7: Append the difference row to the pivoted DataFrame
pivot_df = pivot_df._append(difference_row)

print(pivot_df)

#import ace_tools as tools; tools.display_dataframe_to_user(name="Overall Average Returns by Portfolio", dataframe=overall_avg_returns)
# from IPython.display import display
# display(overall_avg_returns)

#df_int['dummyXdebt_at'] = df_int['debt_at'] * df_int['lint']

# df_clean = df_int.copy()
# df_clean['ln_ceqq'] = df_clean['ln_ceqq'].replace([np.inf, -np.inf], np.nan)
# df_clean['d_debt_at'] = df_clean['d_debt_at'].replace([np.inf, -np.inf], np.nan)
# df_clean['d_roe'] = df_clean['d_roe'].replace([np.inf, -np.inf], np.nan)
# df_reset = df_clean.reset_index()
# df_clean_no_na = df_reset.dropna(subset=['d_debt_at', 'RET_lead1', 'ln_ceqq', 'roa', 'beta', 'bm'])
# df_clean_no_na['year_month'].nunique()
# df_clean_no_na['year_month'].max()
# save = df_clean.to_feather('data/feather/df_fm.feather')

####################################################
# Generate portfolios and compute average returns
####################################################

# df['portfolio'] = df['qui_d_debt_at'].astype(str) + '-' + df['qua_intan'].astype(str)

