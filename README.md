# Automated data access from the Reef 2050 Integrated Monitoring and Reporting Program Data Management System (RIMReP DMS)

This repository contains example notebooks in `R` and `Python` showing how to access datasets available in the Reef 2050 Integrated Monitoring and Reporting Program Data Management System (RIMReP DMS).  These notebooks include suggested workflows on how to query datasets to create summary tables, figures, and maps.  

## Table of contents
- [What is RIMReP DMS?](#what-is-rimrep-dms)
- [Searching for datasets in RIMReP DMS](#searching-for-datasets-in-rimrep-dms)
  * [Searching for datasets via STAC](#searching-for-datasets-via-stac)
  * [Searching for datasets via Pygeoapi](#searching-for-datasets-via-pygeoapi)
- [Code snippets](#code-snippets)
  * [Connecting to S3 bucket](#connecting-to-s3-bucket)
  * [Extracting data from S3 bucket](#extracting-data-from-s3-bucket)
- [Running example notebooks in this repository](#running-example-notebooks-in-this-repository)
  * [Setting up your machine](#setting-up-your-machine)
- [Description of example notebooks in repository](#description-of-example-notebooks-in-repository)
- [Description of scripts in repository](#description-of-scripts-in-repository)
  
## What is RIMReP DMS?
RIMReP DMS is an Open Geospatial Consortium (OGC) API service and analysis-ready, cloud-optimised (ARCO) repository for data and metadata relevant to the management of the Great Barrier Reef. RIMReP DMS offers services to allow the discovery of the data and the interaction with external RIMReP systems.  
  
In simple terms, RIMReP DMS is a data portal that aims to be a "one-stop-shop" for all data related to the Great Barrier Reef World Heritage Area, which can be easily accessed by the Great Barrier Reef Marine Park Authority (GBRMPA) to support evidence-based management strategies. All datasets have a standard format regardless of their origin, which not only facilitates access to data, but also their analysis as it removes the need to quality control individual datasets.  

Datasets that have an open licence are publically available in the RIMReP DMS, while datasets that have a restricted licence are only available to users that have been granted access to them by the data provider.  
  
## Searching for datasets in RIMReP DMS
There are two main ways to browse datasets available in the RIMReP DMS:  
  
1. Via the SpatioTemporal Asset Catalogs (STAC). STAC provides a common language to describe a range of geospatial information, so that data can be indexed and easily discovered. Our STAC catalogue is available at [https://stac.staging.reefdata.io/](https://stac.staging.reefdata.io/).  
2. Via Pygeoapi, which provides API access to geospatial data that is compliant with OGC API standards. Our Pygeoapi service is available at [https://pygeoapi.staging.reefdata.io/](https://pygeoapi.staging.reefdata.io/).  
  
Alternatively, we provide a link to the original source of the dataset to give users the option of accessing the data directly from the data provider.  
   
### Searching for datasets via STAC
The [STAC catalogue](https://stac.staging.reefdata.io/) is a web-based interface that allows users to search for datasets using a range of filters, such as dataset name, data provider, and date range. To search for datasets, you have the option of clicking on the **Search** button on the top right corner of the page, or you can use the search bar on the top left corner of the page. These two options are highlighted in red boxes in the image below.  
  
![Screenshot of STAC catalogue home page showing the two search options mentioned in the previous paragraph](images/stac_home.png)
  
Datasets available via STAC are organised by **collections**, each containing one or multiple datasets or *items* that are related to each other. To illustrate this, we will use the [**AIMS Oceanography** collection](https://stac.staging.reefdata.io/browser/collections/aims-oceanography) as an example.  
  
![Screenshot of AIMS Oceanography collection page showing a single item is available in this collection](images/aims_ocean.png)
  
The collection level page includes the following information:  
  
- A description of the collection, which is a brief summary of the datasets available in the collection.  
- The items or datasets available in the collection. In this case, we can see that there is a single item available in the collection.  
- The license under which the datasets are available.  
- The temporal coverage of the datasets.  
- A map showing the spatial coverage of the datasets.  
- Information about the data provider
  
If you click on the item name (in this case, [*AIMS Sea Surface Temperature Monitoring Program*](https://stac.staging.reefdata.io/browser/collections/aims-oceanography/items/aims-sst)), you will be taken to the item level page.  
  
![Screenshot of AIMS Sea Surface Temperature Monitoring Program item page showing the item level information. Links to S3 bucket and API are highlighted in red boxes](images/aims_sst.png)
  
The item level page includes the following information:  
  
- A map showing the spatial coverage of the dataset.  
- A description of the dataset.  
- A link to the collection level page.  
- A link to the dataset available in a RIMReP DMS S3 bucket under the **Assets** section.  
- Under the **Additional Resources** section, there will be a link to the data API under and to the original source of the dataset.  
- Metadata about the dataset, including the projection system, preferred citation and the names of the columns in the dataset.  
  
The API and S3 links are highlighted in red boxes in the image above because these are the two methods shown in this repository to access datasets available in the RIMReP DMS.  
  
### Searching for datasets via Pygeoapi
![Screenshot of RIMReP DMS Pygeoapi home page highlighting in the red box where to access documentation](images/pygeoapi.png)  
  
All datasets available through STAC are also available via Pygeoapi. The main difference between the two is that Pygeoapi provides API access to the datasets, while STAC provides a web-based interface to search for datasets. A list of all datasets can be found at [https://pygeoapi.staging.reefdata.io/collections](https://pygeoapi.staging.reefdata.io/collections).  
  
Full documentation about how to use the API can be found under the **API Definition** section of the Pygeoapi home page shown inside the red box in the image above. You can also click [here](https://pygeoapi.staging.reefdata.io/openapi?f=html) to access the documentation.  
    
## Code snippets 
In this section, we are including code snippets that will help you get started with the RIMReP DMS. These snippets are available in `R` and `Python`, simply select the language you want to use from the tabs below.  
  
### Connecting to S3 bucket
To run this code in `R` or `Python`, you will need to have the S3 URL address for the dataset of your interest. For this example, we are using the *AIMS Sea Surface Temperature Monitoring Program* dataset, but you can simply replace the S3 URL address with the one for the dataset you want to access.   
  
You can get this URL following the instructions in the [Searching for datasets via STAC](#searching-for-datasets-via-stac) section above.  
  
<details>
<summary> Instructions for R users </summary>

```r
# Loading arrow library to connect to S3 bucket
library(arrow)
# Providing S3 URL address for dataset of interest
dataset_s3 <- "s3://rimrep-data-public/091-aims-sst/test-50-64-spatialpart/"
# Connecting to S3 bucket
s3_conn <- s3_bucket(dataset_s3)
# Accessing dataset
ds <- open_dataset(s3_conn)
```
  
Remember that you can change the value of `dataset_s3` to the S3 URL address for the dataset you want to access.  
  
Note that if you do not have the `arrow` library installed in your machine, you will need to install it before running the code above. You can do so by running the following line: `install.packages("arrow")`. Alternatively, you can run refer to the [Setting up your machine](#setting-up-your-machine) section below for instructions on how to install all packages used in this repository at once.  
</details>
  
<details>
<summary> Instructions for Python users </summary>

```python
# Loading pyarrow library to connect to S3 bucket
from pyarrow import parquet as pq
# Providing S3 URL address for dataset of interest
dataset_s3 = 's3://rimrep-data-public/091-aims-sst/test-50-64-spatialpart/'
# Connecting to S3 bucket
ds = pq.ParquetDataset(dataset_s3)
```
  
Remember that you can change the value of `dataset_s3` to the S3 URL address for the dataset you want to access.  
  
Note that if you do not have the `pyarrow` package installed in your machine, you will not be able to run the code above. You can install it using a package manager such as `pip` or `conda`. Alternatively, you can run refer to the [Setting up your machine](#setting-up-your-machine) section below for instructions on how to install all packages used in this repository at once.  
</details>
  
### Extracting data from S3 bucket
Once you have connected to the S3 bucket, you do not have to download the entire dataset to your local machine to carry out your analysis. Instead, you can extract data from the dataset of interest based on one or more conditions. You can then load into memory only the relevant data needed to create summary tables, figures, or maps. We are including code snippets showing a simple data selection based on spatial and temporal conditions.    
  
<details>
<summary> Instructions for R users </summary>

Once you have connected to the S3 bucket, you can use [`dplyr` verbs](https://dplyr.tidyverse.org/) to extract a subset of the data based on one or more conditions. Here, we assume that a dataset connection has already been established following instructions in the [Connecting to S3 bucket](#connecting-to-s3-bucket) section above and this dataset is stored in the `ds` variable. We will assume that our dataset has `longitude`, `latitude`, and `time` columns, and we will use them to extract data based on spatial and temporal conditions.  
  
```r
# Loading relevant libraries
library(dplyr)

# We will extract data for the year 2019 that includes Townsville and Cairns
ds_subset <- ds %>% 
  # First we apply a filter based on longitudes
  filter(longitude > 145.6 & longitude < 146.9) %>%
  # Then we apply a filter based on latitudes
  filter(latitude > -19.3 & latitude < -16.8) %>%
  # Finally, we apply a filter based on time
  filter(time >= "2019-01-01" & time <= "2019-12-31") %>% 
  # We could even select only the columns we need
  # We will assume that the dataset also has a column called 'site' and we want to select it
  select(longitude, latitude, time, site)

# We can now load the data into memory
ds_subset <- ds_subset %>% 
  collect()
```
  
You can change the values of the conditions above to extract data that is relevant for your needs. Other conditions may include extracting data based on a specific site, a specific depth range, or even a specific variable.  
</details>

<details>
<summary> Instructions for Python users </summary>

Once you have connected to the S3 bucket, you can use the `dask_geopandas` package to connect to a dataset and extract a subset of the data based on one or more conditions. We will assume that our dataset has `longitude`, `latitude`, and `time` columns, and we will use them to extract data based on spatial and temporal conditions.  We will use the *AIMS Sea Surface Temperature Monitoring Program* dataset as an example, but you can replace the S3 URL address with the one for the dataset you want to access.  
  
```python
# Loading relevant packages
import dask_geopandas as dgp

# We store the S3 URL address in a variable
dataset_s3 = 's3://rimrep-data-public/091-aims-sst/test-50-64-spatialpart/'

# We will define a variable our conditions to extract data for the year 2019 that includes Townsville and Cairns
filter = [(lon > 145.6),
          (lon < 146.9),
          (lat > -19.3),
          (lat < -16.8),
          (time >= "2019-01-01"),
          (time <= "2019-12-31")]

# We will extract data for the year 2019 that includes Townsville and Cairns
ds_subset = dgp.read_parquet(dataset_s3,
                            # We can select the columns of our interest with the columns argument
                             columns = ['lon', 'lat', 'time', 'site', 'qc_val'],
                            # We can specify the column we want to use as index
                             index = 'fid',
                            # We can now apply our filters
                             filters = filter,
                            # We can connect anonimously because this is a public dataset
                             storage_options = {'anon': True})

# We can now load the data into memory
ds_subset = ds_subset.compute()
```
</details>
  
## Running example notebooks in this repository
You can either download or clone this repository to your local machine if you want to run the example notebooks included here. Below we include some instructions on how to set up you machine before you can successfully run the example notebooks.  
  
### Setting up your machine

After making this repository available locally by either cloning or downloading it from GitHub, you need to ensure all packages used in this repository are installed in your local machine before running any notebooks. If any packages are not installed in your machine, you will not be able to run the example notebooks.
  
The good news is that you will not need to go through every notebook checking the libraries you need. We are providing some files that will automate this process for you whether you use `R`, `Python`, or both.  

**Note:** You will only need to complete the set up steps once per machine. This should be done prior to running the notebooks for the first time. Also note that if you plan to use notebooks in one language, either `R` or `Python`, there is no need to follow the set up steps for the programming language that you do NOT need.
  
<details>
<summary> Instructions for R users </summary>

If you are using the `R` notebooks, run the following two lines in the `RStudio` console:  
```R
  source("R_based_scripts/Installing_R_libraries.R")  
  checking_libraries()
```  
The lines above will run a function that automatically checks if any `R` libraries used in this repository are not installed in your machine. If any libraries are missing, it will install them automatically. Bear in mind that these notebooks were developed in `R` version 4.3.1, so you may need to upgrade your `R` version if you encounter any problems during package installation.
</details>

<details>
<summary> Instructions for Python users </summary>
We are also including an `requirements.txt` file under the `Python_based_scripts` folder, which contains all `Python` packages used in the notebooks above. You can use this file to create a [`conda` environment](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) with all the required packages. To do so, run the following command in the Anaconda Prompt (Windows) or in your terminal (MacOS, Linux):  
  
```bash
conda env create -f requirements.txt -n rimrep
```
  
where `rimrep` is the name of the environment. You can change this name to whatever you want. **Note**: If you are not in the directory where the `requirements.txt` file is located, the code above will not work. You will need to specify the path to the `requirements.txt` file. For example, if your terminal window is in the `rimrep-examples` folder, you will need to specify the full path to the `requirements.txt` file as follows:  
  
```bash
conda env create -f Python_based_scripts/requirements.txt -n rimrep
```
    
Finally, you will need to activate this environment before you are able to run the `Python` notebooks included here. To do so, run the following command in your terminal window:  
  
```bash
conda activate rimrep
```
  
When you are done running the notebooks, you can deactivate the environment by running `conda deactivate` in the terminal window.
activate.  
</details>

## Description of example notebooks in repository
All notebooks described in this section are available in `R` and `Python`, you will find them in the `R_based_scripts` and the `Python_based_scripts` folders, respectively. 

- **AIMS temperature loggers**: Available as a [Quarto notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/AIMS_waterTemp.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/AIMS_waterTemp.ipynb) for `Python` users. In this example, we will connect to the RIMReP geoparquet collection in our AWS S3 bucket to access the AIMS temperature logger dataset, which contains over 150 million records! We will calculate the mean latitude, longitude, and temperature, and total number of temperature records for all deployment sites around the Great Barrier Reef Marine Protected Area using familiar [dplyr](https://dplyr.tidyverse.org) verbs. Finally, we aggregated all data at a site level to create a map where the site marker change in size in proportion to the number of records at each site.  
- **Extracting water temperature at site**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Water_Temperature_at_Site.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Water_Temperature_at_Site.ipynb) for `Python` users. This notebook calculates monthly temperature means for any sites of interest included in the AIMS Sea Surface Temperature Monitoring Program. Data summaries and plots saved in local machine.  
- **Extracting spatial data GBR**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Spatial_Data_GBR_Features.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Spatial_Data_GBR_Features.ipynb) for `Python` users. This notebook extracts spatial data for all above water features within the Great Barrier Reef Marine Protected Area.  
- **Extracting water temperature within GBR feature boundaries**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Water_Temperature_GBR_Features.md) and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Water_Temperature_GBR_Features.ipynb): This notebook will identify AIMS water temperature monitoring sites within a GBR feature and calculate monthly means.  
- **Plotting ABS census data**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Plotting_ABS_Census_Data_LGA_2021.md) and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Plotting_ABS_Census_Data_LGA_2021.ipynb): This notebooks uses Australian Bureau of Statistics (ABS) census data to create summary tables, bar plots and maps.  
- **Plotting SELTMP data**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Plotting_SELTMP_Data.md) and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Plotting_SELTMP_Data.ipynb): This notebooks uses the the Social and Economic Long-Term Monitoring Program (SELTMP) dataset from CSIRO to create a variety of plots available in their [dashboard](https://research.csiro.au/seltmp/explore-dashboards-here/).  
  
Additionally, there are two more notebooks available exclusively for `Python` users:  
- [**Geoparquet example (using AIMS Temperature Loggers data)**](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/geoparquet.ipynb)  
- [**Zarr example (using NOAA Coral Reef Watch degree heating weeks data)**](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/zarr.ipynb) 
  
**Note:** You will notice that there are two files with the same name, but two different extensions: `.md` and `.Rmd`. They contain the same information, but in different formats. The `.Rmd` file is the source code of the notebook, which you can open in RStudio and run. While the `.md` file is the output of the `.Rmd` file and they include the results of running the code. If you click on the notebook links above, it will take you to the `.md` files, which are nicely formatted for GitHub.
  
## Description of scripts in repository
All scripts described in this section are available in `R` and `Python`, you will find them in the `R_based_scripts` and the `Python_based_scripts` folders, respectively. 
- **Useful Spatial Functions to extract data**: Available as an [`R` script](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/useful_spatial_functions_data_extraction.R) and in [`Python`](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/useful_spatial_functions_data_extraction.py). This script includes a collection of functions that we will use to extract data available in the RIMReP collections using spatial data, such as polygons defining boundaries for the area of our interest.  
  