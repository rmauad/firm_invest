import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from merge_functions import custom_fill
# import sys
# sys.path.append('code/firm_invest/python/psm_did_event/')
# from data_functions import convert_to_datetime

#df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
df = pd.read_csv('data/csv/db_did.csv') # created by prep_db_did.py
#compustat = pd.read_csv('data/csv/comp_fundq.csv')
crsp_d = pd.read_csv('data/csv/crsp_full.csv')
link_permno_gvkey = pd.read_csv('data/csv/link_permno_gvkey.csv')
link_permno_gvkey = link_permno_gvkey.loc[:,['GVKEY', 'LPERMNO']]
link_permno_gvkey_unique = link_permno_gvkey.drop_duplicates()

########################################################
# Merging databases and selecting variables of interest
########################################################

crsp_d_merge = (crsp_d
             .assign(date = pd.to_datetime(crsp_d["date"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
             .assign(day = lambda x: x['date'].dt.day)             
             .assign(month = lambda x: x['date'].dt.month)
             .assign(year = lambda x: x['date'].dt.year)
        )

link_permno_gvkey_renamed = link_permno_gvkey_unique.rename(columns={'LPERMNO': 'PERMNO'})


crsp_link = (pd.merge(crsp_d_merge, link_permno_gvkey_renamed, how = 'inner', on = 'PERMNO')
             .assign(GVKEY_date = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
        )

df_link = (df
           .assign(date = pd.to_datetime(df["DATE"], format = '%Y-%m-%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
           .assign(day = lambda x: x['date'].dt.day)             
           .assign(month = lambda x: x['date'].dt.month)
           .assign(year = lambda x: x['date'].dt.year)
           .assign(GVKEY_date = lambda x: x['GVKEY'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str) + '_' + x['day'].astype(str))
           .drop(columns = ['year_q', 'year', 'month', 'day', 'GVKEY'])
           )

df_merge = (pd.merge(crsp_link, df_link, how = 'left', on = 'GVKEY_date'))


df_sel = df_merge[['GVKEY', 'PRC', 'RET', 'SHROUT', 'atq', \
                   'capxy', 'cash_at', 'debt_at', 'org_cap_comp', 'ppentq', \
                    'year', 'month', 'date', 'state']]

df_filled = df_sel.groupby('GVKEY').apply(custom_fill)

df_sel_filled = df_filled.assign(
    intan_cap=lambda x: x['org_cap_comp'] / (x['org_cap_comp'] + x['ppentq']),
    tercile=lambda x: pd.qcut(x['intan_cap'], q=3, labels=['low', 'mid', 'high']),
    ter_top=lambda x: (x['tercile'] == 'high').astype(int),
    ter_mid=lambda x: (x['tercile'] == 'mid').astype(int),
    ter_bot=lambda x: (x['tercile'] == 'low').astype(int),    # Convert boolean to integer (1 for True, 0 for False)
    year_month = lambda x: x['year'].astype(str) + '-' + x['month'].astype(str)
)

######################################################
# No difference between tangible and intangible firms
######################################################
df_sel_filled = df_sel_filled.assign(
    treated=lambda x: (x['state'] == 'TX') | (x['state'] == 'LA')
)
           
df_treated = df_sel_filled[(df_sel_filled['treated'] == 1) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)] #only firms in TX and LA
df_control = df_sel_filled[(df_sel_filled['treated'] == 0) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)]

# Calculating 98th percentile for outlier removal
percentile_98_treated = df_treated['debt_at'].quantile(.98)
percentile_98_control = df_control['debt_at'].quantile(.98)

# Filtering out data above 98th percentile
df_treated_filtered = df_treated[df_treated['debt_at'] <= percentile_98_treated]
df_control_filtered = df_control[df_control['debt_at'] <= percentile_98_control]

debt_at_treated_mean = df_treated_filtered.groupby(['year_month'])['debt_at'].mean()
debt_at_control_mean = df_control_filtered.groupby(['year_month'])['debt_at'].mean()

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage of tangible firms')
plt.xlabel('Month')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::10]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()


#########################
# Plotting stock prices
#########################
# Calculating 98th percentile for outlier removal
percentile_98_treated = df_treated['PRC'].abs().quantile(.98)
percentile_98_control = df_control['PRC'].abs().quantile(.98)

# Filtering out data above 98th percentile
df_treated_filtered = df_treated[df_treated['PRC'] <= percentile_98_treated]
df_control_filtered = df_control[df_control['PRC'] <= percentile_98_control]

stk_prc_treated_mean = df_treated_filtered.groupby('year_month')['PRC'].apply(lambda x: x.abs().mean())
stk_prc_control_mean = df_control_filtered.groupby('year_month')['PRC'].apply(lambda x: x.abs().mean())

plt.figure(figsize=(10, 6))
plt.plot(stk_prc_treated_mean.index, stk_prc_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(stk_prc_control_mean.index, stk_prc_control_mean.values, label = 'Control', marker = 'o')
plt.title('Average stock prices')
plt.xlabel('Month')
plt.ylabel('Stock price')
plt.xticks(rotation = 45)
tick_labels = stk_prc_treated_mean.index[::10]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

#########################
# Plotting stock returns
#########################
# Calculating 98th percentile for outlier removal
percentile_98_treated = df_treated['RET'].abs().quantile(.98)
percentile_98_control = df_control['RET'].abs().quantile(.98)

# # Filtering out data above 98th percentile
# df_treated_filtered = df_treated[df_treated['PRC'] <= percentile_98_treated]
# df_control_filtered = df_control[df_control['PRC'] <= percentile_98_control]
df_treated['RET'] = pd.to_numeric(df_treated['RET'], errors='coerce')
df_control['RET'] = pd.to_numeric(df_control['RET'], errors='coerce')

stk_ret_treated_mean = df_treated.groupby('year_month')['RET'].mean()
stk_ret_control_mean = df_control.groupby('year_month')['RET'].mean()

plt.figure(figsize=(10, 6))
plt.plot(stk_ret_treated_mean.index, stk_ret_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(stk_ret_control_mean.index, stk_ret_control_mean.values, label = 'Control', marker = 'o')
plt.title('Average stock prices')
plt.xlabel('Month')
plt.ylabel('Stock price')
plt.xticks(rotation = 45)
tick_labels = stk_ret_treated_mean.index[::10]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

########################################
# Plotting stock returns for tangible firms
########################################

df_treated = df_sel_filled[(df_sel_filled['treated'] == 1) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)] #only firms in TX and LA
df_control = df_sel_filled[(df_sel_filled['treated'] == 0) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)]

df_treated_tang = df_treated[(df_treated['ter_bot'] == 1)]
df_control_tang = df_control[(df_control['ter_bot'] == 1)]

stk_ret_treated_mean = df_treated_tang.groupby('year_month')['RET'].mean()
stk_ret_control_mean = df_control_tang.groupby('year_month')['RET'].mean()

plt.figure(figsize=(10, 6))
plt.plot(stk_ret_treated_mean.index, stk_ret_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(stk_ret_control_mean.index, stk_ret_control_mean.values, label = 'Control', marker = 'o')
plt.title('Average stock prices')
plt.xlabel('Month')
plt.ylabel('Stock price')
plt.xticks(rotation = 45)
tick_labels = stk_ret_treated_mean.index[::10]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()


# Save dataframe
df_sel_filled.to_csv('data/csv/ccm.csv', index = False)
df_sel_filled.to_feather('data/feather/ccm.feather')

# Data visualization
sorted_columns = sorted(df_merge.columns)
print(sorted_columns)