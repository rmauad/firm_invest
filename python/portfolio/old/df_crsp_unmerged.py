import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

df = pd.read_csv('data/csv/psm_clean.csv') #created by psm_clean.py

#########################
# Plotting leverage 
#########################

df_intan = df[(df['ter_top'] == 1) & (df['year'] >= 1990) & (df['year'] <= 2006)]
df_tang = df[(df['ter_bot'] == 1) & (df['year'] >= 1990) & (df['year'] <= 2006)]

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
debt_at_treated_mean.index = ['{}-{:02}'.format(year, month) for year, month in debt_at_treated_mean.index]
debt_at_control_mean.index = ['{}-{:02}'.format(year, month) for year, month in debt_at_control_mean.index]

plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage of tangible firms')
plt.xlabel('Quater')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

#########################
# Plotting stock returns
#########################

# Merge with


crsp = pd.read_csv('data/csv/crsp_full.csv')

crsp = (crsp.assign(date = pd.to_datetime(crsp["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
        .assign(month = lambda x: x['date'].dt.month)
        .assign(year = lambda x: x['date'].dt.year)
        .assign(PERMNO_year_month = lambda x: x['PERMNO'].astype(str) + '_' + x['year'].astype(str) + '_' + x['month'].astype(str)))



plt.figure(figsize=(10, 6))
plt.plot(debt_at_treated_mean.index, debt_at_treated_mean.values, label = 'Treated', marker = 'o')
plt.plot(debt_at_control_mean.index, debt_at_control_mean.values, label = 'Control', marker = 'o')
plt.title('Leverage of tangible firms')
plt.xlabel('Quater')
plt.ylabel('Leverage')
plt.xticks(rotation = 45)
tick_labels = debt_at_treated_mean.index[::4]
plt.xticks(tick_labels)
plt.legend()
plt.grid(True)
plt.show()

sorted_columns = sorted(crsp.columns)
print(sorted_columns)

print(crsp[['date', 'RET', 'PERMNO']])