library(terra)
source("R_based_scripts/useful_functions.R")

base_url <-"https://pygeoapi.staging.reefdata.io/collections/noaa-crw-dhw/"

ras <- connect_dms_dataset(base_url, start_time = "2023-02-01")

plot(ras)
