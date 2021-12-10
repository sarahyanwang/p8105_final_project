
hydrant <- 
  violation %>% 
  filter(violation %in% c("FIRE HYDRANT"), !is.na(google_address)) 

num_groups <- 10

hydrant_split <- 
  hydrant %>% 
  group_by((row_number() - 1) %/% (n()/num_groups)) %>%
  nest %>% 
  pull(data)

hydrant_1 <- hydrant_split[[1]]
hydrant_2 <- hydrant_split[[2]]
hydrant_3 <- hydrant_split[[3]]
hydrant_4 <- hydrant_split[[4]]
hydrant_5 <- hydrant_split[[5]]
hydrant_6 <- hydrant_split[[6]]
hydrant_7 <- hydrant_split[[7]]
hydrant_8 <- hydrant_split[[8]]
hydrant_9 <- hydrant_split[[9]]
hydrant_10 <- hydrant_split[[10]]


hydrant_list <- 
  tibble(
    name = paste0("hydrant_", c(1:10)),
    data = hydrant_split
  )

code_lat_long <-
  function(indf){
    temp_df <- 
      indf %>% 
      geocode(address, method = 'google', lat = latitude , long = longitude, limit = 1)
    return(temp_df)
  }

hydrant_1 <- hydrant_1 %>% code_lat_long

hydrant_lat_long <- 
  bind_rows(hydrant_1, 
            hydrant_2, 
            hydrant_3, 
            hydrant_4, 
            hydrant_5, 
            hydrant_6, 
            hydrant_7, 
            hydrant_8, 
            hydrant_9, 
            hydrant_10)

write_csv(hydrant_1, "hydrant_lat_long_1.csv")

