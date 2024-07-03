# Function to add significance stars
def add_stars(tstat):
    if abs(tstat) >= 2.58:
        return '***'
    elif abs(tstat) >= 1.96:
        return '**'
    elif abs(tstat) >= 1.645:
        return '*'
    else:
        return ''