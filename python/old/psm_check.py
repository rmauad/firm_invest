# Visual inspection of the PSM quality

import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

psm = pd.read_csv('data/csv/psm_clean.csv')

# Filter only treated firms in psm
treatment_tang = psm[(psm['treated'] == 1) & (psm['ter'] == 1)]
control_tang = psm[(psm['treated'] == 0) & (psm['ter'] == 1)]

debt_issuan_treat = treatment_tang.groupby('year_q')['debt_issuance'].mean()
debt_issuan_control = control_tang.groupby('year_q')['debt_issuance'].mean()
start_date = pd.to_datetime('1990-01-01')
end_date = pd.to_datetime('2020-03-01')

#debt_issuance_control = control.dropna(subset=['debt_issuance']).groupby('year_q')['debt_issuance'].mean()

# print columns year_q, GVKEY, and debt_issuance for control for 1996Q3
print(control[control['year_q'] == '2020Q4'][['year_q', 'GVKEY', 'debt_issuance', 'capxy']])
# print(control[control['year_q'] == '1996Q3'][['year_q', 'GVKEY', 'debt_issuance']].describe)

print(control[['year_q', 'GVKEY', 'debt_issuance']].describe())
print(control[control['year_q'] == '2015Q1'][['year_q', 'GVKEY', 'debt_issuance']].describe)


# Plot the average of debt issuance for treated and control firms
debt_issuan_treat_filtered = debt_issuan_treat.loc[:'2005:Q4']
debt_issuan_control_filtered = debt_issuan_control.loc[:'2005:Q4']
debt_issuan_treat_filtered.plot(kind='line', label = 'Treated Firms')
debt_issuan_control_filtered.plot(kind='line', label = 'Control Firms')
plt.title('Average Debt to Total Assets')
plt.xlabel('Quarter')
plt.ylabel('Debt to Total Assets')
plt.legend()
plt.show()

# print the average of debt issuance for treated and control firms between 1994 and 2004
print(debt_issuan_treat.loc['1994':'2004'])
print(debt_issuan_control.loc['1994':'2004'])


plt.figure(figsize=(10, 6))
plt.hist(treatment['debt_at'], alpha=0.5, label='Investment Treatment')
plt.hist(control['debt_at'], alpha=0.5, label='Investment Control')
plt.xlabel('Investment')
plt.ylabel('Frequency')
plt.title('Histogram of Investment by Group')
plt.legend()
plt.show()

#Density plot
plt.figure(figsize=(10, 6))
sns.kdeplot(treatment['debt_at'], label='Treatment', shade=True)
sns.kdeplot(control['debt_at'], label='Control', shade=True)
plt.xlabel('Covariate Value')
plt.title('Density Plot of Covariate by Group')
plt.legend()
plt.show()

# Boxplot
combined_data = pd.concat([treatment.assign(group='Treatment'), control.assign(group='Control')])
plt.figure(figsize=(10, 6))
sns.boxplot(x='year_q', y='debt_at', data=combined_data)
plt.xlabel('Group')
plt.ylabel('Covariate Value')
plt.title('Boxplot of Covariate by Group')
plt.show()