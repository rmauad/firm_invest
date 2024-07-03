import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# import os
# print(os.getcwd())

##################################
# Loading and importing dataframes (import one at a time)
##################################

ccm_q = pd.read_feather('data/feather/ccm_q_lev.feather') #from merge_cc_q_lev.py
cpi = pd.read_excel('data/excel/CPI.xls')
cpi = cpi.rename(columns={'date': 'year'})
ccm_q = pd.merge(ccm_q, cpi, on='year', how='left')

###################################################
# Creating variables to estimate intangible assets
###################################################

data_new = (
    ccm_q
    .assign(sic=lambda x: pd.to_numeric(x['sic'], errors='coerce'))
    .query('not (6000 <= sic <= 6799) and (SHRCD == 10 or SHRCD == 11) and (EXCHCD == 1 or EXCHCD == 2 or EXCHCD == 3)')
    .assign(xsgaq=lambda x: x['xsgaq'].fillna(0))
    .groupby('GVKEY')
    .apply(lambda df: df.assign(
            diff_sgaq=df['xsgaq'] - df['xsgaq'].shift(),
            perc_gr=lambda x: x['diff_sgaq'] / df['xsgaq'].shift()
        )
    )
    .reset_index(drop=True)  # You might want to keep or drop the index based on your requirement
)
# data_new.head(50)

# Calculate the average growth rate of SGA
clean_data = data_new['perc_gr'].dropna()
clean_data = clean_data[np.isfinite(clean_data)] #only checks 'perc_gr' column because of the previous command.
avr_sgaq_gr = clean_data.mean() #do not need to specify the column because there is only one column
print(avr_sgaq_gr)
delta_init = 0.15 #from Eisfeldt and Papanikolaou (2013)


###################################################
# Applying functions to compute organization capital
##################################################
import sys
sys.path.append('code/firm_invest/python/pre_process_lev/')
from org_cap_lev import org_cap_pim

ccm_q_intan = data_new.copy()
#ccm_q_intan['org_cap_init'] = ccm_q_intan.groupby('GVKEY')['xsgaq'].transform(lambda x: x.iloc[0] / (avr_sgaq_gr + delta_init))
ccm_q_intan['org_cap_init'] = ccm_q_intan.groupby('GVKEY').apply(lambda x: x['xsgaq'].iloc[0] * (100 / x['cpi']) / (avr_sgaq_gr + delta_init)).reset_index(level=0, drop=True)

# ccm_q_intan['org_cap_comp'] = org_cap_pim(ccm_q_intan['org_cap'], ccm_q_intan['xsgaq'], ccm_q_intan['cpi'], delta_init)

# Function to apply to each group
def apply_org_cap_pim(group):
    group['org_cap_comp'] = org_cap_pim(group['org_cap_init'], group['xsgaq'], group['cpi'], delta_init)
    return group

# Group by GVKEY and apply the function
# grouped_df = ccm_q_intan.groupby('GVKEY')
# result = grouped_df.apply(lambda group: org_cap_pim(group, delta_init)).reset_index(level=0, drop=True)
# ccm_q_intan['org_init_val'] = result

ccm_q_intan = ccm_q_intan.groupby('GVKEY').apply(apply_org_cap_pim).reset_index(level=0, drop=True)

ccm_q_intan[['GVKEY', 'year_month', 'org_cap_init', 'org_cap_comp', 'cpi', 'xsgaq']].head(50)

# grouped_df = ccm_q_intan.groupby('GVKEY')
# result = grouped_df.apply(lambda x: org_cap_pim(x['org_init_val'], x['sga'], x['cpi'], delta_init))

# ccm_q_intan.head(50)
# ccm_q_intan['org_cap_init'].isna().sum()

# ccm_q_intan = (
#     ccm_q_sga_zero
#     .groupby('GVKEY')
#     .apply(
#         lambda df: df.assign(
#             org_cap=lambda x: 0.3 * x['sga_no_na'].iloc[0] / (avr_sgaq_gr + delta_init)
#         ).pipe(lambda df: df.assign(
#             org_cap_comp=lambda x: org_cap_pim(x['org_cap'], x['sga_no_na'], x['cpi'], delta_init)
#         ))
#     )
# )

