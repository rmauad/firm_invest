import pandas as pd

compustat = pd.read_csv('data/csv/comp_fundq.csv')

compustat['GVKEY'].nunique()
#compustat.loc(compustat['state'] == 'TX' | compustat['state'] == 'LA',:)