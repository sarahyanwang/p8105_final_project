
### 
# Data Cleaning
# Call by using source("code/data_cleaning.R") 
###

library(tidyverse)
library(lubridate)

##
# basic data cleaning
# 
# - creates new borough variable and maps county codes to borough
# - changes character issue_date to date variable and parses into month, year, date, and weekday
# - removes month = 11 and 12 (not meaningful for this project)
# - brings time (hour and minute) together and converts to 24 hour time
##

violation1 <-
  read_csv("../data/Open_Parking_and_Camera_Violations.csv") %>% 
  janitor::clean_names() %>%
  mutate(
    borough = case_when(
      county %in% c("BK","K", "Kings") ~ "Brooklyn",
      county %in% c("BX", "Bronx") ~ "Bronx",
      county %in% c("Q", "QN", "Qns") ~ "Queens",
      county %in% c("ST", "R", "Rich", "RICH") ~ "Staten Island",
      county %in% c("NY", "MN") ~ "Manhattan"),
      issue_date = as.Date(issue_date, format = "%m/%d/%Y"),
      weekday = weekdays(issue_date),
      year = year(issue_date),
      month = month(issue_date),
      day = day(issue_date)
  )  %>% 
  filter(county != "A", 
         weekday != "NA",
         month != "11",
         month != "12") %>%
  separate(violation_time, c("hour", "min"), ":") %>%
  mutate(hour = ifelse(substr(min, 3, 3) == "P", as.numeric(hour) + 12, hour)) %>%
  mutate(hour = as.numeric(hour))

### 
# geographical data cleaning
#
# - reads in second dataset and joins to first dataset
# - creates house_street address:
#   > if no street name, house_street is set to NA
#   > if street name exists but house number does not, 0 is affixed to street name and output to house_street
#   > if both elements are not NA, house_number affixed to street_name and output to hosue_street
# - creates geo_nyc_address, to be fed into NYCGeoSearch API to return coordinate (sort of slow, free, not super precise):
#   > concatenates the following if not NA: house_street, intersecting_street 
#   > adds uppercase borough and "NEW YORK, NY"
#   > separates text by ","
# - creates google_address, to be fed into Google API to return coordinates (faster, not free, precise):
#  > similar process to geo_nyc_address, but final element in the string is "New York, NY"
###

violation2 <- 
  read_csv("../data/Parking_Violations_Issued_-_Fiscal_Year_2022.csv") %>%
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
    house_street = ifelse(is.na(street_name), NA, 
                          ifelse(is.na(house_number), paste("0", street_name), 
                                 paste(house_number, street_name))),
    geo_nyc_address = paste(house_street[!is.na(house_street)], 
                            intersecting_street[!is.na(intersecting_street)], 
                            paste(toupper(borough), "COUNTY"),
                            "NEW YORK, NY",
                            sep = ","),
    google_address = paste(house_street[!is.na(house_street)], 
                           intersecting_street[!is.na(intersecting_street)], 
                           toupper(borough), 
                           "New York, NY",
                           sep = ",")
  ) %>%
  select(-house_number, -street_name, -intersecting_street)

###
# address_std: function to standardize commonly used address terms
#
# - changes address to uppercase
# - maps the following:
#   > PKY --> PARKWAY
#   > BLVD, BL --> BOULEVARD
#   > AVE, AV --> AVENUE
#   > ST --> STREET
#   > PL --> PLACE
#   > HWY --> HIGHWAY
#   > DR --> DRIVE
###

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

# applying address_std() to geo_nyc_address
violation <- violation  %>% mutate(geo_nyc_address = geo_nyc_address %>% address_std())
