import pandas as pd
import numpy as np

def org_cap_pim(org_init_val, sga, cpi, delta_init):
    org_init_val = org_init_val.copy()  # Ensure we're not modifying the original Series
    if len(org_init_val) < 2:
        # Handle scalar case: no loop needed, just a direct operation
        return org_init_val  # Modify as needed
    else:
            for i in range(1, len(org_init_val)):
                org_init_val.iloc[i] = (1 - delta_init) * org_init_val.iloc[i - 1] + (100*sga.iloc[i]) / cpi.iloc[i]
            return org_init_val

# def org_cap_pim(group, delta_init):
#     org_init_val = group['org_init_val'].copy()
#     sga = group['sga']
#     cpi = group['cpi']

#     if len(org_init_val) < 2:
#         # Handle scalar case: no loop needed, just a direct operation
#         return org_init_val  # Modify as needed
#     else:
#         for i in range(1, len(org_init_val)):
#             org_init_val.iloc[i] = (1 - delta_init) * org_init_val.iloc[i - 1] + (100 * sga.iloc[i]) / cpi.iloc[i]
#         return org_init_val