# def enhance_df(df):
#     df = df.reset_index(drop=True)
#     df['org_cap'] = df['xsgaq'].iloc[0] / (avr_sgaq_gr + delta_init)
#     df['org_cap_comp'] = org_cap_pim(df['org_cap'], df['xsgaq'], df['cpi'], delta_init)
#     return df


# ccm_q_intan = data_new.groupby('GVKEY').apply(enhance_df)
ccm_q_intan_no_zeros = ccm_q_intan[ccm_q_intan['org_cap_comp'] > 0]
ccm_q_intan_no_zeros.shape
ccm_q_intan.shape
#######################################
# Plot the organization capital measure
#######################################

# plot_intan = (
#     ccm_q_intan_no_zeros
#     .assign(intan_tan = lambda x: x['org_cap_comp'] / x['ppentq'])
# )
# Calculate the grouped sum
intan_sum_by_year = ccm_q_intan_no_zeros.groupby('year')['org_cap_comp'].transform('sum')
ccm_q_intan_no_zeros['ppentq_real'] = (ccm_q_intan_no_zeros['ppentq']*100) / ccm_q_intan_no_zeros['cpi']
#ccm_q_intan_no_zeros[['GVKEY', 'year_month', 'cpi', 'ppentq', 'ppentq_real']].head(50)
tang_sum_by_year = ccm_q_intan_no_zeros.groupby('year')['ppentq_real'].transform('sum')

# Adding both 'intan_sum' and 'tang_sum' to the same DataFrame without overwriting
plot_intan = ccm_q_intan_no_zeros.assign(intan_sum=intan_sum_by_year).assign(tang_sum=tang_sum_by_year)

# Then add 'intan_tan'
plot_intan = plot_intan.assign(intan_tan=lambda x: x['intan_sum'] / x['tang_sum'])

# clean_intan_data = plot_intan[plot_intan['intan_tan'].isna()]
# intan_mean = clean_intan_data.groupby('year')['intan_tan'].mean()

clean_intan_data = plot_intan[(plot_intan['intan_tan'].notna()) & (np.isfinite(plot_intan['intan_tan']))]

#intan_mean = plot_intan.dropna(subset=['intan_tan']).groupby('year')['intan_tan'].mean()

# clean_intan_data = (
#     clean_intan_data
#     .assign(intan_mean=lambda x: x['intan_tan'])
# )

#intan_mean = clean_intan_data.groupby('year')[['org_cap_comp', 'ppentq']].sum()
# intan_mean = intan_mean.groupby('year')[['org_cap_comp', 'ppentq']].sum()


intan_mean = clean_intan_data.groupby('year')['intan_tan'].mean()

# Plot the intangible to tangible ratio
intan_mean.plot(kind='line', label = 'Intangible Firms')
plt.title('Average Debt to Total Assets')
plt.xlabel('Quarter')
plt.ylabel('Debt to Total Assets')
plt.legend()
plt.show()


##########################
# Visualize the DataFrame
##########################
print(ccm_q[['date', 'CPI']])
ccm_q_intan[['date', 'GVKEY', 'org_cap', 'org_cap_comp']].head()
cpi.head()
ccm_q_sga_zero.shape
intan_mean.shape
ccm_q_intan_no_zeros.shape
first_five_gvkeys = ccm_q_intan['GVKEY'].unique()[:5]
print(first_five_gvkeys)

ccm_q_intan['org_cap_comp'][ccm_q_intan['GVKEY'] == 1005]

print(ccm_q_intan['org_cap'].equals(ccm_q_intan['org_cap_comp']))

intan_mean.head()

ccm_q_sga_zero['GVKEY'].nunique()
ccm_q_intan_no_zeros['GVKEY'].nunique()
plot_intan['ppentq'].isna().sum()
clean_data.shape
ccm_q['year'].dtype

ccm_q_intan['org_cap'].iloc[0].dtype


# How many missing values in gvkey_year_q?
data_new['xsgaq'].isna().sum()
ccm_q_intan['org_cap'].isna().sum()
np.isinf(data_new['xsgaq']).sum()
np.isinf(data_new['perc_gr']).sum()
ccm_q_intan['GVKEY'].count()



data_new['xsgaq'].dtype
crsp_sel_q['gvkey_year_q'].head()

# find the type of gvkey_year_q
crsp_sel_q['gvkey_year_q'].dtype
ccm_macro_q['GVKEY'].dtype

sorted_columns = clean_data.columns
print(sorted_columns)