# DMS R notebooks

Use these notebooks to explore the data from the DMS project.

## 01-eReef_data_extraction

Extract one variable form the eReef model for one reef

## 02-eReef_maps_timeseries

Extract data from eReefs, produce a map and plot a time series at different depths

## 03-Extracting_Spatial_Data_GBR_Features

Show how to access the RIMReP geoparquet collection for Great Barrier Reef (GBR) Feature from the Great Barrier Reef Marine Park Authority (GBRMPA). This dataset includes the unique IDs and names of all features above water, including sand banks, reefs, cays, islets, and islands. Since this dataset includes spatial data, we can extract the spatial limits of each feature included in this dataset.

## 04-**LTMP_data_extraction**

This notebook will demonstrate how to access the Long-Term Monitoring Program (LTMP) dataset from AIMS. The goal of the LTMP is to measure the long-term status and trend of reefs in the Great Barrier Reef (GBR) World Heritage Area. Data has been collected across the GBR for over 35 years. There are a variety of variables measured during this campaign, but they all provide information about the health of the coral reefs.

## 05-LTMP_data_extraction_2

Another example about how to access and extract data from AIMS Long Term monitoring Program modeled data.

## 06-NOAA_Degree_Heating_Week

This notebook will demonstrate how to access the RIMReP collection for [NOAA's Coral Reef Watch - Degree Heating Week (DHW)](https://stac.staging.reefdata.io/browser/collections/noaa-crw/items/noaa-crw-dhw?.language=en&.asset=asset-data). This dataset provides coral bleaching heat stress index derived from satellite data a global scale with a temporal resolution of 1-day and a horizontal spatial resolution of about 5 km ($0.05^{\circ}$). The dataset available in the DMS is [version 3.1 of the NOAA's Coral Reef Watch - Degree Heating Week](https://coralreefwatch.noaa.gov/index.php), which includes data from January 1, 1985 to present. In this notebook, we will use the `connect_dms_dataset` function from the `useful_functions.R` script, which allows us to access data from the RIMReP DMS API. We also have the option of including spatial and temporal boundaries to extract the data of interest.

## 07-API_data_access

More examples on how to use DMS API to work with Zarr files

## 08-SST_climatologies

This notebook will demonstrate how to access the the different collections that contain Sea Surface Temperature climatologies. We will plot a map of a climatological values for a region, extract climatological expected temperature values from one point and produce a plot of the climatological year for one area.
