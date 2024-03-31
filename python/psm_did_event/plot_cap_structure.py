import pandas as pd
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/jmp_github/python/')
from data_functions import convert_to_datetime

# Load the data and convert year_q to datetime
df = pd.read_csv('data/csv/db_reg.csv')
df['date'] = df['year_q'].apply(convert_to_datetime)

# Calculate total capital and debt
df['tot_cap'] = df['dlcq'] + df['dlttq'] + df['ceqq']
df['debt'] = df['dlcq'] + df['dlttq']

# Filter for selected firms
intan_firms = df[df['ter_top'] == 1]
tang_firms = df[df['ter_bot'] == 1]

# Group by time period and calculate mean
df['tot_cap_avr_intan'] = intan_firms.groupby('date')['tot_cap'].mean()
df['debt_avr_intan'] = intan_firms.groupby('date')['debt'].mean()
df['tot_cap_avr_tang'] = tang_firms.groupby('date')['tot_cap'].mean()
df['debt_avr_tang'] = tang_firms.groupby('date')['debt'].mean()
df['debt_tot_cap_avr_intan'] = df['debt_avr_intan']/ df['tot_cap_avr_intan']
df['debt_tot_cap_avr_tang'] = df['debt_avr_tang']/ df['tot_cap_avr_tang']

df['atq_avr_intan'] = intan_firms.groupby('date')['atq'].mean()
df['atq_avr_tang'] = tang_firms.groupby('date')['atq'].mean()
df['debt_at_avr_intan'] = df['debt_avr_intan']/ df['atq_avr_intan']
df['debt_at_avr_tang'] = df['debt_avr_tang']/ df['atq_avr_tang']

# Plot the average debt to total capital
df['debt_at_avr_intan'].plot(kind='line', label = 'Intangible Firms')
df['debt_at_avr_tang'].plot(kind='line', label = 'Tangible Firms')
plt.title('Average Debt to Total Assets')
plt.xlabel('Quarter')
plt.legend()
plt.show()
