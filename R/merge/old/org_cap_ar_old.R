org_cap_ar <- function(org_init_val, sga, cpi, delta_init) {
  if (length(org_init_val) == 1){
    org_init_val <- (1 - delta_init)*org_init_val + 0.3*(sga/cpi)*100}
  
  if (length(org_init_val) >= 2){
    org_init_val[1] <- (1 - delta_init)*org_init_val[1] + 0.3*(sga[1]/cpi[1])*100
    
    for(i in 2:length(org_init_val)){
      org_init_val[i] <- (1 - delta_init)*org_init_val[i-1] + 0.3*(sga[i]/cpi[i])*100 #30% of SG&A becomes organization capital.
  }
  }
  return(org_init_val)
} 