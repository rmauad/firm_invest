import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge, RidgeCV, LassoCV
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error

# To run a Double Machine Learning Estimator, use ridge and lasso specifications 
# to estimate intangible capital from firm characteristics. Then, use this new intangible 
# measure to explore the effect of interest rate fluctuations on firm investment.

df_dml = pd.read_csv('data/csv/db_reg_dml.csv') #from dml.py

df_dml['intan_ridge_cap'] = df_dml['intan_ridge']/(df_dml['intan_ridge'] + df_dml['ppegtq'])
# Create terciles based on intan_ridge_cap grouping by year_q
df_dml['ter_ridge'] = df_dml.groupby(['year_q'])['intan_ridge_cap'].transform(lambda x: pd.qcut(x, 3, labels=False))
df_dml['ter_ridge_top'] = np.where(df_dml['ter_ridge'] == 2, 1, 0)
df_dml['ter_ridge_bot'] = np.where(df_dml['ter_ridge'] == 0, 1, 0)

# Saving the dataframe to dta
df_dml.to_stata('data/dta/db_reg_dml.dta')

########################
# Visualizing the data
########################

sorted_columns = sorted(df_dml.columns)
print(sorted_columns)
# print(df_dml['intan_ridge_cap'].describe())
# print(df_dml['intan_cap'].describe())