Final Report
================
12/6/2021

### Motivation

One of our group members’ had the unfortunate experience of getting her
car towed last year, due to parking near by a fire hydrant in Minnesota.
A news report published by New York Post about locations drivers were
most likely to get a parking ticket in NYC between October 2020 and
September 2021
[-Link](https://nypost.com/2021/11/18/these-are-the-worst-nyc-streets-for-getting-a-parking-ticket/).
We were intrigued by the potential of investigating the parking
violation in NYC in 2021.

### Questions

1.  When and where a parking ticket in NYC is most likely to be found?
2.  
3.  

### Data

#### Data Processing and Cleaning

We used two datasets from NYC OpenData in our project:

-   Open Parking and Camera Violations
    [-Link](https://data.cityofnewyork.us/City-Government/Open-Parking-and-Camera-Violations/nc67-uf89)

The Open Parking and Camera violations contains violations from 2016 to
2021 and have 73.6 millions of rows. Since we only focus on year 2021,
we filter the dataset on the website page to remove redundant
information and download the dataset after filtering. The dataset we
used was too large to store in github. We are interested in parking
violation in five boroughs, Manhattan, Kings, The Bronx, State Island,
and Queens. The original variable `county` renamed as `borough` and
names are aligned. We separated the `issue_date` into `month`, `date`,
and `year` and apply function to find the weekday of the date. We
further broke down the `violation_time` into `hour` and `min` for
plotting the violation over a day.

-   Parking Violations Issued - Fiscal Year 2021
    [-Link](https://data.cityofnewyork.us/City-Government/Parking-Violations-Issued-Fiscal-Year-2021/kvfd-bves)

#### Variable of Interests

The key variables that we used in our analysis include:

#### Data Cleaning

### Exploratory Analysis

### Additional Analysis(Regression Analysis)

### Discussion

### Conclusion
