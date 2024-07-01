import pandas as pd
import statsmodels.api as sm
from statsmodels.regression.rolling import RollingOLS


# def rolling_ols(y, X):
#     model = sm.OLS(y, sm.add_constant(X)).fit()
#     return model.params

def rolling_regression(df, window_length):
    #df['year_month'] = pd.to_datetime(df['year_month'].astype(str), format='%Y-%m')
    results = []

    for key, group in df.groupby('GVKEY'):
        if len(group) < window_length:
            # Skip groups with fewer data points than the rolling window size
            continue

        group = group.set_index('year_month')
        group = group.sort_index()
        
        # Prepare the dependent and independent variables
        y = group['ret_rf']
        X = sm.add_constant(group['mkt_rf'])

        # Apply RollingOLS
        rolling_model = RollingOLS(y, X, window=window_length)
        rolling_params = rolling_model.fit().params

        # Add GVKEY and reset index
        rolling_params = rolling_params.reset_index()
        rolling_params['GVKEY'] = key
        results.append(rolling_params)
    
    results_df = pd.concat(results)
    return results_df


