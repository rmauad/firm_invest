import pandas as pd
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/jmp_github/python/')
from data_functions import convert_to_datetime

# Load the data
cap_struct = pd.read_csv('data/csv/cap_struct.csv')
df = pd.read_csv('data/csv/db_reg.csv')

# Convert year_q (currently an int) to datetime at the quarterly frequency
df['year_q'] = df['year_q'].apply(convert_to_datetime).dt.to_period('Q')
df = df.drop('dltisy', axis = 1)

# Convert datadate to datetime at the quarterly frequency
cap_struct['year_q'] = pd.to_datetime(cap_struct['datadate']).dt.to_period('Q')

# Merge the data
df_merge = pd.merge(df, cap_struct, on = ['GVKEY', 'year_q'], how = 'left')

# Save df_merge
df_merge.to_csv('data/csv/db_did.csv', index = False)

