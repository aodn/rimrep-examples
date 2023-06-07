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


# Defining functions ------------------------------------------------------

#Extracting features by feature name
sub_site <- function(site_name, sites){
  unique_sites <- str_to_lower(unique(sites$LOC_NAME_S))
  true_site <- unique_sites[str_detect(unique_sites, str_to_lower(paste(site_name, collapse = "|")))]
  if(length(true_site) == 0){
    stop(paste("Site names given do not exist. Check site names:", paste(site_name, collapse = ",")))
  }
  if(length(site_name) != length(true_site)){
    not_site <- site_name[!str_to_lower(site_name) %in% str_match(true_site, str_to_lower(paste(site_name, collapse = "|")))]
    true_site <- site_name[str_to_lower(site_name) %in% str_match(true_site, str_to_lower(paste(site_name, collapse = "|")))]
    if(length(not_site) > 0){
      warning(paste("One or more site names do not seem to exist. Check site names:", paste(not_site, collapse = ",")))
    }}
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
  finally = message("Subsetting GBR features by ", paste(true_site, collapse = ",")))
  return(out_site)
}


#Extracting features by ID
sub_ID <- function(site_ID, sites){
  if(class(site_ID) != "character"){
    site_ID <- str_pad(as.character(site_ID), 11, pad = 0)
  }
  unique_ID <- unique(sites$UNIQUE_ID)
  true_ID <- site_ID[site_ID %in% unique_ID]
  if(length(true_ID) == 0){
    stop(paste("Site IDs given do not exist. Check site IDs:", paste(site_ID, collapse = ",")))
  }
  if(length(site_ID) != length(true_ID)){
    not_ID <- site_ID[!site_ID %in% unique_ID]
  warning(paste("One or more site IDs do not seem to exist. Check site IDs:", paste(not_ID, collapse = ",")))
  }
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
  
  if(!is.null(site_name) & !is.null(site_ID)){
    names_sub <- sub_site(site_name, sites_all)
    ids_sub <- sub_ID(site_ID, sites_all)
    sites_sub <- bind_rows(names_sub, ids_sub)
  }else if(!is.null(site_name) & is.null(site_ID)){
    sites_sub <- sub_site(site_name, sites_all)
  }else if(!is.null(site_ID) & is.null(site_name)){
    sites_sub <- sub_ID(site_ID, sites_all)}
  
  if(is.null(site_name) & is.null(site_ID)){
    return(sites_all)
  }else(return(sites_sub))
}


