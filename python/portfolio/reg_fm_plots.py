import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from linearmodels.panel.model import FamaMacBeth
from tabulate import tabulate
import sys
sys.path.append('code/firm_invest/python/portfolio/')
from report_functions import add_stars

# Read the data from the feather file
df = pd.read_feather('data/feather/df_fm.feather') #from prep_fm.py
# df_test = df.dropna(subset=['lev'])
# df.shape
# df_test.shape

# Calculate monthly averages across all firms
monthly_avg = df.groupby('year_month')[['debt_at', 'lev', 'd_debt_at', 'd_lev']].mean().reset_index()
df[df['year'] ==  1981]['d_debt_at'].describe()

# Plot the results
# plt.figure(figsize=(14, 7))

# plt.plot(monthly_avg['year_month'], monthly_avg['debt_at'], label='Debt/Assets')
# plt.plot(monthly_avg['year_month'], monthly_avg['lev'], label='Total Liabilities/Assets')

# plt.xlabel('Month')
# plt.ylabel('Ratio')
# plt.title('Monthly Average Debt/Assets and Total Liabilities/Assets')
# plt.legend()
# plt.grid(True)
# plt.show()

# Plot leverage change 
plt.figure(figsize=(14, 7))

plt.plot(monthly_avg['year_month'], monthly_avg['d_debt_at'], label='Change in debt/Assets')
plt.plot(monthly_avg['year_month'], monthly_avg['d_lev'], label='Change in Total Liabilities/Assets')

plt.xlabel('Month')
plt.ylabel('Ratio')
plt.title('Monthly Average Debt/Assets and Total Liabilities/Assets')
plt.legend()
plt.grid(True)
plt.show()