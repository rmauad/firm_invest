a <- db_reg_1989 %>% 
  filter(year == 1989) %>%
  select(GVKEY, sic, ff_indust, d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989)

a <- db_reg %>% 
  filter(year == 1989) %>%
  select(GVKEY, sic, ff_indust, d_med_only_1989, d_terc_only_1989, d_quar_only_1989, d_quin_only_1989, d_dec_only_1989)
