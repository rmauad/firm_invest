import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option('display.max_rows', 100)
pd.set_option('display.max_columns', 30)
pd.set_option('display.width', 1000)
##################
# Check the data
##################

df_sel_filled['GVKEY'].nunique()
df['GVKEY'][df['state'] == 'LA'].nunique()
df['debt_at'][df['state'] == 'AL'].isna().sum()
df['debt_at'][df['state'] == 'AL'].describe()
df['debt_at'][df['state'] == 'TX'].describe()
print(df_treated.shape)

sorted_columns = sorted(df_treated.columns)
print(sorted_columns)

df['debt_cap'][(df['year_q'] == '1997Q2') & (df['GVKEY'] != 23942) & (df['GVKEY'] != 1755)].describe()
df['debt_cap'][(df['year_q'] == '1997Q3') & (df['GVKEY'] != 23942)].describe()

df[['GVKEY', 'debt_cap']][df['year_q'] == '1997Q2'].min()
sorted_df = df[df['year_q'] == '1997Q2'].sort_values('debt_cap', ascending=True)
lowest_leverage_firm = sorted_df[['GVKEY', 'debt_cap']].iloc[1]
print(lowest_leverage_firm)
df['GVKEY'].dtype

df_sel_filled[df_sel_filled['month'] == 2].head(50)

df_sel_filled['month'].min()
df_treated.head(50)

df_sel_filled.shape