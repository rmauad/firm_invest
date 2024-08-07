import pandas as pd
from tabulate import tabulate

df = pd.read_feather('data/feather/df_fm.feather') # from prep_fm.py
# df_vars[['debt_at', 'lev_new']].tail(50)
df_vars = ['me', 'lev', 'd_lev', 'bm', 'ln_at']
variable_labels = {
    'lev': 'Leverage',
    'd_lev': 'Leverage change',
    'd_debt_at': 'Debt/assets change',
    'ln_ceqq': 'Log(equity)',
    'roa': 'Return on Assets',
    'beta': 'Beta',
    'bm': 'Book-to-Market Ratio',
    'me': 'Market value of equity'
}

mean = df[df_vars].mean()
std = df[df_vars].std()
median = df[df_vars].median()

summary_stats = pd.DataFrame({
    'Variable': df_vars,
    'Mean': mean,
    'Median': median,
    'Standard Deviation': std
})

# Apply formatting
summary_stats['Mean'] = summary_stats.apply(lambda row: f"{row['Mean']:.4f}" if row['Variable'] == 'd_debt_at' else f"{row['Mean']:.2f}", axis=1)
summary_stats['Median'] = summary_stats.apply(lambda row: f"{row['Median']:.4f}" if row['Variable'] == 'd_debt_at' else f"{row['Median']:.2f}", axis=1)
summary_stats['Standard Deviation'] = summary_stats.apply(lambda row: f"{row['Standard Deviation']:.4f}" if row['Variable'] == 'd_debt_at' else f"{row['Standard Deviation']:.2f}", axis=1)
summary_stats['Variable'] = summary_stats['Variable'].map(variable_labels)
summary_stats.set_index('Variable', inplace=True)
print(summary_stats)

latex_table = tabulate(summary_stats, headers='keys', tablefmt='latex', floatfmt=".2f")
print(latex_table)
