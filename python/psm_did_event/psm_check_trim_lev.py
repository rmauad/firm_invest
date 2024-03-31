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
percentile_98 = treatment_tang['debt_at'].quantile(0.98)
treatment_tang_trim = treatment_tang[treatment_tang['debt_at'] < percentile_98]
control_tang_trim = control_tang[control_tang['debt_at'] < percentile_98]
debt_issuan_treat_tang = treatment_tang_trim.groupby('year_q')['debt_at'].mean()
debt_issuan_control_tang = control_tang_trim.groupby('year_q')['debt_at'].mean()

percentile_98 = treatment_intan['debt_at'].quantile(0.98)
treatment_intan_trim = treatment_intan[treatment_intan['debt_at'] < percentile_98]
control_intan_trim = control_intan[control_intan['debt_at'] < percentile_98]
debt_issuan_treat_intan = treatment_intan_trim.groupby('year_q')['debt_at'].mean()
debt_issuan_control_intan = control_intan_trim.groupby('year_q')['debt_at'].mean()

# Plot the average of debt issuance for treated and control firms
debt_issuan_treat_tang_filtered = debt_issuan_treat_tang.loc[:'2005:Q4']
debt_issuan_control_tang_filtered = debt_issuan_control_tang.loc[:'2005:Q4']
debt_issuan_treat_tang_filtered.plot(kind='line', label = 'Tangible Treated Firms')
debt_issuan_control_tang_filtered.plot(kind='line', label = 'Tangible Control Firms')
plt.title('Average debt/assets for Treated and Control Firms')
plt.xlabel('Quarter')
plt.ylabel('Debt/assets')
plt.legend()
plt.show()

# Plot the average of debt issuance for treated and control firms
debt_issuan_treat_intan_filtered = debt_issuan_treat_intan.loc[:'2005:Q4']
debt_issuan_control_intan_filtered = debt_issuan_control_intan.loc[:'2005:Q4']
debt_issuan_treat_intan_filtered.plot(kind='line', label = 'Intangible Treated Firms')
debt_issuan_control_intan_filtered.plot(kind='line', label = 'Intangible Control Firms')
plt.title('Average debt/assets for Treated and Control Firms')
plt.xlabel('Quarter')
plt.ylabel('Debt/assets')
plt.legend()
#plt.ylim(-400, 200)
plt.show()