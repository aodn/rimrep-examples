# Useful functions to extract data using polygons
#
# Author: Denisse Fierro Arcos
# Date: 2023-06-07


# Loading libraries -------------------------------------------------------
library(arrow)
library(dplyr)
library(magrittr)
library(stringr)
library(wkb)
library(ggplot2)
library(sf)
library(lubridate)


# Defining supporting functions -------------------------------------------
#These functions are called by the gbr_features function to subset GBR features by name, ID or both

#Extracting features by feature name
sub_site <- function(site_name, sites){
  #Extracting list of unique site names - Transforming to lower case to make them case insensitive
  unique_sites <- str_to_lower(unique(sites$LOC_NAME_S))
  #Checking that site names provided as input exist in list of unique site names in the GBR features
  true_site <- unique_sites[str_detect(unique_sites, str_to_lower(paste(site_name, collapse = "|")))]
  #If there are no matches, an error will be raised
  if(length(true_site) == 0){
    stop(paste("Site names given do not exist. Check site names:", paste(site_name, collapse = ",")))
  }
  #If some names provided as input are not included in the GBR database, a warning is raised which includes the incorrect names
  #which will NOT be processed
  if(length(site_name) != length(true_site)){
    not_site <- site_name[!str_to_lower(site_name) %in% str_match(true_site, str_to_lower(paste(site_name, collapse = "|")))]
    true_site <- site_name[str_to_lower(site_name) %in% str_match(true_site, str_to_lower(paste(site_name, collapse = "|")))]
    if(length(not_site) > 0){
      warning(paste("One or more site names do not seem to exist. Check site names:", paste(not_site, collapse = ",")))
    }}
  #Fuzzy matching of site names
  out_site <- tryCatch({
    sites <- sites %>% 
      filter(str_detect(str_to_lower(LOC_NAME_S), str_to_lower(paste(site_name, collapse = "|"))))
  },
  error = function(cond){
    message("Here's the original error message:")
    message(cond)
    # Choose a return value in case of error
    return(NA)
  },
  warning = function(cond){
    message("Here's the original error message:")
    message(cond)
    },
  #Printing message of sites included in subsetting of GBR features
  finally = message("Subsetting GBR features by ", paste(true_site, collapse = ",")))
  return(out_site)
}


#Extracting features by ID
sub_ID <- function(site_ID, sites){
  #Ensure site IDs is of class character and has 11 characters (zeroes will be added if needed)
  if(class(site_ID) != "character"){
    site_ID <- str_pad(as.character(site_ID), 11, pad = 0)
  }
  #Extracting list of unique site IDs
  unique_ID <- unique(sites$UNIQUE_ID)
  #Checking that site IDs provided as input exist in list of unique site IDs in the GBR features
  true_ID <- site_ID[site_ID %in% unique_ID]
  #If there are no matches, an error will be raised
  if(length(true_ID) == 0){
    stop(paste("Site IDs given do not exist. Check site IDs:", paste(site_ID, collapse = ",")))
  }
  #If some IDs provided as input are not included in the GBR database, a warning is raised which includes the incorrect IDs
  #which will NOT be processed
  if(length(site_ID) != length(true_ID)){
    not_ID <- site_ID[!site_ID %in% unique_ID]
  warning(paste("One or more site IDs do not seem to exist. Check site IDs:", paste(not_ID, collapse = ",")))
  }
  #Matching of site IDs
  out_ID <- tryCatch({
    sites <- sites %>% 
      filter(UNIQUE_ID %in% true_ID)
  },
  error = function(cond){
    message("Here's the original error message:")
    message(cond)
    # Choose a return value in case of error
    return(NA)
  },
  warning = function(cond){
    message("Here's the original error message:")
    message(cond)
  },
  finally = message("Subsetting GBR features by ", paste(true_ID, collapse = ",")))
  return(out_ID)
}

## Getting shapefile with Great Barrier Reef features ---------------------
gbr_features <- function(site_name = NULL, site_ID = NULL){
  #Establishing connection
  data_bucket <- s3_bucket("s3://rimrep-data-public/gbrmpa-complete-gbr-features")
  #Accessing dataset
  data_df <- open_dataset(data_bucket)
  
  #Extract sites
  sites_all <- data_df %>% 
  #Selecting unique sites included in the dataset
  distinct(UNIQUE_ID, GBR_NAME, LOC_NAME_S, geometry) %>%
  #This will load them into memory
  collect()
  
  #Cleaning up data
  sites_all <- sites_all %>% 
    #Adding column with spatial information in degrees
    mutate(coords_deg = readWKB(geometry) %>% st_as_sf())
  
  #Clean up sites information transforming into shapefile
  sites_all <- sites_all %>%
    #Removing original geometry column
    select(!geometry) %>% 
    #Renaming coordinate degrees column
    mutate(coords_deg = coords_deg$geometry) %>% 
    rename("geometry" = "coords_deg") %>% 
    #Transforming into shapefile
    st_as_sf() %>% 
    #Assigning reference systems: WGS84 (EPSG: 4326)
    st_set_crs(4326)
  
  #Ensuring simple feature has valid geometries
  sites_all <- st_make_valid(sites_all)
  
  #If site names and site IDs are given, search database using the functions above
  if(!is.null(site_name) & !is.null(site_ID)){
    names_sub <- sub_site(site_name, sites_all)
    ids_sub <- sub_ID(site_ID, sites_all)
    sites_sub <- bind_rows(names_sub, ids_sub)
  }else if(!is.null(site_name) & is.null(site_ID)){
    sites_sub <- sub_site(site_name, sites_all)
  }else if(!is.null(site_ID) & is.null(site_name)){
    sites_sub <- sub_ID(site_ID, sites_all)}
  
  #If no site names or IDs are given, return all geometries
  if(is.null(site_name) & is.null(site_ID)){
    return(sites_all)
  }else(return(st_make_valid(sites_sub)))
}


# Clipping AIMS sites with GBR features -----------------------------------
sites_of_interest <- function(sites_pts, area_polygons){
  #Checking all polygons have valid geometries, otherwise fix
  if(sum(!st_is_valid(un_reefs)) != 0){
    area_polygons <- st_make_valid(area_polygons)
  }
  #Cropping to polygon boundaries
  crop_sites <- st_crop(sites_pts, area_polygons)
  #Extracting points that intersect with polygon
  sites_index <- st_intersects(crop_sites, area_polygons)
  crop_sites <- crop_sites[lengths(sites_index) > 0,]
  
  return(crop_sites)
}
