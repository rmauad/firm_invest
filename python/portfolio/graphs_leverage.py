import pandas as pd
import matplotlib.pyplot as plt

# Read the data from the feather file
df = pd.read_feather('data/feather/ccm_monthly_filled.feather') #from crsp_merge_monthly.py
# df.columns
# Generate leverage and drop NAs based on the leverage
df = (df
      .assign(year = df['date_ret'].dt.year)
      .assign(debt_at = (df['dlttq'] + df['dlcq']) / df['atq'])
      #.assign(debt_at = (df['loq'] / df['atq']))      
      .query('year >= 1980 and ceqq > 0')
      )

df_tx = df[(df['state'] == 'TX') & (df['year'] >= 1996) & (df['year'] <= 2003)]

df_tx = (df_tx
         .assign(year_month = df_tx['date_ret'].dt.to_period('M'))
         .sort_values('year_month')
         .groupby('year_month')
         .agg(mean_debt_at=('debt_at', 'mean'))
         .reset_index()
)

# Plot the leverage
fig, ax = plt.subplots()
df_tx.plot(x='year_month', y='mean_debt_at', ax=ax, legend=False)
ax.set_title('Average Leverage Over Time')
ax.set_xlabel('Year-Month')
ax.set_ylabel('Average Leverage (debt_at)')
plt.show()

