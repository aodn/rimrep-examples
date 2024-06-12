# DMS Python notebooks

Use these notebooks to explore the data from the DMS project.

## 01-Direct-accessing-eReef  
This notebook demonstrates how to access a public dataset from the RIMReP DMS that is in `zarr` format. We will use the [AIMS - eReefs Aggregations of Hydrodynamic Model Outputs (4km Daily)](https://thredds.ereefs.aims.gov.au/thredds/resources/docs/gbr4.html) dataset as an example.  

## 02-Extracting_Spatial_Data_GBR_Features  
This notebook will show how to access the RIMReP `geoparquet` collection for Great Barrier Reef (GBR) Feature from the Great Barrier Reef Marine Park Authority (GBRMPA). This dataset includes the unique IDs and names of all features above water, including sand banks, reefs, cays, islets, and islands. Since this dataset includes spatial data, we can extract the spatial limits of each feature included in this dataset.  

## 03-extract_NOAA-DHW  
This notebook demonstrates how to access a public dataset from the RIMReP collection using `Zarr`. We will use the [NOAA CRW degree heating weeks](https://www.coris.noaa.gov/search/catalog/search/resource/details.page?uuid=%7BF77EF0B8-C12F-463F-B66A-CC922E50A39D%7D) dataset as an example. We will also include examples of how to make simple calculations to produce maps and timeseries.  

## 04-AIMS_waterTemp  
This notebook demonstrates direct access to the [AIMS Temperature Logger Monitoring Program](https://apps.aims.gov.au/metadata/view/4a12a8c0-c573-11dc-b99b-00008a07204e) dataset in the RIMReP `geoParquet` collection. This dataset includes sea temperature data from 1980 for tropical and subtropical coral reefs around Australia, and it includes sites within the Great Barrier Reef.   

## 05-Extracting_Water_Temperature_at_Site  
This notebook demonstrates direct access to the [AIMS Temperature Logger Monitoring Program](https://apps.aims.gov.au/metadata/view/4a12a8c0-c573-11dc-b99b-00008a07204e) dataset in the RIMReP `geoparquet` collection. This dataset includes sea temperature data from 1980 for tropical and subtropical coral reefs around Australia, and it includes sites within the Great Barrier Reef. In this example, we will extract the coordinates for all sites sampled in this monitoring program and then extract the temperature data for a specific site of interest. This means that we will not need to know the exact location of the site, but we will need to know the name of the site of our interest.  

## 06-getDHWmax
This notebook allows you to connect with the DMS NOAA DHW product, extract the maximum DHW value and the corresponding day of the year for each pixel, and save the results as a netCDF file. You have the option to specify a spatial extent and a temporal extent (typically a full year).  

## 07-stac-metadata
This notebook shows basic use of our metadata API using a Python library PySTAC-Client. It demonstrates how to fetch all collections, fetch a given collection/item, and perform simple searches.  

