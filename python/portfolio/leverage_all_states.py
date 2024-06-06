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

df = pd.read_csv('data/csv/psm_clean_all_states.csv') #created by psm_clean_all_states.py
sorted_columns = sorted(df.columns)
print(sorted_columns)

df[['year_q', 'atq']].head()

##################################
# Plot firm leverage in TX and LA
##################################

df_treated_tx_la = df[(df['treated_TX_LA'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_tx_la = df[(df['treated_TX_LA'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_tx_la.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_tx_la.groupby('year_q')['debt_at'].mean()

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

##################################
# Plot firm leverage in AL
##################################

df_treated_al = df[(df['treated_AL'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_al = df[(df['treated_AL'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_al.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_al.groupby('year_q')['debt_at'].mean()

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


##################################
# Plot firm leverage in DE
##################################

df_treated_de = df[(df['treated_DE'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_de = df[(df['treated_DE'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_de.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_de.groupby('year_q')['debt_at'].mean()

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

##################################
# Plot firm leverage in SD
##################################

df_treated_sd = df[(df['treated_SD'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_sd = df[(df['treated_SD'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_sd.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_sd.groupby('year_q')['debt_at'].mean()

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


##################################
# Plot firm leverage in VA
##################################

df_treated_va = df[(df['treated_VA'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_va = df[(df['treated_VA'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_va.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_va.groupby('year_q')['debt_at'].mean()

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


##################################
# Plot firm leverage in NV
##################################

df_treated_nv = df[(df['treated_NV'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control_nv = df[(df['treated_NV'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated_nv.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control_nv.groupby('year_q')['debt_at'].mean()

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



# Data vizualization

df.shape