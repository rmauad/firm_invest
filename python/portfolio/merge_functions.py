# Functions for merging dataframes

def custom_fill(group):
    group['atq'] = group['atq'].interpolate()
    group['capxy'] = group['capxy'].interpolate()
    group['cash_at'] = group['cash_at'].interpolate()
    group['debt_at'] = group['debt_at'].interpolate()
    group['org_cap_comp'] = group['org_cap_comp'].interpolate()
    group['ppentq'] = group['ppentq'].interpolate()
    group['state'] = group['state'].ffill()
    return group