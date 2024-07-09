import pandas as pd
import numpy as np
from linearmodels.panel.model import FamaMacBeth
import statsmodels.api as sm
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
df_new = (df
      .assign(ceqq_lag1 = df.groupby('GVKEY')['ceqq'].shift(1))
      .assign(bm = lambda x: x['ceqq_lag1']*1000 / (np.abs(x['PRC'])*x['SHROUT'])) #ceqq is in millions and shrout is in thousands
      .assign(ln_ceqq = np.log(df['ceqq']))
      .assign(RET = pd.to_numeric(df['RET'], errors='coerce'))
      .assign(year_month = df['date_ret'].dt.to_period('M'))
      )

# df[['GVKEY', 'year_month', 'ceqq', 'ceqq_lag1', 'PRC', 'SHROUT', 'bm']].tail(50)

df_new['year_month'] = df_new['year_month'].dt.to_timestamp()
df_new.set_index(['GVKEY', 'year_month'], inplace=True)

df_new['qua_intan'] = df_new.groupby('year_month')['intan_pt_at'].transform(
    lambda x: pd.qcut(x, 4, labels=[1, 2, 3, 4]) 
)


df_new = (df_new
      .assign(ret_aux = 1 + df_new['RET'])
      .assign(ret_aux_lead1 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-1))
      .assign(ret_aux_lead2 = lambda x: x.groupby('GVKEY')['ret_aux'].shift(-2))
      .assign(ret_2mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']) - 1)
      .assign(ret_2mo_lead1 = lambda x: x.groupby('GVKEY')['ret_2mo'].shift(-1))
      .assign(ret_3mo = lambda x: (x['ret_aux']*x['ret_aux_lead1']*x['ret_aux_lead2']) - 1)
      .assign(ret_3mo_lead1 = lambda x: x.groupby('GVKEY')['ret_3mo'].shift(-1))
      .drop(columns=['ret_aux', 'ret_aux_lead1', 'ret_aux_lead2'])       
      )

#df_new[['RET', 'ret_aux', 'ret_aux_lead1', 'ret_aux_lead2', 'ret_3mo', 'ret_3mo_lead1']].head(50)
# df_new[['hint', 'quart_intan']][df_new['quart_intan'] == 4].tail(50)
#df_int = df_new.query('lint == True')

df_new['RET_lead1'] = df_new.groupby('GVKEY')['RET'].shift(-1)
df_new['debt_at_lag1'] = df_new.groupby('GVKEY')['debt_at'].shift(1)
df_new['d_debt_at'] = df_new['debt_at'] - df_new['debt_at_lag1']
df_new.reset_index(inplace=True)

# To generate quintiles of leverage change by month, 
# I need to deal with the zeros (otherwise, I get "Bin edges must be unique" error)
# Solution: replace zeros with the smallest non-zero value - espilon

smallest_non_zero = df_new.loc[df_new['d_debt_at'] > 0, 'd_debt_at'].min()
print(smallest_non_zero)
epsilon = np.random.uniform(0, smallest_non_zero * 0.1, size=len(df))

smallest_non_zero_lev = df_new.loc[df_new['debt_at'] > 0, 'debt_at'].min()
print(smallest_non_zero_lev)
epsilon_lev = np.random.uniform(0, smallest_non_zero_lev * 0.1, size=len(df))


# Replace zeros with these small random numbers (otherwise, qcut will not work)
df_new['d_debt_at_adj'] = df_new['d_debt_at']
df_new['debt_at_adj'] = df_new['debt_at']
df_new.loc[df_new['d_debt_at'] == 0, 'd_debt_at_adj'] = epsilon[df_new['d_debt_at'] == 0]
df_new.loc[df_new['debt_at'] == 0, 'debt_at_adj'] = epsilon_lev[df_new['debt_at'] == 0]

df_new.head(50)

df_new['qui_d_debt_at'] = df_new.groupby('year_month')['d_debt_at_adj'].transform(
    lambda x: pd.qcut(x, 5, labels=[1, 2, 3, 4, 5])
)

df_new['qui_debt_at'] = df_new.groupby('year_month')['debt_at_adj'].transform(
    lambda x: pd.qcut(x, 5, labels=[1, 2, 3, 4, 5])
)

