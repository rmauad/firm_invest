import pandas as pd
import matplotlib.pyplot as plt
import os
import sys
sys.path.append('code/jmp_github/python/')
from data_functions import convert_to_datetime

# Load the data
db_did = pd.read_csv('data/csv/db_did.csv')
db_did['date'] = db_did['year_q'].apply(convert_to_datetime)
db_did['date'] = pd.to_datetime(db_did['date'])

# Generating variables "debt issuance"
db_did['debt_issuance'] = db_did['dltisy'] - db_did['dltry'] + db_did['dlcchy']

# Select firms in the states of TX and LA
#db_did['ter'] = db_did.groupby(['year_q'])['org_cap_comp'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
db_did['intan_at'] = db_did['org_cap_comp'] / db_did['atq']
db_did['ter'] = db_did.groupby(['year_q'])['intan_at'].transform(lambda x: pd.qcut(x, 3, labels = [1, 2, 3]))
#db_did['ter'] = pd.qcut(db_did['intan_at'], 3, labels = [1, 2, 3])
sel_states = db_did[(db_did['state'] == 'TX') | (db_did['state'] == 'LA')]
other_states = db_did[(db_did['state'] != 'TX') & (db_did['state'] != 'LA')]

# Select firms in the tercile of intangible assets
sel_states_intan = sel_states[sel_states['ter'] == 3]
sel_states_tang = sel_states[sel_states['ter'] == 1]
other_states_intan = other_states[other_states['ter'] == 3]
other_states_tang = other_states[other_states['ter'] == 1]


# Plot the average debt issuance for the selected and other states (intangible firms)
debt_issuance_avr_intan = other_states_intan.groupby('date')['debt_issuance'].mean()
debt_issuance_sel_avr_intan = sel_states_intan.groupby('date')['debt_issuance'].mean()
start_date = '1994-01-01'
end_date = '2006-12-31' 
debt_issuance_avr_intan_rest = debt_issuance_avr_intan.loc[start_date:end_date]
debt_issuance_sel_avr_intan_rest = debt_issuance_sel_avr_intan.loc[start_date:end_date]

debt_issuance_avr_intan_rest.plot(kind='line', label = 'Other States')
debt_issuance_sel_avr_intan_rest.plot(kind='line', label = 'TX and LA')
plt.title('Debt Issuance intangible firms')
plt.xlabel('Quarter')
plt.ylabel('Debt Issuance')
plt.legend()
plt.show()

# Plot the average debt issuance for the selected and other states (tangible firms)
debt_issuance_avr_tang = other_states_tang.groupby('date')['debt_issuance'].mean()
debt_issuance_sel_avr_tang = sel_states_tang.groupby('date')['debt_issuance'].mean()
start_date = '1994-01-01'
end_date = '2006-12-31' 
debt_issuance_avr_tang_rest = debt_issuance_avr_tang.loc[start_date:end_date]
debt_issuance_sel_avr_tang_rest = debt_issuance_sel_avr_tang.loc[start_date:end_date]

debt_issuance_avr_tang_rest.plot(kind='line', label = 'Other States')
debt_issuance_sel_avr_tang_rest.plot(kind='line', label = 'TX and LA')
plt.title('Debt Issuance tangible firms')
plt.xlabel('Quarter')
plt.ylabel('Debt Issuance')
plt.legend()
plt.show()

# Print the series of values of the debt_issuance_avr_tang
start_date = '1994-01-01'
end_date = '2005-12-31' 
filtered_data = debt_issuance_sel_avr_tang.loc[start_date:end_date]

print(filtered_data)


# Plot the average equity issuance for the selected and other states
equity_issuance_avr_intan = other_states_intan.groupby('date')['sstky'].mean()
equity_issuance_sel_avr_intan = sel_states_intan.groupby('date')['sstky'].mean()
start_date = '1994-01-01'
end_date = '2006-12-31' 
equity_issuance_avr_intan_rest = equity_issuance_avr_intan.loc[start_date:end_date]
equity_issuance_sel_avr_intan_rest = equity_issuance_sel_avr_intan.loc[start_date:end_date]


equity_issuance_avr_intan_rest.plot(kind='line', label = 'Other States')
equity_issuance_sel_avr_intan_rest.plot(kind='line', label = 'TX and LA')
plt.title('Equity Issuance intangible firms')
plt.xlabel('Quarter')
plt.ylabel('Equity Issuance')
plt.legend()
plt.show()

# Plot the average equity issuance for the selected and other states
equity_issuance_avr_tang = other_states_tang.groupby('date')['sstky'].mean()
equity_issuance_sel_avr_tang = sel_states_tang.groupby('date')['sstky'].mean()
start_date = '1994-01-01'
end_date = '2006-12-31' 
equity_issuance_avr_tang_rest = equity_issuance_avr_tang.loc[start_date:end_date]
equity_issuance_sel_avr_tang_rest = equity_issuance_sel_avr_tang.loc[start_date:end_date]


equity_issuance_avr_tang_rest.plot(kind='line', label = 'Other States')
equity_issuance_sel_avr_tang_rest.plot(kind='line', label = 'TX and LA')
plt.title('Equity Issuance tangible firms')
plt.xlabel('Quarter')
plt.ylabel('Equity Issuance')
plt.legend()
plt.show()


print(db_did['state'].describe())