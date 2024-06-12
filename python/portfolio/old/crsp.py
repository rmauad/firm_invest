import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
# import sys
# sys.path.append('code/firm_invest/python/psm_did_event/')
# from data_functions import convert_to_datetime

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py
#compustat = pd.read_csv('data/csv/comp_fundq.csv')
crsp = pd.read_csv('data/csv/crsp_full.csv')
link_permno_gvkey = pd.read_csv('data/csv/link_permno_gvkey.csv')
link_permno_gvkey = link_permno_gvkey.loc[:,['GVKEY', 'LPERMNO']]

########################################################
# Merging databases and selecting variables of interest
########################################################

# Defining a mapping from quarter to middle month
quarter_to_middle_month = {
    'Q1': '02',
    'Q2': '05',
    'Q3': '08',
    'Q4': '11'
}

# Merging databases
df_link = (pd.merge(df, link_permno_gvkey, how = 'inner', on = 'GVKEY')
            .rename(columns = {'LPERMNO': 'PERMNO'})
            .assign(month = lambda x: x['year_q'].str[-2:].map(quarter_to_middle_month))
            .assign(PERMNO_year_month = lambda x: x['PERMNO'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str)))

crsp = (crsp.assign(date = pd.to_datetime(crsp["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
        .assign(month = lambda x: x['date'].dt.month)
        .assign(year = lambda x: x['date'].dt.year)
        .assign(PERMNO_year_month = lambda x: x['PERMNO'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str)))

df_merge = (pd.merge(crsp, df_link, how = 'left', on = 'PERMNO_year_month')
            .rename(columns = {'year_x': 'year', 'month_x': 'month'})
            .query('1990 <= year <= 2020'))

df_sel = df_merge[['COMNAM', 'GVKEY', 'PRC', 'RET', 'SHROUT', 'atq', \
                   'capxy', 'cash_at', 'debt_at', 'org_cap_comp', 'ppentq', \
                    'year', 'month', 'state', 'treated']]

df_sel_filled = df_sel.fillna(method='ffill')

df_sel_filled = df_sel_filled.assign(
    intan_cap=lambda x: x['org_cap_comp'] / (x['org_cap_comp'] + x['ppentq']),
    tercile=lambda x: pd.qcut(x['intan_cap'], q=3, labels=['low', 'mid', 'high']),
    ter_top=lambda x: (x['tercile'] == 'high').astype(int),
    ter_mid=lambda x: (x['tercile'] == 'mid').astype(int),
    ter_bot=lambda x: (x['tercile'] == 'low').astype(int)    # Convert boolean to integer (1 for True, 0 for False)
)

#########################
# Plotting stock returns
#########################


df_intan = df_sel[(df_sel['ter_mid'] == 1)]
df_intan = df_sel[(df_sel['year'] >= 1990) & (df_sel['year'] <= 2006)]


df_intan = df_sel_filled[(df_sel_filled['ter_top'] == 1) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)]
df_tang = df_sel_filled[(df_sel_filled['ter_bot'] == 1) & (df_sel_filled['year'] >= 1990) & (df_sel_filled['year'] <= 2006)]

# Tangible firms
df_treated_tang = df_tang[(df_tang['treated'] == 1)]
df_control_tang = df_tang[(df_tang['treated'] == 0)]

debt_at_treated_mean = df_treated_tang.groupby(['year', 'month'])['debt_at'].mean()
debt_at_control_mean = df_control_tang.groupby(['year', 'month'])['debt_at'].mean()

# Intangible firms
df_treated_intan = df_intan[(df_intan['treated'] == 1)]
df_control_intan = df_intan[(df_intan['treated'] == 0)]

# Removing specific outliers (based on the analysis below)
df_treated_intan = df_treated_intan[(df_treated_intan['GVKEY'] != 12118) & (df_treated_intan['GVKEY'] != 30325)]
debt_at_treated_intan_mean = df_treated_intan.groupby('month')['debt_at'].mean()
debt_at_control_intan_mean = df_control_intan.groupby('month')['debt_at'].mean()

# Tangible firms
debt_at_treated_mean.index = ['{}-{:02}'.format(year, month) for year, month in debt_at_treated_mean.index]
debt_at_control_mean.index = ['{}-{:02}'.format(year, month) for year, month in debt_at_control_mean.index]

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

# Intangible firms
plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_intan_mean.index, debt_at_treated_intan_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_intan_mean.index, debt_at_control_intan_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage  of intangible firms')
plt.xlabel('Quarter')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
# tick_labels = debt_at_treated_mean.index[::4]
# plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()



#df_merge = df_merge[(df_merge['year'] >= 1990) & (df_merge['year'] <= 2020)]
test = crsp[(crsp['year'] >= 1990) & (crsp['year'] <= 2020)]

# test = crsp.assign(year = lambda x: x['date'].dt.year)
# test = crsp.assign(date = pd.to_datetime(crsp["date"], format = '%Y%m%d', errors = "coerce"))
        
# type(crsp.date)
max_year = df_merge['month'].min()
print(max_year)
print(df_sel[['month', 'GVKEY']])

sorted_columns = sorted(df_merge.columns)
print(sorted_columns)

df_intan = df_sel[(df_sel['ter_top'] == 1)]
                  
df_merge['PERMNO_year_month'].head()
max_val = df_tang['month'].min()
print(max_val)
df_intan.shape
type(df_sel)

df_intan.shape
df['GVKEY'].nunique()

# even the mid tercile only shows month 11. Something is wrong with the terciles.

month_counts = df_intan['month'].value_counts()
print(month_counts)

desc_stats = df['intan_cap'].describe()
print(desc_stats)

print(df['org_cap_comp'].isna().sum())

df_treated = df[(df['treated'] == 0)]

df_treated['GVKEY'].nunique()