grouped = df_new.groupby(['year_month', 'qui_debt_at', 'qui_d_debt_at'])

# Computing the Average Return for Each Group
monthly_avg_returns = grouped['RET'].mean().reset_index()

# monthly_avg_returns.head(50)
# Compute the Average Across All Months
overall_avg_returns = monthly_avg_returns.groupby(['qui_debt_at', 'qui_d_debt_at'])['RET'].mean().reset_index()
# avr_returns_by_qui_debt_at.head(50)
# pivot_df = overall_avg_returns.pivot(index='qui_d_debt_at', columns='qua_intan', values='ret_3mo_lead1')
pivot_df = overall_avg_returns.pivot(index='qui_d_debt_at', columns='qui_debt_at', values='RET')

# Calculate the difference between the first and fifth rows
difference_row = pivot_df.iloc[0] - pivot_df.iloc[4]
difference_row.name = '1-5 Difference'

# Step 7: Append the difference row to the pivoted DataFrame
pivot_df = pivot_df._append(difference_row)

print(pivot_df)

######################
# Calculating t-stats
######################

pivot_t_stat = monthly_avg_returns.pivot_table(values='RET', index=['year_month', 'qui_debt_at'], columns='qui_d_debt_at').reset_index()
pivot_t_stat.head(50)
pivot_t_stat['RET_diff'] = pivot_t_stat[1] - pivot_t_stat[5]
time_series_diff = pivot_t_stat[['year_month', 'qui_debt_at', 'RET_diff']]
time_series_diff = time_series_diff.sort_values(by = ['qui_debt_at', 'year_month'])


# Function to perform regression on a constant
def regress_on_constant(df):
    df = df.dropna(subset=['RET_diff'])  # Remove rows with NaN values in 'RET_diff'
    X = sm.add_constant(pd.Series([1]*len(df), index=df.index))  # Add a constant term (array of ones) with the same index as df
    model = sm.OLS(df['RET_diff'], X).fit()
    return model

# Dictionary to store regression results
regression_results = {}
t_stats = []

# time_series_diff['qui_debt_at'].unique()
# Loop through each qui_debt_at value and perform the regression
for qui_debt_at_value in time_series_diff['qui_debt_at'].unique():
    df_filtered = time_series_diff[time_series_diff['qui_debt_at'] == qui_debt_at_value]
    model = regress_on_constant(df_filtered)
    regression_results[qui_debt_at_value] = model.summary()
    t_stats.append(model.tvalues[0]) 

t_stats_row = pd.DataFrame([t_stats], columns=time_series_diff['qui_debt_at'].unique())

pivot_df_percent = pivot_df * 100
pivot_df_with_t_stats = pivot_df_percent._append(t_stats_row, ignore_index=True)
print(pivot_df_with_t_stats)

##############
# Latex table
##############

# Extract the last row (t-stats) and the rows with coefficients
t_stats_row = pivot_df_with_t_stats.iloc[-1]
avr_rows = pivot_df_with_t_stats.iloc[:-1]

# Add stars to t-stats
t_stats_with_stars = [f"({t_stat:.2f}){add_stars(t_stat)}" for t_stat in t_stats_row]

# Create LaTeX table string
latex_table = "\\begin{tabular}{cccccc}\n"
latex_table += "\\toprule\n"
latex_table += "qui\\_debt\\_at & 1 & 2 & 3 & 4 & 5 \\\\\n"
latex_table += "\\midrule\n"

for index, row in avr_rows.iterrows():
    qui_debt_at = row.name
    coeffs = [f"{row[col]:.4f}" for col in avr_rows.columns]
    latex_table += f"{qui_debt_at} & " + " & ".join(coeffs) + " \\\\\n"

latex_table += "\\midrule\n"
latex_table += "t-stats & " + " & ".join(t_stats_with_stars) + " \\\\\n"
latex_table += "\\bottomrule\n"
latex_table += "\\end{tabular}"

print(latex_table)



# Display the regression summaries
# for qui_debt_at_value, summary in regression_results.items():
#     print(f"Regression result for qui_debt_at {qui_debt_at_value}:\n")
#     print(summary)
#     print("\n" + "="*80 + "\n")
