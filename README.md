# Accessing data from the Reef 2050 Integrated Monitoring and Reporting Program Data Management System (RIMReP DMS) using `R` and `Python`

This repository contains example notebooks in `R` and `Python` showing how to access datasets available in the Reef 2050 Integrated Monitoring and Reporting Program Data Management System (RIMReP DMS).  These notebooks include suggested workflows on how to query datasets to create summary tables, figures, and maps.  
  
## What is RIMReP DMS?
RIMReP DMS is an Open Geospatial Consortium (OGC) API service and analysis-ready, cloud-optimised (ARCO) repository for data and metadata relevant to the management of the Great Barrier Reef. RIMReP DMS offers services to allow the discovery of the data and the interaction with external RIMReP systems.  
  
In simple terms, RIMReP DMS is a data portal that aims to be a ‘one-stop-shop’ for all data related to the Great Barrier Reef World Heritage Area, which can be easily accessed by the Great Barrier Reef Marine Park Authority (GBRMPA) to support evidence-based management strategies. All datasets have a standard format regardless of their origin, which not only facilitates access to data, but also their analysis as it removes the need to quality control individual datasets. Additionally, we also have plans to make all datasets in the RIMReP DMS publicly available to researchers and other stakeholders.  
  
## Code snippets

In this section, you can find code snippets that will help you get started with the RIMReP DMS. These snippets are available in `R` and `Python`, simply select the language you want to use from the tabs below.
`````{tab-set}
````{tab-item} R
library(dplyr)
````

````{tab-item} Python
import pandas as pd
````
`````

## Setting up your machine

After making this repository available locally by either cloning or downloading it from GitHub, you need to ensure all packages used in this repository are installed in your local machine before running any notebooks. If any packages are not installed in your machine, you will not be able to run the example notebooks.
  
The good news is that you will not need to go through every notebook checking the libraries you need. We are providing some files that will automate this process for you whether you use `R`, `Python`, or both.  

**Note:** You will only need to complete the set up steps once per machine. This should be done prior to running the notebooks for the first time. Also note that if you plan to use notebooks in one language, either `R` or `Python`, there is no need to follow the set up steps for the programming language that you do NOT need.
  
### `R` users
If you are using the `R` notebooks, run the following two lines in the `RStudio` console:  
```R
  source("R_based_scripts/Installing_R_libraries.R")  
  checking_libraries()
```  
The lines above will run a function that automatically checks if any `R` libraries used in this repository are not installed in your machine. If any libraries are missing, it will install them automatically. Bear in mind that these notebooks were developed in `R` version 4.3.1, so you may need to upgrade your `R` version if you encounter any problems during package installation.

### `Python` users
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
  

## Description of example notebooks in repository
All notebooks described in this section are available in `R` and `Python`, you will find them in the `R_based_scripts` and the `Python_based_scripts` folders, respectively. 

- **AIMS temperature loggers**: Available as a [Quarto notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/AIMS_waterTemp.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/AIMS_waterTemp.ipynb) for `Python` users. In this example, we will connect to the RIMReP geoparquet collection in our AWS S3 bucket to access the AIMS temperature logger dataset, which contains over 150 million records! We will calculate the mean latitude, longitude, and temperature, and total number of temperature records for all deployment sites around the Great Barrier Reef Marine Protected Area using familiar [dplyr](https://dplyr.tidyverse.org) verbs. Finally, we aggregated all data at a site level to create a map where the site marker change in size in proportion to the number of records at each site.  
- **Extracting water temperature at site**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Water_Temperature_at_Site.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Water_Temperature_at_Site.ipynb) for `Python` users. This notebook calculates monthly temperature means for any sites of interest included in the AIMS Sea Surface Temperature Monitoring Program. Data summaries and plots saved in local machine.  
- **Extracting spatial data GBR**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Spatial_Data_GBR_Features.md) for `R` users, and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Spatial_Data_GBR_Features.ipynb) for `Python` users. This notebook extracts spatial data for all above water features within the Great Barrier Reef Marine Protected Area.  
- **Extracting water temperature within GBR feature boundaries**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Extracting_Water_Temperature_GBR_Features.md) and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Extracting_Water_Temperature_GBR_Features.ipynb): This notebook will identify AIMS water temperature monitoring sites within a GBR feature and calculate monthly means.  
- **Plotting ABS census data**: Available as a [markdown notebook](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/Plotting_ABS_Census_Data_LGA_2021.md) and as a [Jupyter notebook](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/Plotting_ABS_Census_Data_LGA_2021.ipynb): This notebooks uses Australian Bureau of Statistics (ABS) census data to create summary tables, bar plots and maps.  
  
**Note:** You will notice that there are two files with the same name, but two different extensions: `.md` and `.Rmd`. They contain the same information, but in different formats. The `.Rmd` file is the source code of the notebook, which you can open in RStudio and run. While the `.md` file is the output of the `.Rmd` file and they include the results of running the code. If you click on the notebook links above, it will take you to the `.md` files, which are nicely formatted for GitHub.
  

## Description of scripts in repository
All scripts described in this section are available in `R` and `Python`, you will find them in the `R_based_scripts` and the `Python_based_scripts` folders, respectively. 
- **Useful Spatial Functions to extract data**: Available as an [`R` script](https://github.com/aodn/rimrep-examples/blob/main/R_based_scripts/useful_spatial_functions_data_extraction.R) and in [`Python`](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/useful_spatial_functions_data_extraction.py). This script includes a collection of functions that we will use to extract data available in the RIMReP collections using spatial data, such as polygons defining boundaries for the area of our interest.  

### Python

There are two Jupyter notebooks available:  
- [Geoparquet example (using AIMS Temperature Loggers data)](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/geoparquet.ipynb)  
- [Zarr example (using NOAA Coral Reef Watch degree heating weeks data)](https://github.com/aodn/rimrep-examples/blob/main/Python_based_scripts/zarr.ipynb)  
  
