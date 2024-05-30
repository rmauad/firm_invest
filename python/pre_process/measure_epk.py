import pandas as pd
import numpy as np
# import os
# print(os.getcwd())

##################################
# Loading and importing dataframes (import one at a time)
##################################

ccm_q = pd.read_feather("data/feather/ccm_q.feather") #from merge_cc_q.py
cpi = pd.read_excel('data/excel/CPI.xls')
cpi = cpi.rename(columns={'date': 'year'})

##################################
# Selecting and treating variables
##################################
ccm_q = (
    ccm_q.
    rename(columns={'CPI': 'inflation'})
    .assign(
        year = lambda x: x['date'].dt.year,
    )
)

ccm_q = pd.merge(ccm_q, cpi, on='year')

###################################################
# Creating variables to estimate intangible assets
###################################################

ccm_q_sga_zero = (
    ccm_q
    .assign(sga_zeros=lambda x: x['xsgaq'].fillna(0))
)

# From Eisfeldt and Papanikolaou (2013)

data_new = (
    ccm_q_sga_zero
    .assign(sic_int=lambda df: pd.to_numeric(df['sic'], errors='coerce'))
    .dropna(subset=['sic_int'])
    .query('year <= 2008 and not (6000 <= sic_int <= 6799) and (SHRCD == 10 or SHRCD == 11) and (EXCHCD == 1 or EXCHCD == 2 or EXCHCD == 3)')
    .groupby('GVKEY')
    .apply(
        lambda df: df.assign(
            diff_sgaq=df['sga_zeros'] - df['sga_zeros'].shift(),
            perc_gr=lambda x: x['diff_sgaq'] / df['sga_zeros'].shift()
        )
    )
    .reset_index(drop=True)  # You might want to keep or drop the index based on your requirement
)


clean_data = data_new['perc_gr'].dropna()
clean_data = clean_data[np.isfinite(clean_data)] #only checks 'perc_gr' column because of the previous command.
avr_sgaq_gr = clean_data.mean() #do not need to specify the column because there is only one column
print(avr_sgaq_gr)

##########################
# Visualize the DataFrame
##########################
print(ccm_q[['date', 'CPI']])
ccm_q[['date', 'cpi']].head()
cpi.head()
ccm_q.shape
ccm_q['GVKEY'].nunique()
data_new['GVKEY'].nunique()
data_new['xsgaq'].isna().sum()
clean_data.shape
ccm_q['year'].dtype

# How many missing values in gvkey_year_q?
data_new['xsgaq'].isna().sum()
ccm_q_sga_zero['sga_zeros'].isna().sum()
np.isinf(data_new['xsgaq']).sum()
np.isinf(data_new['perc_gr']).sum()


data_new['xsgaq'].dtype
crsp_sel_q['gvkey_year_q'].head()

# find the type of gvkey_year_q
crsp_sel_q['gvkey_year_q'].dtype
ccm_macro_q['GVKEY'].dtype

sorted_columns = clean_data.columns
print(sorted_columns)