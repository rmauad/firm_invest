ff_5ind <- function(sic) {
if (sic >= 100 & sic <= 999 | sic >= 2000 & sic <= 2399 |
    sic >= 2700 & sic <= 2749 | sic >= 2770 & sic <= 2799 |
    sic >= 3100 & sic <= 3199 |
    sic >= 3940 & sic <= 3989 | sic >= 2500 & sic <= 2519 | 
    sic >= 2590 & sic <= 2599 |
    sic >= 3630 & sic <= 3659 | sic >= 3710 & sic <= 3711 |
    sic == 3714 | sic == 3716 | sic >= 3750 & sic <= 3751 |
    sic == 3792 | sic >= 3900 & sic <= 3939 | sic >= 3990 & sic <= 3999 |
    sic >= 5000 & sic <= 5999 | sic >= 7200 & sic <= 7299 |
    sic >= 7600 & sic <= 7699) 
  {ff_5ind = 1} #consumer goods
  else if (sic >= 2520 & sic <= 2589 | sic >= 2600 & sic <= 2699 | sic >= 2750 & sic <= 2769 |
           sic >= 2800 & sic <= 2829 | sic >= 2840 & sic <= 2899 |
           sic >= 3000 & sic <= 3099 | sic >= 3200 & sic <= 3569 | sic >= 3580 & sic <= 3629 |
           sic >= 3700 & sic <= 3709 | sic >= 3712 & sic <= 3713 | sic == 3715 | sic >= 3717 & sic <= 3749 |
           sic >= 3752 & sic <= 3791 | sic >= 3793 & sic <= 3799 | sic >= 3830 & sic <= 3839 |
           sic >= 3860 & sic <= 3899 | sic >= 1200 & sic <= 1399 | sic >= 2900 & sic <= 2999 |
           sic >= 4900 & sic <= 4949)
  {ff_5ind = 2} #manufacturing
  else if (sic >= 2830 & sic <= 2839 | sic == 3693 | sic >= 3840 & sic <= 3859 |
           sic >= 8000 & sic <= 8099)
  {ff_5ind = 4} #health care
  else {ff_ind = 0}
} 
