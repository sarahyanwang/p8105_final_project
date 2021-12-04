
### 
# Data cleaning
# Call by using source("code/data_cleaning.R") 
###

library(tidyverse)
library(httr)
library(lubridate)
library(plotly)

violation = read_csv("data/Open_Parking_and_Camera_Violations.csv") %>% 
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
  filter(borough != "A",                  # get rid of "A"
         weekday != "NA") 
  # %>%   # remove data that cannot turn into weekday
  # separate(temp_issue_date, into = c("year", "month", "day"), sep = "-")  # separate date into year, month, day

