import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.linear_model import Ridge
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score

# To run a Double Machine Learning Estimator, use ridge and lasso specifications 
# to estimate intangible capital from firm characteristics. Then, use this new intangible 
# measure to explore the effect of interest rate fluctuations on firm investment.

df = pd.read_csv('data/csv/db_reg.csv') #created by pre_process_dta.R
# sorted_columns = sorted(df.columns)
# print(sorted_columns)

# Creating the variables to be used in the regressions
df['log_assets_lag1'] = df.groupby('GVKEY')['atq'].apply(np.log).shift(1)  
df['log_assets_squared_lag1'] = df['log_assets_lag1']**2
df['debt_at_lag1'] = df.groupby('GVKEY')['debt_at'].shift(1)
df['debt_at_squared_lag1'] = df['debt_at_lag1']**2
df['cash_at_lag1'] = df.groupby('GVKEY')['cash_at'].shift(1)
df['log_intan'] = df['org_cap_comp'].apply(np.log)   
df_clean = df.dropna()

X = df_clean[['log_assets_lag1', 'log_assets_squared_lag1', 'sales_growth_lag1', 'debt_at_lag1', 'debt_at_squared_lag1', 'cash_at_lag1']]
y = df_clean['log_intan']

# Standardize the features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

ridge = Ridge(alpha = .8)
ridge.fit(X_train, y_train)

# Predict the test set 
y_pred = ridge.predict(X_test)

# Evaluate the model
print("Mean Squared Error:", mean_squared_error(y_test, y_pred))
print("Coefficient of Determination (R^2):", r2_score(y_test, y_pred))

# Access the model's coefficients
print("Coefficients:", ridge.coef_)

# Plot predicted vs. test set.
plt.figure(figsize=(10, 6))

# Scatter plot of actual vs. predicted values
plt.scatter(y_test, y_pred, alpha=0.5)
plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], '--', lw=2, color='red')
plt.xlabel('Actual')
plt.ylabel('Predicted')
plt.title('Actual vs. Predicted Values')
plt.show()