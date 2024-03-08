import pandas as pd
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/firm_invest/python/')
from data_functions import convert_to_datetime

# Load the data
df = pd.read_csv('data/csv/db_reg.csv')

# Generating date variable and creating terciles of org_cap_comp
df['date'] = df['year_q'].apply(convert_to_datetime)
df['date'] = pd.to_datetime(df['date'])
#df['ter_indust'] = df.groupby(['ff_indust'])['org_cap_comp'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
# Generate intangible assets to total assets
df['int_at'] = df['org_cap_comp'] / df['atq']
df['ter'] = df.groupby(['year_q', 'ff_indust'])['int_at'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
#df['ter'] = pd.qcut(df['org_cap_comp'], 3, labels = [1, 2, 3])

# Filter for selected firms
df['equity_at'] = df['ceqq'] / df['atq']
intan_firms = df[df['ter'] == 3]
tang_firms = df[df['ter'] == 1]

# Group by time period and calculate mean
debt_at_intan = intan_firms.groupby('date')['debt_at'].mean()
debt_at_tang = tang_firms.groupby('date')['debt_at'].mean()

# Plot the average debt to total assets for intangible and tangible firms
debt_at_intan.plot(kind='line', label = 'Intangible Firms')
debt_at_tang.plot(kind='line', label = 'Tangible Firms')
plt.title('Average Debt to Total Assets')
plt.xlabel('Quarter')
plt.ylabel('Debt to Total Assets')
plt.legend()
plt.show()

# Generate variable equity/assets (removing firms with extreme values - discovered with the commands below)
filtered_intan_firms = intan_firms[(intan_firms['GVKEY'] != 144887) & (intan_firms['GVKEY'] != 19033) & (intan_firms['GVKEY'] != 108872)]
filtered_tang_firms = tang_firms[(tang_firms['GVKEY'] != 144887) & (tang_firms['GVKEY'] != 19033) & (tang_firms['GVKEY'] != 108872)]
eq_at_intan = filtered_intan_firms.groupby('date')['equity_at'].mean()
eq_at_tang = filtered_tang_firms.groupby('date')['equity_at'].mean()

# Plot the average debt to total assets for intangible and tangible firms
eq_at_intan.plot(kind='line', label = 'Intangible Firms')
eq_at_tang.plot(kind='line', label = 'Tangible Firms')
plt.title('Average Equity to Total Assets')
plt.xlabel('Quarter')
plt.ylabel('Equity to Total Assets')
plt.legend()
plt.show()


# Print the descriptive data for equity to total assets in 2013
print(df['equity_at'].loc[df['year'] == 2002].describe())

# Identify the GVKEY of the firm with the min value for equity to total assets in 2013
print(df['GVKEY'].loc[df['equity_at'] == df['equity_at'].loc[df['year'] == 2002].min()])