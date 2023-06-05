# rimrep-examples

A repository containing example notebooks and documentation for the RIMReP project.

## Data API proof-of-concept

### Direct data access

#### Python

- [Geoparquet example (using AIMS Temperature Loggers data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/geoparquet.ipynb)
- [Zarr example (using NOAA Coral Reef Watch degree heating weeks data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/zarr.ipynb)

#### R

These are [quarto](https://quarto.org) R notebooks:

- [AIMS temperature loggers](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/AIMS_waterTemp.qmd)

This notebook connects with the AIMS temperature logger dataset in our AWS S3 bucket, calculates the mean latitude and logitude of all deployments per site and calculates the number of records, using familiar [dplyr](https://dplyr.tidyverse.org) verbs. Then with the aggregated data frame, it creates a map of the sites with the size of the marker proportional to the number of record in the site. This dataset contains more than 150 millions of records!  
  
These are R markdown notebooks:  
- [Extracting water temperature at site]("poc-data-api/Extracting_Water_Temperature_at_site.md"): This notebook calculates monthly temperature means for any sites of interest included in the AIMS Sea Surface Temperature Monitoring Program. Data summaries and plots saved in local machine.  
  
## USE CASE 01: RLS - data from Reef Life Survey

The notebook responds to this request:

As **Reef Outlook** I need **total reef fish abundance** per **GBR administrative** region at **5 $km^{2}$ aggregates** per **year**.
