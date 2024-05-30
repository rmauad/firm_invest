# Unused

# ccm_q = ccm_q.assign(
#     CPI=lambda df: df.groupby('GVKEY').apply(
#         lambda x: np.exp(np.cumsum(np.log(1 + x['inflation'] / 100)))
#     ).reset_index(level=0, drop=True)
# ).pipe(
#         lambda df: df.assign(
#             CPI = lambda x: x['CPI'] * 100 / x.loc[x['date'].eq('2015-12-31'), 'CPI'].iloc[0]
#             )
#     )