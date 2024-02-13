org_init <- function(sga,delta_init, sga_avr_gr) {
  init_org <- 0.3*sga[1]/(sga_avr_gr + delta_init)
    return(init_org)
} 