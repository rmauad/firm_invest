gen log_rgdp = log(RGDP)
gen dlog_rgdp = .

// Sort the dataset by firm and year to ensure the data is in the correct order
sort GVKEY year

// Use a forval loop to loop through each firm
levelsof GVKEY, local(firm_list)
foreach GVKEY of local firm_list {
    // Sort the data by firm and year again (just to be safe)
    sort GVKEY year

    // Generate a new variable that stores the lagged expenses for each firm
	by GVKEY: replace dlog_rgdp =  log_rgdp -  log_rgdp[_n-1] if _n > 1
}
