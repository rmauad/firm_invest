from tabulate import tabulate

# Helper function to extract relevant information and return a formatted DataFrame
def format_model_summary(model):
    # Extract the summary as a DataFrame
    results_df = model.summary_frame()
    # Renaming columns for better readability
    results_df.rename(columns={'coef': 'Coefficient', 'std err': 'Standard Error', 'P>|t|': 'p-value'}, inplace=True)
    # Selecting columns and rounding to 2 decimal places
    results_df = results_df[['Coefficient', 'Standard Error', 'p-value']].round(2)
    return results_df

# Function to save DataFrame as a clean LaTeX table
def save_latex_table(df, filename, caption, label):
    latex_table = tabulate(df, tablefmt="latex_booktabs", headers="keys", showindex=True, floatfmt=".4f")
    latex_table = f"\\begin{{table}}[ht]\n\\centering\n\\caption{{{caption}}}\n\\label{{{label}}}\n{latex_table}\n\\end{{table}}"
    with open(filename, 'w') as f:
        f.write(latex_table)

