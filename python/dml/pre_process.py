import pandas as pd
import numpy as np

# To run a Double Machine Learning Estimator, use ridge and lasso specifications 
# to estimate intangible capital from firm characteristics. Then, use this new intangible 
# measure to explore the effect of interest rate fluctuations on firm investment.

df_dml = pd.read_csv('data/csv/db_reg_dml.csv') #from dml_lasso.py

df_dml['intan_lasso_cap'] = df_dml['intan_lasso']/(df_dml['intan_lasso'] + df_dml['ppegtq'])
# Create terciles based on intan_ridge_cap grouping by year_q
df_dml['ter_lasso'] = df_dml.groupby(['year_q'])['intan_lasso_cap'].transform(lambda x: pd.qcut(x, 3, labels=False))
df_dml['ter_lasso_top'] = np.where(df_dml['ter_lasso'] == 2, 1, 0)
df_dml['ter_lasso_bot'] = np.where(df_dml['ter_lasso'] == 0, 1, 0)

# Saving the dataframe to dta
df_dml.to_stata('data/dta/db_reg_dml.dta')

########################
# Visualizing the data
########################

sorted_columns = sorted(df_dml.columns)
print(sorted_columns)
# print(df_dml['intan_ridge_cap'].describe())
# print(df_dml['intan_cap'].describe())