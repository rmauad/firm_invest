org_cap_ar <- function(org_init_val, sga, cpi, delta_init) {
  if (length(org_init_val) >= 2){
    for(i in 2:length(org_init_val)){
      org_init_val[i] <- (1 - delta_init)*org_init_val[i-1] + sga[i] #/cpi[i]) #30% of SG&A becomes organization capital.
  }
  }
  return(org_init_val)
} 