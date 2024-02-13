ff_ind <- function(sic) {
if (sic >= 100 & sic <= 999 | sic >= 2000 & sic <= 2399 |
    sic >= 2700 & sic <= 2749 | sic >= 3100 & sic <= 3199 |
    sic >= 3940 & sic <= 3989) 
  {ff_ind = 1}
  else if (sic >= 2500 & sic <= 2519 | sic >= 2590 & sic <= 2599 |
           sic >= 3630 & sic <= 3659 | sic >= 3710 & sic <= 3711 |
           sic == 3714 | sic == 3716 | sic >= 3750 & sic <= 3751 |
           sic == 3792 | sic >= 3900 & sic <= 3939 | sic >= 3990 & sic <= 3999)
  {ff_ind = 2}
  else if (sic >= 2520 & sic <= 2589 | sic >= 2600 & sic <= 2699 | sic >= 2750 & sic <= 2769 |
           sic >= 3000 & sic <= 3099 | sic >= 3200 & sic <= 3569 | sic >= 3580 & sic <= 3629 |
           sic >= 3700 & sic <= 3709 | sic >= 3712 & sic <= 3713 | sic == 3715 | sic >= 3717 & sic <= 3749 |
           sic >= 3752 & sic <= 3791 | sic >= 3793 & sic <= 3799 | sic >= 3830 & sic <= 3839 |
           sic >= 3860 & sic <= 3899)
  {ff_ind = 3}
  else if (sic >= 1200 & sic <= 1399 | sic >= 2900 & sic <= 2999)
  {ff_ind = 4}
  else if (sic >= 2800 & sic <= 2829 | sic >= 2840 & sic <= 2899)
  {ff_ind = 5}
  else if (sic >= 3570 & sic <= 3579 | sic >= 3660 & sic <= 3692 | sic >= 3694 & sic <= 3699 |
           sic >= 3810 & sic <= 3829 | sic >= 7370 & sic <= 7379)
  {ff_ind = 6}
  else if (sic >= 4800 & sic <= 4899)
  {ff_ind = 7}
  else if (sic >= 4900 & sic <= 4949)
  {ff_ind = 8}
  else if (sic >= 5000 & sic <= 5999 | sic >= 7200 & sic <= 7299 | sic >= 7600 & sic <= 7699)
  {ff_ind = 9}
  else if (sic >= 2830 & sic <= 2839 | sic == 3693 | sic >= 3840 & sic <= 3859 |
           sic >= 8000 & sic <= 8099)
  {ff_ind = 10}
 # skip 11 as that is financial services 
  else {ff_ind = 12}
} 
