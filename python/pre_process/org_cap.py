import pandas as pd
import numpy as np

# def org_init(sga, delta_init, sga_avr_gr):
#     init_org = 0.3 * sga.iloc[0] / (sga_avr_gr + delta_init)
#     return init_org

# def org_cap_pim(org_init_val, sga, cpi, delta_init):

#     # Check if org_init_val has at least two elements
#     if len(org_init_val) >= 2:
#         # Iterate over the range starting from the second element (index 1 in Python)
#         for i in range(1, len(org_init_val)):
#             # Update org_init_val at index i
#             org_init_val[i] = (1 - delta_init) * org_init_val[i - 1] + (sga[i]*100)  / cpi[i] # optional use

#     return org_init_val

# def org_cap_pim(org_init_val, sga, cpi, delta_init):
#     # Assuming org_init_val, sga, cpi can be scalars or arrays, handle accordingly
#     if np.isscalar(org_init_val):
#         # Handle scalar case: no loop needed, just a direct operation
#         return org_init_val  # Modify as needed
#     else:
#         # Handle series/array case: your original logic
#         if len(org_init_val) >= 2:
#             for i in range(1, len(org_init_val)):
#                 org_init_val[i] = (1 - delta_init) * org_init_val[i - 1] + (sga[i] * 100) / cpi[i]
#         return org_init_val
    

# def org_cap_pim(org_init_val, sga, cpi, delta_init):
#     # Assuming org_init_val, sga, cpi can be scalars or arrays, handle accordingly
#     if np.isscalar(org_init_val):
#         # Handle scalar case: no loop needed, just a direct operation
#         return org_init_val  # Modify as needed
#     else:
#         # Handle series/array case: your original logic
#         if len(org_init_val) >= 2:
#             for i in range(1, len(org_init_val)):
#                 org_init_val[i] = (1 - delta_init) * org_init_val[i - 1] + (sga[i] * 100) / cpi[i]
#         return org_init_val
    

def org_cap_pim(org_init_val, sga, cpi, delta_init):
    # Assuming org_init_val, sga, cpi can be scalars or arrays, handle accordingly
    if len(org_init_val) < 2:
        # Handle scalar case: no loop needed, just a direct operation
        return org_init_val  # Modify as needed
    else:
            for i in range(1, len(org_init_val)):
                org_init_val[i] = (1 - delta_init) * org_init_val[i - 1] + sga[i] #/ cpi[i]
                return org_init_val