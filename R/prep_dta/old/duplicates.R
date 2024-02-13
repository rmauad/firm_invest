test2 <- test %>% group_by(GVKEY, year) %>%
  summarise(nobs = n())

test3 <- test2 %>% filter(nobs >=2)

test3 <-  db_reg %>% filter(GVKEY == 1094 & year == 1991)

test <- data_new %>% group_by(GVKEY) %>%
  summarise(nobs = n())

test2 <- test %>% filter(nobs <= 2)

db_reg <- db_reg %>% group_by(GVKEY, year) %>% filter(row_number()==1)
  
  m1 <-
  test %>% 
  group_by(id) %>% 
  filter(row_number()==1)