import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option('display.max_rows', 100)
pd.set_option('display.max_columns', 30)
pd.set_option('display.width', 1000)

##################
# Check the data
##################

# Checking shape, number of unique firms, max and min of specific values
df.shape
df['GVKEY'].nunique()
df_sel_filled['month'].min()
df['GVKEY'][df['state'] == 'LA'].nunique()
df['debt_at'][df['state'] == 'AL'].isna().sum()
df['debt_at'][df['state'] == 'AL'].describe()
print(df.index.get_level_values('GVKEY').unique())
print(df.index.get_level_values('date').unique())
print(df['date'].head())
print(df['date'].isnull().sum())

# Checking for negative values
num_negatives = len([x for x in df['GVKEY'] if x < 0])


# Sorting the columns
sorted_columns = sorted(df.columns)
print(sorted_columns)

# Checking the types of the columns
ret_data_type = df['date'].dtype
print(ret_data_type) 

df_sel['date'].dtype()

# Visualizing the data
df[df['GVKEY', 'date']].head(50)
df_sel_filled[df_sel_filled['month'] == 2].head(50)
df.head()

# Finding outliers in a graph
df[['GVKEY', 'debt_cap']][df['year_q'] == '1997Q2'].min()
df['debt_cap'][(df['year_q'] == '1997Q3') & (df['GVKEY'] != 23942)].describe()
sorted_df = df[df['year_q'] == '1997Q2'].sort_values('debt_cap', ascending=True)

lowest_leverage_firm = sorted_df[['GVKEY', 'debt_cap']].iloc[1]
print(lowest_leverage_firm)

# View attributes of a model
print(dir(mod))



