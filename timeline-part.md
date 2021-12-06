timeline
================
Sarah

``` r
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.4     ✓ dplyr   1.0.7
    ## ✓ tidyr   1.1.3     ✓ stringr 1.4.0
    ## ✓ readr   2.0.1     ✓ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
library(ggplot2)
```

``` r
# load the data
violation_df = read_csv("data_after_sampling.csv")
```

    ## Rows: 10000 Columns: 19

    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (12): plate, state, license_type, issue_date, violation_time, violation,...
    ## dbl  (7): summons_number, fine_amount, penalty_amount, interest_amount, redu...

    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
violation_df = violation_df %>%
  janitor::clean_names() 
```

``` r
violation_df %>%
  separate(issue_date, into = c("month", "date", "year")) %>%
  mutate(month = month.name[as.numeric(month)]) %>%
  mutate(month = as.factor(month),
         month = fct_relevel(month, "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")) %>%
  relocate(year, month, date) %>%
  group_by(year, month) %>%
  summarize(n_obs = n()) %>%
  ggplot(aes(x = month, y = n_obs, group = 1)) + 
  geom_point() + geom_line() + 
  theme(axis.text.x = element_text(angle = 60, hjust = 1) ) +
  labs(title = "The observation of parking violations \n of each month in 2021")
```

    ## Warning: Unknown levels in `f`: December

    ## `summarise()` has grouped output by 'year'. You can override using the `.groups` argument.

![](timeline-part_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
plot_timeline_day = 
  violation_df %>%
  separate(violation_time, c("hour", "min"), ":") %>%
  mutate(hour = ifelse(substr(min, 3, 3) == "P", as.numeric(hour) + 12, hour)) %>%
  mutate(hour = as.numeric(hour)) %>%
  group_by(hour) %>%
  summarize(count = n()) %>%
  filter(hour <= 24)

plot_timeline_day %>%
  ggplot(aes(x = hour, y = count)) + geom_point() + geom_line() +
  labs(title = "The total number of violations during 24 hours \n of a day in 2021")
```

![](timeline-part_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
## another way I tried for day time
violation_df %>%
  separate(violation_time, c("hour", "min"), ":") %>%
  mutate(hour = ifelse(substr(min, 3, 3) == "P", as.numeric(hour) + 12, hour)) %>%
  mutate(hour = as.character(hour),
         min = substr(min, 1, 2)) %>%
  mutate(time = paste(hour, min, sep = ":")) %>%
  mutate(time_2 = as.POSIXct(time, format = "%H:%M")) %>%
  ggplot(aes(x = time_2)) + geom_histogram() + xlab("Time") + ylab("Count") 
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

    ## Warning: Removed 816 rows containing non-finite values (stat_bin).

![](timeline-part_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->
