# Function to convert year_q to datetime
import pandas as pd

def convert_to_datetime(yearq):
    year = str(yearq)[:4]
    quarter = str(yearq)[-1]
    # Construct a date string with the first month of the given quarter
    if quarter == '1':
        return pd.to_datetime(year + '-01-01')
    elif quarter == '2':
        return pd.to_datetime(year + '-04-01')
    elif quarter == '3':
        return pd.to_datetime(year + '-07-01')
    elif quarter == '4':
        return pd.to_datetime(year + '-10-01')
