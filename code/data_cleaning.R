
### 
# Data cleaning
# Call by using source("code/data_cleaning.R") 
###

library(jsonlite)
library(progress)
library(tidyverse)
library(lubridate)

violation1 <-
  read_csv("./Open_Parking_and_Camera_Violations.csv") %>% 
  janitor::clean_names() %>%
  rename(borough = county) %>%  # rename county to borough
  mutate(
    borough = case_when(
      borough %in% c("BK","K", "Kings") ~ "Brooklyn",
      borough %in% c("BX", "Bronx") ~ "Bronx",
      borough %in% c("Q", "QN", "Qns") ~ "Queens",
      borough %in% c("ST", "R", "Rich", "RICH") ~ "Staten Island",
      borough %in% c("NY", "MN") ~ "Manhattan"),
      issue_date = as.Date(issue_date, format = "%m/%d/%Y"),
      weekday = weekdays(issue_date),
      year = year(issue_date),
      month = month(issue_date),
      day = day(issue_date)
  )  %>%  # make the borough the same 
  filter(borough != "A", 
         weekday != "NA",
         month != "11",
         month != "12") %>%
  separate(violation_time, c("hour", "min"), ":") %>%
  mutate(hour = ifelse(substr(min, 3, 3) == "P", as.numeric(hour) + 12, hour)) %>%
  mutate(hour = as.numeric(hour))

violation2 <- 
  read_csv("./Parking_Violations_Issued_-_Fiscal_Year_2022.csv") %>%
  janitor::clean_names() %>%
  rename(borough = violation_county) %>%
  select(house_number,
         street_name,
         intersecting_street,
         summons_number, 
         vehicle_body_type, 
         vehicle_year)



violation <-
  violation1 %>% left_join(violation2, by = "summons_number") %>%
  mutate(
    house_street = ifelse(is.na(street_name), NA, ifelse(is.na(house_number), paste("0", street_name), paste(house_number, street_name))),
    geo_nyc_address = paste(house_street[!is.na(house_street)], 
                            intersecting_street[!is.na(intersecting_street)], 
                            toupper(borough), sep = ","),
    google_address = paste(house_street[!is.na(house_street)], 
                           intersecting_street[!is.na(intersecting_street)], 
                           toupper(borough), 
                           "New York, NY",
                           sep = ",")
  ) %>%
  select(-house_number, -street_name, -intersecting_street)


address_std <- function(ad){
  address <- 
    toupper(ad) %>%
    str_replace(" PKY,", " PARKWAY, ") %>%
    str_replace(" BLVD,", " BOULEVARD, ") %>%
    str_replace(" BL,", "BOULEVARD, ") %>%
    str_replace(" AVE,", " AVENUE, ") %>%
    str_replace(" AV,", "AVENUE, ") %>%
    str_replace(" ST,", " STREET, ") %>%
    str_replace(" PL,", " PLACE, ") %>%
    str_replace(" HWY,", "HIGHWAY, ") %>%
    str_replace(" DR,", "DRIVE, ")
  return(address)
}

violation <- violation  %>% mutate(geo_nyc_address = geo_nyc_address %>% address_std())















