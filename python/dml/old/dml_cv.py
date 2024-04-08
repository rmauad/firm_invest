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

df = pd.read_csv('data/csv/db_reg.csv') #created by pre_process_dta.R
# sorted_columns = sorted(df.columns)
# print(sorted_columns)

# Creating the variables to be used in the regressions
df['log_assets_lag1'] = df.groupby('GVKEY')['atq'].apply(np.log).shift(1)  
df['log_assets_squared_lag1'] = df['log_assets_lag1']**2
df['log_assets_lag2'] = df.groupby('GVKEY')['atq'].apply(np.log).shift(2)  
df['log_assets_squared_lag2'] = df['log_assets_lag2']**2
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['debt_at_squared_lag1'] = df['debt_at_lag1']**2
df['debt_at_lag2'] = df.groupby('GVKEY')['debt_at'].shift(2)
df['debt_at_squared_lag2'] = df['debt_at_lag2']**2
df['debt_at_lag3'] = df.groupby('GVKEY')['debt_at'].shift(3)
df['debt_at_squared_lag3'] = df['debt_at_lag3']**2
df['cash_at_lag1'] = df.groupby('GVKEY')['cash_at'].shift(1)
df['cash_at_squared_lag1'] = df['cash_at_lag1']**2
df['cash_at_lag2'] = df.groupby('GVKEY')['cash_at'].shift(2)
df['cash_at_squared_lag2'] = df['cash_at_lag2']**2
df['capex_lag1'] = df.groupby('GVKEY')['capxy'].shift(1)
df['capex_squared_lag1'] = df['capex_lag1']**2
df['capex_lag2'] = df.groupby('GVKEY')['capxy'].shift(2)
df['capex_squared_lag2'] = df['capex_lag2']**2
df['sales_growth_squared_lag1'] = df['sales_growth_lag1']**2
df['sales_growth_lag2'] = df.groupby('GVKEY')['sales_growth_lag1'].shift(1)
df['sales_growth_squared_lag2'] = df['sales_growth_lag2']**2
# df['log_sga_lag1'] = df.groupby('GVKEY')['xsgaq'].apply(np.log).shift(1)
# df['log_sga_squared_lag1'] = df['log_sga_lag1']**2
# df['log_sga_lag2'] = df.groupby('GVKEY')['xsgaq'].apply(np.log).shift(2)
# df['log_sga_squared_lag2'] = df['log_sga_lag2']**2
# df['log_rd_lag1'] = df.groupby('GVKEY')['xrdq'].apply(np.log).shift(1)
# df['log_rd_squared_lag1'] = df['log_rd_lag1']**2
# df['log_rd_lag2'] = df.groupby('GVKEY')['xrdq'].apply(np.log).shift(2)
# df['log_rd_squared_lag2'] = df['log_rd_lag2']**2
df['log_intan'] = df['org_cap_comp'].apply(np.log)
df_clean = df.dropna()

# Select only numeric columns for the np.isfinite() check
# numeric_cols = df_clean.select_dtypes(include=[np.number]).columns

# df_clean = df_clean[(np.isfinite(df_clean[numeric_cols])).all(axis=1)]

#df_clean = df_clean[(np.isfinite(df_clean)).all(axis=1)]

# X = df_clean[['log_assets_lag1', 'log_assets_squared_lag1', 'log_assets_lag2', 'log_assets_squared_lag2', 'debt_at_lag1', 'debt_at_squared_lag1', 'debt_at_lag2', 'debt_at_squared_lag2', 'cash_at_lag1', 'cash_at_squared_lag1', 'cash_at_lag2', 'cash_at_squared_lag2', 'capex_lag2', 'capex_squared_lag2', 'sales_growth_lag1', 'sales_growth_squared_lag1', 'sales_growth_lag2', 'sales_growth_squared_lag2', 'log_rd_lag1', 'log_rd_squared_lag1', 'log_rd_lag2', 'log_rd_squared_lag2']]
X = df_clean[['log_assets_lag1', 'log_assets_squared_lag1', 'log_assets_lag2', 'log_assets_squared_lag2', 'debt_at_lag1', 'debt_at_squared_lag1', 'debt_at_lag2', 'debt_at_squared_lag2', 'debt_at_lag3', 'debt_at_squared_lag3', 'cash_at_lag1', 'cash_at_squared_lag1', 'cash_at_lag2', 'cash_at_squared_lag2', 'capex_lag2', 'capex_squared_lag2', 'sales_growth_lag1', 'sales_growth_squared_lag1', 'sales_growth_lag2', 'sales_growth_squared_lag2']]
y = df_clean['log_intan']

# Standardize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

# Define a range of alpha values to test
alphas = np.logspace(-6, 6, 13)

# Ridge and Lasso regressions
ridge_cv = RidgeCV(alphas = alphas, store_cv_values=True)
ridge_cv.fit(X_train, y_train)

lasso_cv = LassoCV(alphas = alphas, cv=5)
lasso_cv.fit(X_train, y_train)

# The best alpha value found
print('Best alpha value Ridge:', ridge_cv.alpha_)
print('Best alpha value Lasso:', lasso_cv.alpha_)

# Predict the test set 
y_pred_ridge = ridge_cv.predict(X_test)
y_pred_lasso = lasso_cv.predict(X_test)

# Evaluate the model
print("MAE:", mean_absolute_error(y_test, y_pred_ridge))
print("MSE:", mean_squared_error(y_test, y_pred_ridge))
print("RMSE:", mean_squared_error(y_test, y_pred_ridge, squared=False))
print("R-squared:", r2_score(y_test, y_pred_ridge))


# Access the model's coefficients
print("Coefficients:", ridge_cv.coef_)
print("Coefficients:", lasso_cv.coef_)


# Plot predicted vs. test set.
plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred_ridge, alpha=1)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], '--', lw=2, color='red')
plt.xlabel('Actual')
plt.ylabel('Predicted')
plt.title('Actual vs. Predicted Values Ridge Regression')
plt.show()

# Plot residuals
residuals = y_test - y_pred_ridge
plt.scatter(y_pred_ridge, residuals)
plt.hlines(y=0, xmin=y_pred_ridge.min(), xmax=y_pred_ridge.max(), colors='red')
plt.xlabel('Predicted Values')
plt.ylabel('Residuals')
plt.title('Residual Plot')
plt.show()

# Plot predicted vs. test set.
plt.figure(figsize=(10, 6))
plt.scatter(y_test, y_pred_lasso, alpha=1)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], '--', lw=2, color='red')
plt.xlabel('Actual')
plt.ylabel('Predicted')
plt.title('Actual vs. Predicted Values Lasso Regression')
plt.show()