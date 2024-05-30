import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import statsmodels.formula.api as smf
import linearmodels as lm
import statsmodels.api as sm
import sys
import re
sys.path.append('code/firm_invest/python/psm_did_event/')
from data_functions import convert_to_datetime

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
sorted_columns = sorted(df.columns)
print(sorted_columns)

df[['year_q', 'atq']].head()

##################################
# Plot firm leverage in TX and LA
##################################

df_treated = df[(df['treated'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

##################################################################
# Only among firms in TX and LA, separate tangible and intangible
##################################################################

df_treated_intan = df_treated[(df_treated['ter_top'] == 1)]
df_treated_tang = df_treated[(df_treated['ter_bot'] == 1)]

debt_at_intan_mean = df_treated_intan.groupby('year_q')['debt_at'].mean()
debt_at_tang_mean = df_treated_tang.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_intan_mean.index, debt_at_intan_mean.values, label = 'Intangible', marker = 'o')
plt.plot(debt_at_tang_mean.index, debt_at_tang_mean.values, label = 'Tangible', marker = 'o')
plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

##################################################################
# Only among tangible firms, get treated vs. control
##################################################################

df_intan = df[(df['ter_top'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_tang = df[(df['ter_bot'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

# Tangible firms
df_treated_tang = df_tang[(df_tang['treated'] == 1)]
df_control_tang = df_tang[(df_tang['treated'] == 0)]

debt_at_treated_mean = df_treated_tang.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_tang.groupby('year_q')['debt_at'].mean()

# Intangible firms
df_treated_intan = df_intan[(df_intan['treated'] == 1)]
df_control_intan = df_intan[(df_intan['treated'] == 0)]

# Removing specific outliers (based on the analysis below)
df_treated_intan = df_treated_intan[(df_treated_intan['GVKEY'] != 12118) & (df_treated_intan['GVKEY'] != 30325)]
debt_at_treated_intan_mean = df_treated_intan.groupby('year_q')['debt_at'].mean()
debt_at_control_intan_mean = df_control_intan.groupby('year_q')['debt_at'].mean()

# Tangible firms
plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage of tangible firms')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

# Intangible firms
plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_intan_mean.index, debt_at_treated_intan_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_intan_mean.index, debt_at_control_intan_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage  of intangible firms')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

###############################################################
# Analyzing whether the results are driven by only a few firms
###############################################################

quarter = '1997Q4'
plt.figure(figsize=(10, 6))
sns.boxplot(x='GVKEY', y='debt_at', data=df_treated_intan[df_treated_intan['year_q'] == quarter])
plt.title(f'Leverage Distribution in {quarter}')
plt.xticks(rotation = 45)
plt.show()
# GVKEY: 12118

quarter = '1999Q1'
plt.figure(figsize=(10, 6))
sns.boxplot(x='GVKEY', y='debt_at', data=df_treated_intan[df_treated_intan['year_q'] == quarter])
plt.title(f'Leverage Distribution in {quarter}')
plt.xticks(rotation = 45)
plt.show()
# GVKEY: 30325

quarter = '1999Q4'
plt.figure(figsize=(10, 6))
sns.boxplot(x='GVKEY', y='debt_at', data=df_treated_intan[df_treated_intan['year_q'] == quarter])
plt.title(f'Leverage Distribution in {quarter}')
plt.xticks(rotation = 45)
plt.show()
# GVKEY: 30325


# Example code for flow:
# btc = (btc.assign(Date = pd.to_datetime(btc["Date"], errors = "coerce"))
#         .assign(Year = lambda x: x["Date"].dt.year)
#         .dropna()
#         .drop_duplicates("Date"))