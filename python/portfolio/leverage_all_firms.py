import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# import os
# import sys
# sys.path.append('code/firm_invest/python/')
# from data_functions import convert_to_datetime
# import requests as rq

# Load the data
df = pd.read_csv('data/csv/db_did.csv') # created by prep_db_did.py

##########################################################################################      
# Plot average leverage for treated and control firms (where control are all firms outside the states and period of law enactement)
##########################################################################################  

df['treated_tx_la'] = 0
df.loc[(df['state'] == 'TX') | (df['state'] == 'LA'), 'treated_tx_la'] = 1

df['treated_la'] = 0
df.loc[(df['state'] == 'LA'), 'treated_la'] = 1

df['treated_al'] = 0
df.loc[(df['state'] == 'AL'), 'treated_al'] = 1

df['treated_de'] = 0
df.loc[(df['state'] == 'DE'), 'treated_de'] = 1

df['treated_sd'] = 0
df.loc[(df['state'] == 'SD'), 'treated_sd'] = 1

df['treated_va'] = 0
df.loc[(df['state'] == 'VA'), 'treated_va'] = 1

df['treated_nv'] = 0
df.loc[(df['state'] == 'NV'), 'treated_nv'] = 1

df['debt_cap'] = (df['dlcq'] + df['dlttq']) / (df['dlcq'] + df['dlttq'] + df['ceqq'])


df_treated = df[(df['treated_tx_la'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_tx_la'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

#df_control = df[(df['treated_tx_la'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4') & df['GVKEY'] != 23942 & df['GVKEY'] != 1755]

# df_treated = df[(df['treated_tx_la'] == 1)]
# df_control = df[(df['treated_tx_la'] == 0)]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'TX and LA', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.axvline(x='1997Q1', color='r', linestyle='--')
plt.ylim(bottom=0.12, top=0.32) 
plt.legend()
plt.grid(True)
plt.show()

################# 
# Leverage in LA
#################

df_treated = df[(df['treated_la'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_la'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

# df_treated = df[(df['treated_tx_la'] == 1)]
# df_control = df[(df['treated_tx_la'] == 0)]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'LA', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.axvline(x='1997Q1', color='r', linestyle='--')
plt.ylim(bottom=0.12, top=0.32) 
plt.legend()
plt.grid(True)
plt.show()

################# 
# Leverage in AL
#################


df_treated = df[(df['treated_al'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_al'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'AL', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.axvline(x='2001Q1', color='r', linestyle='--')
plt.ylim(bottom=0.12, top=0.32) 
plt.legend()
plt.grid(True)
plt.show()


################# 
# Leverage in DE
#################


df_treated = df[(df['treated_de'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_de'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'DE', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)

# Add a vertical line at 1997Q1
plt.axvline(x='2002Q1', color='r', linestyle='--')

plt.legend()
plt.grid(True)
plt.show()

################# 
# Leverage in VA (skipping SD because there are only 8 firms there)
#################


df_treated = df[(df['treated_va'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_va'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'VA', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)

# Add a vertical line at 1997Q1
plt.axvline(x='2004Q1', color='r', linestyle='--')

plt.legend()
plt.grid(True)
plt.show()


################# 
# Leverage in NV
#################


df_treated = df[(df['treated_nv'] == 1) & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]
df_control = df[(df['treated_nv'] == 0)  & (df['year_q'] >= '1990Q1') & (df['year_q'] <= '2006Q4')]

debt_at_treated_mean = df_treated.groupby('year_q')['debt_at'].mean()
debt_at_control_mean = df_control.groupby('year_q')['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'NV', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Other states', marker = 'o')
#plt.title('Leverage')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)

# Add a vertical line at 1997Q1
plt.axvline(x='2005Q1', color='r', linestyle='--')

plt.legend()
plt.grid(True)
plt.show()

##################
# Check the data
##################

df['GVKEY'].nunique()
df['GVKEY'][df['state'] == 'LA'].nunique()
df['debt_at'][df['state'] == 'AL'].isna().sum()
df['debt_at'][df['state'] == 'AL'].describe()
df['debt_at'][df['state'] == 'TX'].describe()
print(df_treated.shape)

a = 1126 + 55
print(a)

sorted_columns = sorted(df.columns)
print(sorted_columns)

df['debt_cap'][(df['year_q'] == '1997Q2') & (df['GVKEY'] != 23942) & (df['GVKEY'] != 1755)].describe()
df['debt_cap'][(df['year_q'] == '1997Q3') & (df['GVKEY'] != 23942)].describe()

df[['GVKEY', 'debt_cap']][df['year_q'] == '1997Q2'].min()
sorted_df = df[df['year_q'] == '1997Q2'].sort_values('debt_cap', ascending=True)
lowest_leverage_firm = sorted_df[['GVKEY', 'debt_cap']].iloc[1]
print(lowest_leverage_firm)
df['GVKEY'].dtype