# AIMS temperature data: Creating a map of sites
E. Klein, D. Fierro Arcos

- [Goal](#goal)
- [Loading libraries](#loading-libraries)
- [Connect to S3 parquet directory](#connect-to-s3-parquet-directory)
- [Exploring the dataset](#exploring-the-dataset)
- [Analysing the data](#analysing-the-data)
- [Mapping sites](#mapping-sites)

# Goal

This notebook demonstrates how to interact with the RIMReP DMS
`geoparquet` collection. Here, we will call the AIMS water temperature
logger data to make a map of all sites where loggers have been deployed.

This dataset includes sea temperature data since 1980 for tropical and
subtropical coral reefs around Australia, including sites at the Great
Barrier Reef.

# Loading libraries

``` r
#Accessing S3 bucket
library(arrow)
#Data manipulation
library(dplyr)
#Plotting maps
library(leaflet)
#Measuring time - it checks how long our code takes to run
library(tictoc)
```

# Connect to S3 parquet directory

This chunk will create a S3 bucket access and open a connection. Note
that the `df` object we create below is an arrow object, not an `R` data
frame.

``` r
#Starting total timer and timer for this particular chunk of code
tic("Total time") ## This is the full run timer
tic("S3")

#Establishing connection to S3 bucket
tempBucket <- s3_bucket(bucket = "s3://gbr-dms-data-public/aims-temp-loggers/data.parquet")

#Accessing dataset
df <- open_dataset(tempBucket)

#Stopping chunk timer
toc(log = TRUE)
```

    S3: 32.53 sec elapsed

In case you want to check the type of object the `df` variable is, you
can run the code below.

``` r
class(df)
```

    [1] "FileSystemDataset" "Dataset"           "ArrowObject"      
    [4] "R6"               

As you can see above, `df` is an arrow dataset, not an `R` data frame,
so using the `str` function to check the contents of `df` will not give
us useful information. Given the large size of the dataset, we do not
recommend that you try using the `glimpse` function because it will
likely kill your current `R` session, particularly if your machine does
not have much RAM memory.

# Exploring the dataset

A `(geo)parquet` dataset (represented by `df` in the example) is a
collection of files, but it is transparent to the user. This means you
cannot see the contents of the dataset directly, but you can explore the
structure of the `df` object.

``` r
#Starting chuck timer
tic("Metadata")

#Checking the number of files contained within the dataset
print(paste0("Number of files in the parquet directory: ", length(df$files)))
```

    [1] "Number of files in the parquet directory: 32"

``` r
#Checking dataset structure
print(df$schema)
```

    Schema
    deployment_id: int64
    site: string
    site_id: int64
    subsite: string
    subsite_id: int64
    from_date: timestamp[us]
    thru_date: timestamp[us]
    depth: double
    parameter: string
    instrument_type: string
    serial_num: string
    lat: double
    lon: double
    gbrmpa_reef_id: string
    metadata_uuid: string
    sites_with_climatology_available: int64
    time: timestamp[us, tz=UTC]
    cal_val: double
    qc_val: double
    qc_flag: int64
    geometry: binary
    fid: string

    See $metadata for additional Schema metadata

``` r
#Ending timer
toc(log = TRUE)
```

    Metadata: 0.02 sec elapsed

Above, we can see that this dataset contains 50 files, and there are a
number of columns available. You can refer to the [link to the original
metadata](https://apps.aims.gov.au/metadata/view/4a12a8c0-c573-11dc-b99b-00008a07204e)
provided in the [STAC record for the AIMS temperature
data](https://stac.reefdata.io/browser/collections/aims-temp/items/aims-temp-loggers?.asset=asset-data)
to check for the meaning of each column.

# Analysing the data

We can use standard `dplyr` functions to play with the data. For this
example, we will summarise our data by `site`, count the number of
observations, and average the coordinates and the temperature. Note that
the deployment of the loggers do not occur exactly at the same spot
since the 1980s, but they are deployed nearby. Getting a mean of the
coordinates may not necessarily be useful, but we are doing it here just
for fun. We will also apply a filter based on longitudes to select sites
from the east coast of Australia.

Note that to be able to see the results of our calculation, we need to
use the `collect` function at the end, which will trigger our analyse to
begin and will load the results as a data frame.

``` r
#Starting our chunk timer
tic("Summarise")

#Analysing dataset
dfSites <- df |> 
  #Filtering sites with longitudes more than 140.5
  filter(lon >140.5) |> 
  #Grouping data by site
  group_by(site) |> 
  #Calculating means by site
  summarise(tempMean = round(mean(qc_val, na.rm=TRUE), 2),
            lonMean = round(mean(lon, na.rm=TRUE), 4),
            latMean = round(mean(lat, na.rm=TRUE), 4),
            dateMin = min(time), 
            dateMax = max(time),
            nPoints = n()) |> 
  #Triggering analysis and loading to memory
  collect()

#Ending chunk timer
toc(log = TRUE)
```

    Summarise: 36.09 sec elapsed

Let’s look at the resulting table:

``` r
head(dfSites)
```

    # A tibble: 6 × 7
      site  tempMean lonMean latMean dateMin             dateMax             nPoints
      <chr>    <dbl>   <dbl>   <dbl> <dttm>              <dttm>                <int>
    1 Geof…     25.8    147.   -19.2 1991-11-20 14:00:00 2022-02-06 13:50:00 2675313
    2 Pion…     26.0    146.   -18.6 1992-03-08 14:00:00 2011-07-06 13:53:42  293626
    3 Catt…     26.1    146.   -18.6 1993-02-11 14:00:00 2021-05-13 13:50:00 1880434
    4 Pelo…     26.1    146.   -18.5 1993-08-07 14:00:00 2022-02-07 13:50:00 1434371
    5 Myrm…     26.6    147.   -18.3 1995-04-13 14:00:00 2021-03-27 13:56:00 2022959
    6 Hero…     24.5    152.   -23.4 1995-11-24 14:00:00 2021-06-28 13:59:38 2057311

# Mapping sites

From the summary table we created in the previous step, we will make a
map of all sites where loggers were deployed. We will use the `leaflet`
library to create this map, which will make it interactive. We will
change the size of the markers so that they are proportional to the
number of records at each site (`nPoints` column).

``` r
#Starting chunk timer
tic("Map")

#Setting a scaling factor for map markers
scaleFactor <- 2e-6

#Creating our map based on our summary table
m <- leaflet(dfSites) |> 
  #Adding a basemap - Default is Open Street Map
  addTiles() |> 
  #Add circles for markers
  addCircleMarkers(lat = ~latMean, lng = ~lonMean, 
                   #Radius of marker to change based on number of observations
                   radius = ~nPoints*scaleFactor, 
                   fill = TRUE, stroke = FALSE, fillOpacity = 0.5)
#Ending chunk timer
toc(log = TRUE)

#Checking result
m
```

**Note**: Due to the size of the interactive map, we chose not to
display it in the GitHub markdown (file ending in `.md`), however, you
will be able to see it and interact with it when you run the code above
in RStudio using the file ending in `.qmd`.

We are done! We can check the total execution time for this notebook
below.

``` r
#Ending overall timer
toc(log = TRUE)
```

    Total time: 68.95 sec elapsed

``` r
#Printing time for all timers
tic.log(format = TRUE)
```

    [[1]]
    [1] "S3: 32.53 sec elapsed"

    [[2]]
    [1] "Metadata: 0.02 sec elapsed"

    [[3]]
    [1] "Summarise: 36.09 sec elapsed"

    [[4]]
    [1] "Total time: 68.95 sec elapsed"
