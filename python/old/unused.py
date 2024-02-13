# Plot the average debt to assets ratio over time
df['tot_liab'] = df['dlcq'] + df['dlttq'] + df['ceqq']

tot_liab_avr = df.groupby('year_q')['tot_liab'].mean()
tot_at_avr = df.groupby('year_q')['atq'].mean()
debt_eq_at = tot_liab_avr/tot_at_avr


debt_eq_at.plot(kind='line')
plt.title('Total liabilities to Total Assets')
plt.xlabel('Quarter')
plt.ylabel('')
plt.show()

# Group by time period and calculate mean
debt_at_intan = intan_firms.groupby('year_q')['debt_at'].mean()
debt_at_tang = tang_firms.groupby('year_q')['debt_at'].mean()

# Plot the average debt to assets ratio over time
debt_at_intan.plot(kind='line', label = 'Intangible Firms')
debt_at_tang.plot(kind='line', label = 'Tangible Firms')
plt.title('Average Debt to Assets Ratio Over Time')
plt.xlabel('Time Period')
plt.ylabel('Average Debt to Assets Ratio')
plt.legend()
plt.show()


# Plot the average debt to (debt + equity) ratio over time
df['tot_liab'] = df['dlcq'] + df['dlttq'] + df['ceqq']
df['debt_tot_liab'] = (df['dlcq'] + df['dlttq'])/df['tot_liab']
df['debt'] = df['dlcq'] + df['dlttq']

intan_firms = df[df['ter_top'] == 1]
tang_firms = df[df['ter_bot'] == 1]

# Group by time period and calculate mean
eq = df.groupby('year_q')['ceqq'].mean()
tot_liab = df.groupby('year_q')['tot_liab'].mean()
debt = df.groupby('year_q')['debt'].mean()
debt_tot_liab = df.groupby('year_q')['debt_tot_liab'].mean()
debt_tot_liab_intan = intan_firms.groupby('year_q')['debt_tot_liab'].mean()
debt_tot_liab_tang = tang_firms.groupby('year_q')['debt_tot_liab'].mean()

# Plot the average debt to assets ratio over time
debt_tot_liab_intan.plot(kind='line', label = 'Intangible Firms')

debt_tot_liab.plot(kind='line', label = 'Tangible Firms')
plt.title('Average Debt to Total liabilites')
plt.xlabel('Quarter')
plt.ylabel('')
plt.legend()
plt.show()