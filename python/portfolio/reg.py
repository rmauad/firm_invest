import pandas as pd
import matplotlib.pyplot as plt
from linearmodels.panel import PanelOLS
from statsmodels.api import add_constant

# Read the data from the CSV file
df = pd.read_feather('data/feather/ccm.feather') #from crsp_merge.py

#df = df.assign(date = pd.to_datetime(df["date"], format = '%Y%m%d', errors = "coerce")) #non-conforming entries will be coerced to "Not a Time - NaT"
#df['date'] = pd.to_datetime(df['date'], format='%Y%m%d', errors='coerce')

df.set_index(['GVKEY', 'date'], inplace=True)

# Convert the columns to numeric
df['RET'] = pd.to_numeric(df['RET'], errors='coerce')
df['debt_at'] = pd.to_numeric(df['debt_at'], errors='coerce')

# Creating variables
df['dummy_tx_la_97_03'] = (((df['state'] == 'TX') | (df['state'] == 'LA')) & (df['year'] >= 1997) & (df['year'] <= 2003))
df['RET_lag1'] = df.groupby('GVKEY')['RET'].shift(1)
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['lev_x_dummy'] = df['debt_at_lag1'] * df['dummy_tx_la_97_03']
dep = df['RET']
indep = df[['debt_at_lag1', 'RET_lag1', 'dummy_tx_la_97_03', 'lev_x_dummy']]
indep = add_constant(indep)  # Adds a constant term to the model

# Create the model and fit it
mod = PanelOLS(dep, indep, entity_effects=True)
res = mod.fit()

# Print the results
print(res)
