
### 
# Data cleaning
# Call by using source("code/data_cleaning.R") 
###

library(tidyverse)
library(httr)
library(lubridate)
library(plotly)

violation1 <-
  read_csv("data/Open_Parking_and_Camera_Violations.csv") %>% 
  janitor::clean_names() %>%
  rename(borough = county) %>%  # rename county to borough
  mutate(
    borough = case_when(
      borough %in% c("BK","K", "Kings") ~ "Brooklyn",
      borough %in% c("BX", "Bronx") ~ "Bronx",
      borough %in% c("Q", "QN", "Qns") ~ "Queens",
      borough %in% c("ST", "R", "Rich", "RICH") ~ "Staten Island",
      borough %in% c("NY", "MN") ~ "Manhattan"),
      issue_date = as.Date(issue_date, format = "%m/%d/%y"),
      weekday = weekdays(issue_date),
      year = year(issue_date),
      month = month(issue_date),
      day = day(issue_date)
  )  %>%  # make the borough the same 
  filter(borough != "A", 
         weekday != "NA") 

violation2 <- 
  read_csv("data/Parking_Violations_Issued_-_Fiscal_Year_2022.csv") %>%
  janitor::clean_names() %>%
  rename(borough = violation_county) %>%
  mutate(
    address = paste(house_number, street_name, ", NY")
  )  %>% 
  select(address, summons_number)

violation <-
  violation1 %>% left_join(violation2, by = "summons_number")
