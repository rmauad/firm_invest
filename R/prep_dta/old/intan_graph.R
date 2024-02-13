library(dplyr)
library(ggplot2)

plot_data <- data_intan %>%
  filter(year >= 1975) %>%
  group_by(year) %>%
  mutate(ppent_real = (ppent/cpi)*100,
         agg_org_cap = sum(org_cap_comp, na.rm = TRUE),
         agg_ppent = sum(ppent_real, na.rm = TRUE),
         o_k = agg_org_cap/agg_ppent)

         #o_k_1975 = ifelse(year == 1975, o_k, NA),
         #o_k_1975 = coalesce(o_k_1975, first(o_k_1975)))
o_k_1975 <- plot_data %>% filter(year == 1975)
o_k_1975 <- unique(o_k_1975$o_k)
  
plot_data <- plot_data %>%
  mutate(o_k_1975 = o_k_1975,
    o_k_1975_norm = o_k/o_k_1975)

# CONSUMER DOES NOT MATCH
ggplot(data = plot_data, aes(x = year, y = o_k_1975_norm)) +
  geom_line()


  


