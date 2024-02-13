import pandas as pd
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/jmp_github/python/')
from data_functions import convert_to_datetime

# Load the data
df = pd.read_csv('data/csv/db_reg.csv')

# Generating date variable and creating terciles of org_cap_comp
df['date'] = df['year_q'].apply(convert_to_datetime)
df['date'] = pd.to_datetime(df['date'])
#df['ter_indust'] = df.groupby(['ff_indust'])['org_cap_comp'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
df['ter'] = pd.qcut(df['org_cap_comp'], 3, labels = [1, 2, 3])

# Filter for selected firms
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

# Create k_int_at by dividing K_int by total assets
df['int_at'] = df['org_cap_comp'] / df['atq']

# Plot the yearly average of k_int_at for all firms
int_at = df.groupby('year')['int_at'].mean()
int_at.plot(kind='line')
plt.title('Average Intangible Assets to Total Assets')
plt.xlabel('Year')
plt.ylabel('Intangible Assets to Total Assets')
plt.show()


# Count unique firms in the state of AL between 2001 and 2003

# Filter for the years 2001 to 2003
df_2001_2003 = df[(df['date'] >= '2001-01-01') & (df['date'] <= '2003-12-31')]
# Filter for the state of AL
df_2001_2003_AL = df_2001_2003[df_2001_2003['state'] == 'AL']
# Count the unique firms
unique_firms_AL = df_2001_2003_AL['GVKEY'].nunique()
print(unique_firms_AL)

print(df.shape)

