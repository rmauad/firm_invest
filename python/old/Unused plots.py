# Unused plots


# Plot the yearly average of k_int_at for all firms
int_at = df.groupby('year')['int_at'].mean()
int_at.plot(kind='line')
plt.title('Average Intangible Assets to Total Assets')
plt.xlabel('Year')
plt.ylabel('Intangible Assets to Total Assets')
plt.show()

# Plot the yearly average of k_int_at for all tangible and intangible firms
int_at_intan = intan_firms.groupby('year')['int_at'].mean()
int_at_intan.plot(kind='line')
plt.title('Average Intangible Assets to Total Assets')
plt.xlabel('Year')
plt.ylabel('Intangible Assets to Total Assets')
plt.show()

# Plot the yearly average of k_int_at for all tangible and tangible firms
int_at_tang = tang_firms.groupby('year')['int_at'].mean()
int_at_tang.plot(kind='line')
plt.title('Average Intangible Assets to Total Assets')
plt.xlabel('Year')
plt.ylabel('Intangible Assets to Total Assets')
plt.show()


# Sum org_cap_comp by year removing nas
df['sum_intan'] = df.groupby('year')['org_cap_comp'].transform('sum')
df['sum_tang'] = df.groupby('year')['ppentq'].transform('sum')
df['int_tang'] = df['sum_intan'] / df['sum_tang']

#df_clean = df.dropna(subset=['int_tang'])
# df_filtered = df[~np.isinf(df['int_tang'])]
int_at_tang = df.groupby('year')['int_tang'].mean()
#int_at_tang = df['int_tang']
int_at_tang.plot(kind='line')
plt.title('Average Intangible Assets to Tangible Assets')
plt.xlabel('Year')
plt.ylabel('Intangible Assets to Tangible Assets')
plt.show()

import numpy as np
# Print the number of infinite values in int_tang
num_inf_int_tang = np.isinf(df['int_tang']).sum()
print(f"Number of zeros in 'int_tang': {num_inf_int_tang}")

# Print the number of zero values in df['sum_intan']
num_inf_int_tang = np.isnan(df['sum_intan']).sum()
print(f"Number of zeros in 'sum_intan': {num_inf_int_tang}")


# Print values for int_tang in 1997 with a column for year_q
df_1997 = df[df['year'] == 1997]
print(df_1997[['int_tang', 'year_q']])
print(df_1997['int_tang'].describe())


# Count unique firms in the state of AL between 2001 and 2003

# Filter for the years 2001 to 2003
df_2001_2003 = df[(df['date'] >= '2001-01-01') & (df['date'] <= '2003-12-31')]
# Filter for the state of AL
df_2001_2003_AL = df_2001_2003[df_2001_2003['state'] == 'AL']
# Count the unique firms
unique_firms_AL = df_2001_2003_AL['GVKEY'].nunique()
print(unique_firms_AL)

print(df.shape)
