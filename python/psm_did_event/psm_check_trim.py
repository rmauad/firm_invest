# Visual inspection of the PSM quality

import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

psm = pd.read_csv('data/csv/psm_clean.csv')

# Filter treated vs. control and tangible vs. intangible firms in psm 
treatment = psm[(psm['treated'] == 1)]
control = psm[(psm['treated'] == 0)]
treatment_tang = psm[(psm['treated'] == 1) & (psm['ter'] == 1)]
control_tang = psm[(psm['treated'] == 0) & (psm['ter'] == 1)]
treatment_intan = psm[(psm['treated'] == 1) & (psm['ter'] == 3)]
control_intan = psm[(psm['treated'] == 0) & (psm['ter'] == 3)]

# Generate the average of debt issuance for treated and control firms
percentile_98 = treatment_tang['debt_issuance'].quantile(0.98)
treatment_tang_trim = treatment_tang[treatment_tang['debt_issuance'] < percentile_98]
control_tang_trim = control_tang[control_tang['debt_issuance'] < percentile_98]
debt_issuan_treat_tang = treatment_tang_trim.groupby('year_q')['debt_issuance'].mean()
debt_issuan_control_tang = control_tang_trim.groupby('year_q')['debt_issuance'].mean()
debt_issuan_treat_intan = treatment_intan.groupby('year_q')['debt_issuance'].mean()
debt_issuan_control_intan = control_intan.groupby('year_q')['debt_issuance'].mean()



# Plot the average of debt issuance for treated and control firms
debt_issuan_treat_tang_filtered = debt_issuan_treat_tang.loc[:'2005:Q4']
debt_issuan_control_tang_filtered = debt_issuan_control_tang.loc[:'2005:Q4']
debt_issuan_treat_tang_filtered.plot(kind='line', label = 'Tangible Treated Firms')
debt_issuan_control_tang_filtered.plot(kind='line', label = 'Tangible Control Firms')
plt.title('Average Debt Issuance for Treated and Control Firms')
plt.xlabel('Quarter')
plt.ylabel('Average Debt Issuance (million $)')
plt.legend()
plt.show()

# Plot the average of debt issuance for treated and control firms
debt_issuan_treat_intan_filtered = debt_issuan_treat_intan.loc[:'2005:Q4']
debt_issuan_control_intan_filtered = debt_issuan_control_intan.loc[:'2005:Q4']
debt_issuan_treat_intan_filtered.plot(kind='line', label = 'Intangible Treated Firms')
debt_issuan_control_intan_filtered.plot(kind='line', label = 'Intangible Control Firms')
plt.title('Average Debt Issuance for Treated and Control Firms')
plt.xlabel('Quarter')
plt.ylabel('Average Debt Issuance (million $)')
plt.legend()
plt.ylim(-400, 200)
plt.show()