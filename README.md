# rimrep-examples

This repository contains example notebooks in `R` and `Python` showing how to access datasets available in the Reef 2050 Integrated Monitoring and Reporting Program Data Management System (RIMReP DMS).  
  
Example notebooks also include suggested workflows on how to query datasets to create summary tables, figures, and maps.  

## Setting up your machine

After making this repository available locally by either cloning or downloading it, you need to ensure all packages used in this repository are already installed in your local machine. If you are missing any packages in your machine, you will not be able to run the example notebooks.
  
The good news is that you will not need to go through every notebook checking the libraries you need. We are providing some files that will automate this process for you whether you use `R`, `Python`, or both.  
  
### `R` users
If you are using the `R` notebooks, run the following two lines in the `RStudio` console:  
```R
  source("Installing_R_libraries.R")  
  checking_libraries()
```  
These lines run a function that automatically checks if any `R` libraries used in this repository are not installed in your machine, and it will install them automatically. Bear in mind that these notebooks were developed in `R` version 4.3.1, so you may need to upgrade your `R` version if you encounter any problems during package installation.

### `Python` users
We are also including an `environment.yml` file, which contains all `Python` packages used in the notebooks above. You can use this file to create a [`conda` environment](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) with all the required packages. To do so, run the following command in the Anaconda Prompt (Windows) or in your terminal (MacOS, Linux):  
  
```bash
conda env create -f environment.yml
```
  
**Note**: Before running the code above, you need to have [`conda`](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) installed in your machine. Make sure you choose the correct installation instructions for your operating system.  


## Description of example notebooks available

#### Python

- [Geoparquet example (using AIMS Temperature Loggers data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/geoparquet.ipynb)
- [Zarr example (using NOAA Coral Reef Watch degree heating weeks data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/zarr.ipynb)



#### R

There is one `R` script [Useful Spatial Functions to extract data](https://github.com/aodn/rimrep-examples/blob/main/scripts_poc-data-api/useful_spatial_functions_data_extraction.R) which includes a collection of functions that we will use to extract data available in the RIMReP collections using spatial data, such as polygons defining boundaries for the area of our interest.

These are [quarto](https://quarto.org) R notebooks:

- [AIMS temperature loggers](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/AIMS_waterTemp.qmd): This notebook connects with the AIMS temperature logger dataset in our AWS S3 bucket, calculates the mean latitude and logitude of all deployments per site and calculates the number of records, using familiar [dplyr](https://dplyr.tidyverse.org) verbs. Then with the aggregated data frame, it creates a map of the sites with the size of the marker proportional to the number of record in the site. This dataset contains more than 150 millions of records!  
  
We also have the following `R` markdown notebooks:
- [Extracting water temperature at site](https://github.com/aodn/rimrep-examples/blob/main/scripts_poc-data-api/Extracting_Water_Temperature_at_Site.md): This notebook calculates monthly temperature means for any sites of interest included in the AIMS Sea Surface Temperature Monitoring Program. Data summaries and plots saved in local machine.  
- [Extracting spatial data GBR](https://github.com/aodn/rimrep-examples/blob/main/scripts_poc-data-api/Extracting_Spatial_Data_GBR_Features.md): This notebook extracts spatial data for all above water features within the Great Barrier Reef Marine Protected Area.
- [Extracting water temperature within GBR feature boundaries](https://github.com/aodn/rimrep-examples/blob/main/scripts_poc-data-api/Extracting_Water_Temperature_GBR_Features.md): This notebook will identify AIMS water temperature monitoring sites within a GBR feature and calculate monthly means.
- [Plotting ABS census data](https://github.com/aodn/rimrep-examples/blob/main/scripts_poc-data-api/Plotting_ABS_Census_Data_LGA_2021.md): This notebooks uses Australian Bureau of Statistics (ABS) census data to create summary tables, bar plots and maps.  

  
**Note:** You will notice that there are two files with the same name, but two different extensions: `.md` and `.Rmd`. They contain the same information, but in different formats. The `.Rmd` file is the source code of the notebook, which you can open in RStudio and run. While the `.md` file is the output of the `.Rmd` file and they include the results of running the code. If you click on the notebook links above, it will take you to the `.md` files, which are nicely formatted for GitHub.
  
## USE CASE 01: RLS - data from Reef Life Survey

The notebook responds to this request:

As **Reef Outlook** I need **total reef fish abundance** per **GBR administrative** region at **5 $km^{2}$ aggregates** per **year**.


## What is RIMReP DMS?
RIMReP DMS is an Open Geospatial Consortium (OGC) API service and analysis-ready, cloud-optimised (ARCO) repository for data and metadata relevant to the management of the Great Barrier Reef. RIMReP DMS offers services to allow the discovery of the data and the interaction with external RIMReP systems.  
  
In simple terms, RIMReP DMS is a data portal that aims to be a ‘one-stop-shop’ for all data related to the Great Barrier Reef World Heritage Area, which can be easily accessed by the Great Barrier Reef Marine Park Authority (GBRMPA) to support evidence-based management strategies. All datasets have a standard format regardless of their origin, which not only facilitates access to data, but also their analysis as it removes the need to quality control individual datasets. Additionally, we also have plans to make all datasets in the RIMReP DMS publicly available to researchers and other stakeholders.  
