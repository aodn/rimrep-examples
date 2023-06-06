# rimrep-examples

A repository containing example notebooks and documentation for the RIMReP project.

## Data API proof-of-concept

### Direct data access

#### Python

- [Geoparquet example (using AIMS Temperature Loggers data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/geoparquet.ipynb)
- [Zarr example (using NOAA Coral Reef Watch degree heating weeks data)](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/zarr.ipynb)

We are also including an `environment.yml` file, which contains all `Python` packages used in the notebooks above. You can use this file to create a [`conda` environment](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/environments.html) with all the required packages. To do so, run the following command in the Anaconda Prompt (Windows) or in your terminal (MacOS, Linux):  
  
```bash
conda env create -f environment.yml
```
  
**Note**: Before running the code above, you need to have [`conda`](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) installed in your machine. Make sure you choose the correct installation instructions for your operating system.  

#### R

These are [quarto](https://quarto.org) R notebooks:

- [AIMS temperature loggers](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/AIMS_waterTemp.qmd): This notebook connects with the AIMS temperature logger dataset in our AWS S3 bucket, calculates the mean latitude and logitude of all deployments per site and calculates the number of records, using familiar [dplyr](https://dplyr.tidyverse.org) verbs. Then with the aggregated data frame, it creates a map of the sites with the size of the marker proportional to the number of record in the site. This dataset contains more than 150 millions of records!  
  
We also have the following `R` markdown notebooks:
- [Extracting water temperature at site](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/Extracting_Water_Temperature_at_site.md): This notebook calculates monthly temperature means for any sites of interest included in the AIMS Sea Surface Temperature Monitoring Program. Data summaries and plots saved in local machine.  
- [Extracting spatial data GBR](https://github.com/aodn/rimrep-examples/blob/main/poc-data-api/Extracting_Spatial_Data_GBR_Features.md): This notebook extracts spatial data for all above water features within the Great Barrier Reef Marine Protected Area.
  
**Note:** You will notice that there are two files with the same name, but two different extensions: `.md` and `.Rmd`. They contain the same information, but in different formats. The `.Rmd` file is the source code of the notebook, which you can open in RStudio and run. While the `.md` file is the output of the `.Rmd` file and they include the results of running the code. If you click on the notebook links above, it will take you to the `.md` files, which are nicely formatted for GitHub.
  
## USE CASE 01: RLS - data from Reef Life Survey

The notebook responds to this request:

As **Reef Outlook** I need **total reef fish abundance** per **GBR administrative** region at **5 $km^{2}$ aggregates** per **year**.
