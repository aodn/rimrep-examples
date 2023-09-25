Plotting SELTMP data
================
Denisse Fierro Arcos
2023-09-04

- [Goal of this notebook](#goal-of-this-notebook)
- [Loading libraries](#loading-libraries)
- [Connecting to RIMReP collection and loading SELTMP
  dataset](#connecting-to-rimrep-collection-and-loading-seltmp-dataset)
  - [Checking dataset structure](#checking-dataset-structure)
  - [Loading dataset metadata](#loading-dataset-metadata)
  - [Extracting data about recreational
    activities](#extracting-data-about-recreational-activities)
    - [Plotting data about recreational
      activities](#plotting-data-about-recreational-activities)
  - [Extracting data about waterway
    health](#extracting-data-about-waterway-health)
    - [Plotting data about waterway
      health](#plotting-data-about-waterway-health)
  - [Extracting data about
    governance](#extracting-data-about-governance)
    - [Plotting data about governance](#plotting-data-about-governance)
    - [Word cloud example using favourite waterways for
      recreation](#word-cloud-example-using-favourite-waterways-for-recreation)

# Goal of this notebook

This notebook will show how to access the RIMReP `geoparquet` collection
for the Social and Economic Long-Term Monitoring Program (SELTMP) from
CSIRO, which contains the latest results of this survey (2021). This
dataset collects data on a subset of Great Barrier Reef (GBR) human
dimension indicators relating to social, economic, cultural, and
governance aspects of the GBR, as described within the Reef 2050 Long
Term Sustainability Plan (Reef 2050 Plan). These human dimensions are
considered to play a pivotal role in resilience-based management of the
GBR.

In this example, we will produce three figures:  
1. Bar plot showing the proportion of people surveyed performing
recreational activities per region  
2. Bar plot showing people’s perception of waterway health  
3. Bar plot comparing the trust in science by fishers against their
perception of climate change

# Loading libraries

``` r
library(arrow)
library(tidyverse)
library(magrittr)
library(tm)
library(janitor)
library(wordcloud2)
```

# Connecting to RIMReP collection and loading SELTMP dataset

``` r
#Establishing connection
data_bucket <- s3_bucket("s3://rimrep-data-public/csiro-seltmp-baseline-surveys-jul22/data.parquet")

#Accessing SELTMP dataset
data_df <- open_dataset(data_bucket)

#Checking dimension of dataset
dim(data_df)
```

    ## [1] 2440 1235

## Checking dataset structure

As we can see above, the SELTMP dataset contains 2440 rows and 1235
columns. We can explore the contents of this dataset looking at its
`schema`, which will print the name of all columns available in the
dataset and the type of data they contain. Since there are 1235 columns,
we will just print the first 10 column names.

``` r
head(data_df$schema, n = 10)
```

    ## Schema
    ## REGION: int64
    ## recruit path: int64
    ## q1: int64
    ## q1a: double
    ## q1a-label: string
    ## quotagroup: int64
    ## quotagroup-label: string
    ## q1b: double
    ## q1b-label: string
    ## q2: int64

## Loading dataset metadata

We can see that there is a `REGION` column, which as its name suggests,
it contains a code that identifies the regions within the area surveyed.
However, the other column names are given as codes (e.g., `q1`). We can
get more details about the information contained in each column of this
dataset by looking at its metadata.

``` r
#Establishing connection to metadata file
table_bucket <- s3_bucket("s3://rimrep-data-public-development/csiro-seltmp-baseline-surveys-jul22/reference.parquet")

#Loading table as a tibble
table <- read_parquet(table_bucket)

#Checking first few rows
head(table)
```

    ## # A tibble: 6 × 3
    ##   description                                                     new_name field
    ##   <chr>                                                           <chr>    <chr>
    ## 1 responseid                                                      ID       resp…
    ## 2 REGION (1=WT, 2=TSV, 3=MWI, 4=FIT; 5=GH)                        REGION … REGI…
    ## 3 Recruiting pathway (1 =  ORU panel, 2 = live link) (added by M… Recruit… recr…
    ## 4 Q1 - What is your current residential / home postcode?          q1 - ho… q1   
    ## 5 Q1a - Please select your City / Town (LGA):                     q1a - c… q1a  
    ## 6 Text value for q1a                                              <NA>     q1a-…

## Extracting data about recreational activities

We can now use our metadata table to find the variables of interest.

``` r
#Searching for matches
rec <- table %>% 
  filter(str_detect(str_to_lower(new_name), "waterway rec"))

#Checking results
rec
```

    ## # A tibble: 65 × 3
    ##    description                                                    new_name field
    ##    <chr>                                                          <chr>    <chr>
    ##  1 W9_1 - Fishing                                                 w9_1 - … w9_1 
    ##  2 W9_2 - Boating or sailing                                      w9_2 - … w9_2 
    ##  3 W9_3 - Snorkelling/freediving/Scuba diving                     w9_3 - … w9_3 
    ##  4 W9_4 - Motor-powered water sports (e.g. water skiing, jet ski) w9_4 - … w9_4 
    ##  5 W9_5 - Wind-powered water sports (e.g. kite surfing)           w9_5 - … w9_5 
    ##  6 W9_6 - Paddling/canoeing/kayaking                              w9_6 - … w9_6 
    ##  7 W9_7 - Camping                                                 w9_7 - … w9_7 
    ##  8 W9_8 - Swimming                                                w9_8 - … w9_8 
    ##  9 W9_9 - Picnics and barbeques                                   w9_9 - … w9_9 
    ## 10 W9_10 - Exercising/hiking/biking/running                       w9_10 -… w9_10
    ## # ℹ 55 more rows

From the table above, we can see that question `9` contains data about
recreational activities. We can also see that there are multiple options
for recreational activities under the same question. We will create a
new column that will identify the activity, so we can plot it.

We will also keep the region column (`quotagroup-label`) because this
contains the regions where respondents were located and we want to
create a bar plot that shows the differences in responses across
regions.

``` r
rec <- rec %>% 
  #Creating a new column for each activity
  separate(description, c("q_number", "activity"), sep = " - ") %>% 
  #Extracting region from new_name column (upper case letters between - and ONLY)
  mutate(region = str_extract(new_name, "- (.+) ONLY -", group = 1)) %>% 
  #We will only keep columns that are useful for us
  select(activity, field, region)

#Checking results
rec
```

    ## # A tibble: 65 × 3
    ##    activity                                                field region     
    ##    <chr>                                                   <chr> <chr>      
    ##  1 Fishing                                                 w9_1  WET TROPICS
    ##  2 Boating or sailing                                      w9_2  WET TROPICS
    ##  3 Snorkelling/freediving/Scuba diving                     w9_3  WET TROPICS
    ##  4 Motor-powered water sports (e.g. water skiing, jet ski) w9_4  WET TROPICS
    ##  5 Wind-powered water sports (e.g. kite surfing)           w9_5  WET TROPICS
    ##  6 Paddling/canoeing/kayaking                              w9_6  WET TROPICS
    ##  7 Camping                                                 w9_7  WET TROPICS
    ##  8 Swimming                                                w9_8  WET TROPICS
    ##  9 Picnics and barbeques                                   w9_9  WET TROPICS
    ## 10 Exercising/hiking/biking/running                        w9_10 WET TROPICS
    ## # ℹ 55 more rows

Now we have the necessary information to extract the questions from the
complete SELTMP dataset that tell us about recreational activities in
the study area. We will also need to do some data wrangling to format
our data in a way that is easy to plot.

``` r
#Extracting recreational activities questions
recreation <- data_df %>% 
  #Selecting columns of interest - We use the field column in the above data frame
  select(all_of(rec$field)) %>% 
  #Removing columns ending in  "_OTHER" as this provides a description of what other activities were carried out
  select(!ends_with("_OTHER")) %>% 
  #Loading data into memory for further processing
  collect()

#We need to do some additional clean up before plotting
recreation <- recreation %>% 
  #We will make the data frame longer. This means that instead of having multiple columns for each region/activity, 
  #we will have single column containing information about the activities/region linked to that observation
  pivot_longer(cols = everything(), names_to = "field", values_to = "rec_act") %>%
  #We remove any rows with no data in the occupation column (i.e., a single respondent cannot be in multiple regions)
  drop_na(rec_act) %>% 
  #Join with metadata table
  left_join(rec, by = "field") %>% 
  #Summarise data by region and activity
  group_by(region, activity) %>% 
  #Calculate number of respondents per region - This is a simple count of observations per region
  mutate(respondent = n(),
         #Removing additional information in the "Other" category for activities
         activity = case_when(str_detect(activity, "please") ~ "Other",
                              T ~ activity),
         #Change from upper case in region to only first letter as uppercase
         region = case_when(region != "MWI" ~ str_to_title(region),
                            T ~ region)) %>% 
  #Correcting spelling mistake in one of the regions
  mutate(region = case_when(region == "Glastone" ~ "Gladstone",
                            T ~ region)) %>% 
  #Calculate percentage of respondents performing an activity
  #We add the number of people who reported that they performed an activity
  summarise(rec_act = sum(rec_act, na.rm = T),
            #We get the total respondents per region (Otherwise this column would be lost)
            respondent = mean(respondent, na.rm = T),
            #We calculate the percentage - No decimals needed
            per_rec = round((rec_act/respondent)*100, 0)) %>% 
  #Calculate mean % by activity to order data in plot
  group_by(activity) %>% 
  mutate(order_plot = mean(per_rec))
```

    ## `summarise()` has grouped output by 'region'. You can override using the
    ## `.groups` argument.

``` r
#Checking result
head(recreation)
```

    ## # A tibble: 6 × 6
    ## # Groups:   activity [6]
    ##   region  activity                         rec_act respondent per_rec order_plot
    ##   <chr>   <chr>                              <dbl>      <dbl>   <dbl>      <dbl>
    ## 1 Fitzroy Boating or sailing                   136        453      30       31.8
    ## 2 Fitzroy Camping                              147        453      32       32.8
    ## 3 Fitzroy Exercising/hiking/biking/running     188        453      42       49  
    ## 4 Fitzroy Fishing                              225        453      50       50.2
    ## 5 Fitzroy Motor-powered water sports (e.g…      45        453      10        8.4
    ## 6 Fitzroy Other                                 39        453       9        7.2

### Plotting data about recreational activities

Our data is now ready for us to make a plot. We will order our plot by
the mean percentage of people reporting performing an activity. Higher
proportions will be at the bottom and decrease towards the top.

``` r
#Creating plot and assign it to a variable
rec_plot <- recreation %>% 
  #We use activity on y axis and ordering by order_plot in descending order
  ggplot(aes(y = reorder(activity, -order_plot), x = per_rec, fill = activity))+
  #Plot as bars and add a black border
  geom_bar(stat = "identity", color = "black")+
  #Divide plot by regions
  facet_grid(~region)+
  #Add % values as text at the end of the bars
  geom_text(aes(label = per_rec), size = 3, hjust = -0.2, vjust = 0.3)+
  #Change color palette
  scale_fill_brewer(type = "qual", palette = "Paired")+
  #Change x axis limits
  lims(x = c(0, 90))+
  #Change base theme for plot
  theme_bw()+
  #Adding labels, title and caption
  labs(x = "% respondents", title = "Waterway recreation activities performed \nby respondents", 
       caption = "*Numbers next to bars show the % of respondents for each activity")+
  #Formatting figure 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.title.y = element_blank(),
        legend.position = "none",
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(linetype = "dashed"),
        plot.title = element_text(hjust = 0.5), 
        plot.caption = element_text(hjust = 0))

#Checking result
rec_plot
```

![](Plotting_SELTMP_Data_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

The above figure can be saved locally with the following line:
`ggsave("recreation_activities_plot.png", rec_plot, device = "png")`.

## Extracting data about waterway health

Using the metadata table we loaded towards the beginning of this
notebook, we will find the survey questions that cover perceived
waterway health.

``` r
#Searching for matches
health <- table %>%
  filter(str_detect(str_to_lower(new_name), "perceived health"))

#Checking results
health
```

    ## # A tibble: 53 × 3
    ##    description                                             new_name        field
    ##    <chr>                                                   <chr>           <chr>
    ##  1 W13_1 - Freshwater creeks and rivers                    w13_1 - WET TR… w13_1
    ##  2 W13_2 - Freshwater lakes, dams and wetlands             w13_2 - WET TR… w13_2
    ##  3 W13_3 - Estuaries (including mangroves and saltmarshes) w13_3 - WET TR… w13_3
    ##  4 W13_4 - Beaches and the coast                           w13_4 - WET TR… w13_4
    ##  5 W13_5 - Seagrass                                        w13_5 - WET TR… w13_5
    ##  6 W13_6 - Inshore coral reefs                             w13_6 - WET TR… w13_6
    ##  7 W13_7 - Offshore coral reefs                            w13_7 - WET TR… w13_7
    ##  8 W13_8 - Ocean and sea                                   w13_8 - WET TR… w13_8
    ##  9 T13_1 - Freshwater creeks and rivers                    t13_1 - TOWNSV… t13_1
    ## 10 T13_2 - Freshwater lakes, dams and wetlands             t13_2 - TOWNSV… t13_2
    ## # ℹ 43 more rows

The first thing we notice is that for some regions there are more
questions about perceived health, which refer to areas that are not
present across all regions. Since we would like to compare results
across regions, we will select areas that are present across all
regions. These are covered by questions `13_1` to `13_8`. We will select
these from our table of questions above and then use it to load the data
we need to create a plot.

We should highlight three issues with the data:  
1. The Fitzroy region does not include information about wetlands
(`13_2`) and offshore reefs (`13_7`).  
2. The area categories and ID for the Gladstone region do not match all
categories and ID for other regions.  
3. There is no variable dictionary included for the Gladstone region

Since we do not have information to interpret the Gladstone region (and
to maintain things simple), we will ignore this region when creating our
plot.

Finally, we will add the `-label` suffix to the `field` column because
we would like to access the actual labels of the responses instead of
the numerical categories.

``` r
health <- health %>% 
  #Selecting questions 13_1 to 13_8
  filter(str_detect(field, ".*_[1-8]{1}$")) %>% 
  #Creating a new column for each activity
  separate(description, c("q_number", "area"), sep = " - ") %>% 
  #Extracting region from new_name column
  mutate(region = str_extract(new_name, "- (.+) Perceived", group = 1)) %>% 
  #Removing Gladstone region
  filter(region != "GLADSTONE") %>% 
  #Adding -label suffix to field column
  mutate(field = str_c(field, "-label")) %>%
  #We will only keep columns that are useful for us
  select(area, field, region)

#Checking results
health
```

    ## # A tibble: 30 × 3
    ##    area                                            field       region     
    ##    <chr>                                           <chr>       <chr>      
    ##  1 Freshwater creeks and rivers                    w13_1-label WET TROPICS
    ##  2 Freshwater lakes, dams and wetlands             w13_2-label WET TROPICS
    ##  3 Estuaries (including mangroves and saltmarshes) w13_3-label WET TROPICS
    ##  4 Beaches and the coast                           w13_4-label WET TROPICS
    ##  5 Seagrass                                        w13_5-label WET TROPICS
    ##  6 Inshore coral reefs                             w13_6-label WET TROPICS
    ##  7 Offshore coral reefs                            w13_7-label WET TROPICS
    ##  8 Ocean and sea                                   w13_8-label WET TROPICS
    ##  9 Freshwater creeks and rivers                    t13_1-label TOWNSVILLE 
    ## 10 Freshwater lakes, dams and wetlands             t13_2-label TOWNSVILLE 
    ## # ℹ 20 more rows

As we did with the previous plot, we will use the table above to extract
the questions that contain data about perceptions of waterway health. In
this case, we will also need to do some data wrangling to format our
data in a way that is easy to plot.

``` r
#Extracting waterway health perception questions
water_health <- data_df %>%
  #Selecting columns of interest - We use the field column in the above data frame
  select(all_of(health$field), "w13_1") %>% 
  #Loading data into memory for further processing
  collect()

#We will select data for the w13_1 columns to order ratings
labels_water <- water_health %>% 
  select(starts_with("w13_1")) %>% 
  #Removing NA rows
  drop_na() %>% 
  #Keeping unique values
  distinct() %>% 
  #Arranging by numeric value
  arrange(w13_1) %>% 
  #Cleaning up column names
  clean_names()

#We need to do some additional clean up before plotting
water_health_reg <- water_health %>% 
  select(!w13_1) %>% 
  #We will make the data frame longer. This means that instead of having multiple columns for each region/area, 
  #we will have single column containing information about the region/area linked to that observation
  pivot_longer(cols = everything(), names_to = "field", values_to = "rating") %>%
  #We remove any rows with no data in the rating column (i.e., a single respondent cannot be in multiple regions)
  drop_na(rating) %>% 
  #Join with metadata table
  left_join(health, by = "field") %>% 
  #Summarise data by region and area
  group_by(region, area) %>% 
  #Calculate number of respondents per region - This is a simple count of observations per region
  mutate(respondent = n(),
         #Change from upper case in region to only first letter as uppercase
         region = case_when(region != "MWI" ~ str_to_title(region),
                            T ~ region)) %>% 
  #Calculate percentage by rating, so we add rating to the grouping
  group_by(region, area, rating) %>%
  #We count the amount of responses under each rating
  mutate(rate_count = n(),
         rate_per = round((rate_count/respondent)*100, 0)) %>% 
  #Keep unique values only
  distinct() %>% 
  #Change rating column to ordered factor
  mutate(rating = factor(rating, levels = labels_water$w13_1_label, ordered = T)) %>%
  #Convert Not applicable level to NA 
  mutate(rating = fct_recode(rating, NULL = "Not applicable (have not visited)"))

#Checking result
head(water_health)
```

    ## # A tibble: 6 × 31
    ##   `w13_1-label`          `w13_2-label` `w13_3-label` `w13_4-label` `w13_5-label`
    ##   <chr>                  <chr>         <chr>         <chr>         <chr>        
    ## 1 In good health         In good heal… In good heal… In good heal… In good heal…
    ## 2 <NA>                   <NA>          <NA>          <NA>          <NA>         
    ## 3 <NA>                   <NA>          <NA>          <NA>          <NA>         
    ## 4 In fair health         In fair heal… In fair heal… In good heal… I don't know 
    ## 5 Not applicable (have … Not applicab… Not applicab… In fair heal… I don't know 
    ## 6 In good health         In good heal… In good heal… Not applicab… In good heal…
    ## # ℹ 26 more variables: `w13_6-label` <chr>, `w13_7-label` <chr>,
    ## #   `w13_8-label` <chr>, `t13_1-label` <chr>, `t13_2-label` <chr>,
    ## #   `t13_3-label` <chr>, `t13_4-label` <chr>, `t13_5-label` <chr>,
    ## #   `t13_6-label` <chr>, `t13_7-label` <chr>, `t13_8-label` <chr>,
    ## #   `m13_1-label` <chr>, `m13_2-label` <chr>, `m13_3-label` <chr>,
    ## #   `m13_4-label` <chr>, `m13_5-label` <chr>, `m13_6-label` <chr>,
    ## #   `m13_7-label` <chr>, `m13_8-label` <chr>, `f13_1-label` <chr>, …

### Plotting data about waterway health

We will show results for a single region as it is difficult to show all
regions in a single plot. For this example, we will show the Wet
Tropics.

``` r
#Creating plot and assign it to a variable
water_health_reg %>% 
  filter(region == "Wet Tropics") %>% 
  #We use activity on y axis and ordering by order_plot in descending order
  ggplot(aes(y = area, x = rate_per, fill = rating))+
  #Plot as bars and add a black border
  geom_bar(stat = "identity", color = "black", position = "fill")+
  scale_x_continuous(labels = scales::percent)+
  #Add % values as text at the end of the bars
  geom_text(aes(label = rate_per, fontface = 2), size = 3, position = "fill", hjust = 1.1)+
  #Change color palette
  scale_fill_brewer(type = "qual", palette = "Paired")+
  #Change base theme for plot
  theme_bw()+
  #Adding labels, title and caption
  labs(x = "% respondents", title = "Rating of perceived waterway health \nby habitat in the Wet Tropics region",
       caption = "*Numbers inside bars show the % of respondents per rating")+
  #Formatting figure 
  theme(axis.title = element_blank(),
        legend.position = "top", legend.margin = margin(l = -2, unit = "cm"),
        legend.title = element_blank(),
        panel.grid = element_blank(),
        plot.title = element_text(hjust = 0.5), 
        plot.caption = element_text(hjust = 0))
```

![](Plotting_SELTMP_Data_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

## Extracting data about governance

Finally, we will replicate one of the plots about governance of
waterways that is available in the SELTMP website, which we are
including below. By now, you know that the first step is to look for the
variables that contain the information we want to plot.

Since the plot does not include a keyword that is common for all
variables, we will search for `science` since the first variable in the
plot is about “trust in science about waterways”.

![Original plot from SELTMP to be replicated
here](../images/sample_plot.jpeg).

``` r
#Searching for matches - We will use "science" as a keyword
table %>%
  filter(str_detect(str_to_lower(description), "science"))
```

    ## # A tibble: 10 × 3
    ##    description                                                    new_name field
    ##    <chr>                                                          <chr>    <chr>
    ##  1 W18_12 - I trust the science about waterway health and manage… w18_12 … w18_…
    ##  2 W21_5 - Science and Education                                  w21_5 -… w21_5
    ##  3 T18_12 - I trust the science about waterway health and manage… t18_12 … t18_…
    ##  4 T21_5 - Science and Education                                  t21_5 -… t21_5
    ##  5 M18_12 - I trust the science about waterway health and manage… m18_12 … m18_…
    ##  6 M21_5 - Science and Education                                  m21_5 -… m21_5
    ##  7 F18_12 - I trust the science about waterway health and manage… f18_12 … f18_…
    ##  8 F21_5 - Science and Education                                  f21_5 -… f21_5
    ##  9 F18. Please rate your level of agreement with the following s… F18_12 … F18_…
    ## 10 F21. Which broad sector of waterway-dependent business or emp… F21_9 -… F21_9

We can see that trust in science falls under question `18`. We will do
another query to our table and check that all variables needed for the
plot are included in question `18`. We will use additional keywords
identifying the questions that are relevant for our plot.

``` r
#Keywords representing questions of interest
keys <- paste("science", "institutions", "management", "access", "fair", "influence", sep = "|",collapse = "|")

govern <- table %>%
  #Searching for matches - We will use "18_" as a keyword
  filter(str_detect(field, "18_")) %>% 
  #Second filter with keywords
  filter(str_detect(description, keys))

#Checking results
govern
```

    ## # A tibble: 30 × 3
    ##    description                                                    new_name field
    ##    <chr>                                                          <chr>    <chr>
    ##  1 W18_7 - I think that decisions about managing local waterways… w18_7 -… w18_7
    ##  2 W18_8 - I do not have fair access to all the waterways in my … w18_8 -… w18_8
    ##  3 W18_9 - I feel I personally have some influence over how loca… w18_9 -… w18_9
    ##  4 W18_10 - I feel able to have input into the management of wat… w18_10 … w18_…
    ##  5 W18_11 - I trust the information I receive from institutions … w18_11 … w18_…
    ##  6 W18_12 - I trust the science about waterway health and manage… w18_12 … w18_…
    ##  7 T18_7 - I think that decisions about managing local waterways… t18_7 -… t18_7
    ##  8 T18_8 - I do not have fair access to all the waterways in my … t18_8 -… t18_8
    ##  9 T18_9 - I feel I personally have some influence over how loca… t18_9 -… t18_9
    ## 10 T18_10 - I feel able to have input into the management of wat… t18_10 … t18_…
    ## # ℹ 20 more rows

We have identified the fields containing the information we need to
recreate the plot. We now need to tidy up our table as we have done
previously.

``` r
govern <- govern %>%
  #Extracting region and label from new_name column 
  separate(new_name, c("q_number", "region", "question"), sep = " - ") %>% 
  #Extracting region from new_name column - Remove apostrophes (')
  mutate(question = str_replace(question, "\\'", ""),
         #Get only words in upper case
         question = str_extract(question, " (?:[A-Z ]+[A-Z]+)")) %>% 
  #We will only keep columns that are useful for us
  select(question, field, region)

#Checking results
govern
```

    ## # A tibble: 30 × 3
    ##    question                        field  region     
    ##    <chr>                           <chr>  <chr>      
    ##  1 " DECISIONS ARE MADE FAIRLY"    w18_7  WET TROPICS
    ##  2 " DONT HAVE FAIR ACCESS"        w18_8  WET TROPICS
    ##  3 " SOME PERSONAL INFLUENCE"      w18_9  WET TROPICS
    ##  4 " ABLE TO HAVE INPUT"           w18_10 WET TROPICS
    ##  5 " TRUST INFO FROM INSTITUTIONS" w18_11 WET TROPICS
    ##  6 " TRUST THE SCIENCE"            w18_12 WET TROPICS
    ##  7 " DECISIONS ARE MADE FAIRLY"    t18_7  TOWNSVILLE 
    ##  8 " DONT HAVE FAIR ACCESS"        t18_8  TOWNSVILLE 
    ##  9 " SOME PERSONAL INFLUENCE"      t18_9  TOWNSVILLE 
    ## 10 " ABLE TO HAVE INPUT"           t18_10 TOWNSVILLE 
    ## # ℹ 20 more rows

Note that unlike the previous example, we will not use the `-label`
columns because we are interested in the quantifying the level of
agreement of the respondents to the statements in the survey.

We will now use the table above to load the questions about governance
to our session. As in the previous examples, we will need to do some
data wrangling to format our data in a way that is easy to plot.

``` r
#Extracting waterway health perception questions
governance <- data_df %>%
  #Selecting columns of interest - We use the field column in the above data frame
  select(all_of(govern$field)) %>% 
  #Loading data into memory for further processing
  collect()

#We need to do some additional clean up before plotting
governance <- governance %>%
  #We will make the data frame longer as we did in the previous examples
  pivot_longer(cols = everything(), names_to = "field", values_to = "agreement") %>%
  #We remove any rows with no data in the occupation column (i.e., a single respondent cannot be in multiple regions)
  drop_na(agreement) %>% 
  #Join with metadata table
  left_join(govern, by = "field") %>% 
  #Summarise data by region and activity
  group_by(region, question) %>% 
  #Calculate number of respondents per region - This is a simple count of observations per region
  mutate(respondent = n(),
         #Change from upper case in region to only first letter as uppercase
         region = case_when(region != "MWI" ~ str_to_title(region),
                            T ~ region)) %>% 
  #Calculate mean agreement and standard error
  summarise(agree_mean = round(mean(agreement, na.rm = T), 2),
            agree_sd = sd(agreement, na.rm = T),
            #We get the total respondents per region (Otherwise this column would be lost)
            respondent = mean(respondent, na.rm = T),
            #We calculate the percentage - No decimals needed
            agree_se = (agree_sd/sqrt(respondent))) %>% 
  #Calculate mean % by activity to order data in plot
  group_by(question) %>% 
  mutate(order_plot = mean(agree_mean))
```

    ## `summarise()` has grouped output by 'region'. You can override using the
    ## `.groups` argument.

``` r
#Checking results
governance
```

    ## # A tibble: 30 × 7
    ## # Groups:   question [6]
    ##    region    question         agree_mean agree_sd respondent agree_se order_plot
    ##    <chr>     <chr>                 <dbl>    <dbl>      <dbl>    <dbl>      <dbl>
    ##  1 Fitzroy   " ABLE TO HAVE …       4.98     2.36        467   0.109        5.00
    ##  2 Fitzroy   " DECISIONS ARE…       5.55     2.16        467   0.0999       5.52
    ##  3 Fitzroy   " DONT HAVE FAI…       4.35     2.48        467   0.115        4.41
    ##  4 Fitzroy   " SOME PERSONAL…       4.29     2.34        467   0.108        4.27
    ##  5 Fitzroy   " TRUST INFO FR…       5.94     2.30        467   0.107        6.02
    ##  6 Fitzroy   " TRUST THE SCI…       6.65     2.45        467   0.113        6.8 
    ##  7 Gladstone " ABLE TO HAVE …       5.53     2.29        563   0.0967       5.00
    ##  8 Gladstone " DECISIONS ARE…       6.09     2.05        563   0.0863       5.52
    ##  9 Gladstone " DONT HAVE FAI…       4.02     2.39        563   0.101        4.41
    ## 10 Gladstone " SOME PERSONAL…       4.59     2.24        563   0.0945       4.27
    ## # ℹ 20 more rows

### Plotting data about governance

Our data is now ready for us to make a plot. We will order our plot by
the mean agreement. Higher agreement will be on the left and decrease to
the right.

``` r
#Creating plot and assign it to a variable
governance %>% 
  #We use activity on y axis and ordering by order_plot in descending order
  ggplot(aes(y = reorder(question, -order_plot), x = agree_mean, fill = region))+
  #Plot as bars and add a black border
  geom_bar(stat = "identity", color = "black")+
  geom_errorbar(aes(xmin = agree_mean, xmax = agree_mean+agree_se), width = 0.5)+
  #Divide plot by regions
  facet_grid(~region)+
  #Add % values as text at the end of the bars
  geom_text(aes(label = agree_mean), size = 3, hjust = 1.2)+
  #Change color palette
  scale_fill_brewer(type = "qual", palette = "Paired")+
  #Change x axis limits
  lims(x = c(0, 8))+
  #Change base theme for plot
  theme_bw()+
  #Adding labels, title and caption
  labs(x = "Mean agreeement", title = "Perceived fairness and trust by respondents \nin waterway governance", 
       caption = "*Numbers inside bars show the mean agreeement with each statement. Standard errors\n shown as black lines.")+
  #Formatting figure 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.title = element_blank(),
        legend.position = "none",
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_line(linetype = "dashed"),
        plot.title = element_text(hjust = 0.5), 
        plot.caption = element_text(hjust = 0))
```

![](Plotting_SELTMP_Data_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

### Word cloud example using favourite waterways for recreation

We will search for the relevant questions in our table of variables, and
prepare query results to extract data from SELTMP dataset.

``` r
#Searching for matches
water <- table %>%
  filter(str_detect(str_to_lower(new_name), "favourite.*waterway")) %>%
  separate(new_name, c("q_number", "region"), sep = " - ") %>%
  #Extracting region from new_name column
  mutate(region = str_remove(region, " ONLY")) %>%
  #We will only keep columns that are useful for us
  select(field, region)
```

    ## Warning: Expected 2 pieces. Additional pieces discarded in 4 rows [1, 2, 3, 4].

``` r
#Checking results
water
```

    ## # A tibble: 4 × 2
    ##   field region     
    ##   <chr> <chr>      
    ## 1 w10   WET TROPICS
    ## 2 t10   TOWNSVILLE 
    ## 3 m10   MWI        
    ## 4 f10   FITZROY

In this case, we will show global results, so we will ignore regions.
However, by changing the grouping of the data, we can create word clouds
for each region.

``` r
#Extracting waterway health perception questions
fav_water <- data_df %>%
  #Selecting columns of interest - We use the field column in the above data frame
  select(all_of(water$field)) %>% 
  #Loading data into memory for further processing
  collect()

#We need to do some additional clean up before plotting
#Defining answers that are not informative
not_accepted <- "do not|can[:punct:]|variety|havent|^na$|don[:punct:]|dont|none|not |no |wildlife|nil|idk|lovely|know|\\?|car|fishing|all|any|;|boat|impossible|chair|unsure|secret|swimming"

#Cleaning data
fav_water <- fav_water %>%
  #We will make the data frame longer as we did in the previous examples
  pivot_longer(cols = everything(), names_to = "field", values_to = "waterways") %>%
  #Forcing everything to be lower case
  mutate(waterways = str_to_lower(waterways)) %>% 
  #Remove non-informative answers
  filter(!str_detect(waterways, not_accepted)) %>% 
  #Change all special characters to ; to separate things easier
  mutate(waterways = str_to_lower(str_replace_all(waterways, "[:punct:]| and | or |the |  ", ";"))) %>%
  #Separate responses by semicolon (;)
  separate_longer_delim(waterways, delim = ";") %>% 
  #Removing stop words
  mutate(waterways = removeWords(waterways, stopwords("english"))) %>% 
  #Remove blank spaces
  mutate(waterways = str_trim(str_to_lower(waterways), "both")) %>% 
  #Remove empty cells
  filter(waterways != "" & waterways != "s") %>% 
  #Correcting multiple cases of great barrier reef
  mutate(waterways = case_when(str_detect(waterways, "gbr") ~ "great barrier reef",
                               str_detect(waterways, "barrier reef") ~ "great barrier reef",
                               T ~ waterways)) %>%
  #Correcting multiple cases of beach
  mutate(waterways = case_when(waterways == "beaches" ~ "beach",
                               T ~ waterways)) %>%
  #Correcting multiple cases of creek
  mutate(waterways = case_when(waterways == "creeks" ~ "creek",
                               T ~ waterways)) %>%
  #Correcting multiple cases of Whitsunday Islands
  mutate(waterways = case_when(str_detect(waterways, "whitsunday") ~ "whitsunday islands",
                               T ~ waterways)) %>%
  count(waterways) %>% 
  arrange(desc(n))

#Checking results
fav_water
```

    ## # A tibble: 957 × 2
    ##    waterways              n
    ##    <chr>              <int>
    ##  1 ross river            93
    ##  2 fitzroy river         83
    ##  3 strand                81
    ##  4 crystal creek         45
    ##  5 beach                 43
    ##  6 great barrier reef    28
    ##  7 magnetic island       28
    ##  8 pioneer river         27
    ##  9 stoney creek          24
    ## 10 causeway lake         22
    ## # ℹ 947 more rows

More work needs to be done in cleaning this dataset. However, since
there are over 1,000 rows with responses, it is beyond the scope of this
notebook to complete harmonise the answers in the dataset. For now, we
will move on to plotting these results.

Note that you will need to run this notebook in your local machine to
see the results of the word cloud.

``` r
wordcloud2(fav_water)
```
