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
library(httr2)
library(httr)
library(terra)

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


## Defining functions to access RIMReP DMS via API
# Getting token as user input ---------------------------------------------
# Input from user will not be visible in screen
# Script originally from https://www.magesblog.com/post/2014-07-15-simple-user-interface-in-r-to-get-login/
access_dms <- function(){
  require(tcltk)
  
  tt <- tktoplevel()
  tkwm.title(tt, "Get login details")
  Password <- tclVar("Password")
  entry.Password <- tkentry(tt, width = "20", show = "*", 
                            textvariable = Password)
  tkgrid(tklabel(tt, text = "Please enter your login details."))
  tkgrid(entry.Password)
  
  OnOK <- function()
  { 
    tkdestroy(tt) 
  }
  OK.but <-tkbutton(tt, text = " OK ", command = OnOK)
  tkbind(entry.Password, "<Return>", OnOK)
  tkgrid(OK.but)
  tkfocus(tt)
  tkwait.window(tt)
  
  invisible(tclvalue(Password))
}


# Accessing DMS using token provided as input -----------------------------
connect_dms_dataset <- function(API_base_url, variable_name, start_time = NULL, 
                                end_time = NULL, lon_limits = NULL, 
                                lat_limits = NULL){
  #########
  #This function connects to RIMReP API to extract gridded data. It can extract
  #data using spatial and temporal limits
  #
  #Inputs:
  #API_base_url (character): URL to pygeoAPI collection of interest
  #variable_name (character): Name of variable that will be returned by function
  #(Optional)
  #start_time (character/date): First date for which data is extracted. If no
  #end_time is provided, then a single date will be returned. Date format must be
  #YYYY-MM-DD
  #end_time (character/date): Last date for which data is extracted. Date must be
  #provided as YYYY-MM-DD. If no start_time is given, an error will be raised.
  #lon_limits (numeric vector): minimum and maximum longitudes from where data
  #should be extracted.
  #lat_limits (numeric vector): minimum and maximum latitudes from where data
  #should be extracted.
  #
  #Outputs:
  #raster (terra SpatRaster): Raster including data for the variable of choice. 
  #If provided, spatio-temporal boundaries are applied to returned data
  #########
  
  #Parse API URL
  url <-  parse_url(API_base_url)
  #Add coverage to path ending - Ensure path does not end in "/"
  url$path <- file.path(str_remove(url$path, "/$"), "coverage")
  
  #Initialising query list
  query_list <- list()
  
  #Check if temporal limits were provided
  #Start time - Ensure date was provided in correct format, otherwise print error
  if(!is.null(start_time)){
    start_time <- tryCatch(expr = (ymd(start_time, tz = NULL)),
                           warning = function(w){
                             message(paste("Start date is NOT in 'YYY-MM-DD' format"))
                             message("Check date ('", start_time, "') and try again")}
    )}else{start_time <- NULL}
  #End time - Ensure date was provided in correct format, otherwise print error
  if(!is.null(end_time)){
    end_time <- tryCatch(ymd(end_time, tz = NULL),
                         warning = function(w){
                           message(paste("End date is NOT in 'YYY-MM-DD' format"))
                           message("Check date ('", end_time, "') and try again")}
    )}else{end_time <- NULL}
  
  #If only start time exists then use only one date as temporal range
  if(!is.null(start_time) & is.null(end_time)){
    dt_limits <- start_time
    #If end time is given, bit no start time, then print message
  }else if(is.null(start_time) & !is.null(end_time)){
    stop("'start_time' not provided, cannot use 'end_time'")
  }else if(!is.null(start_time) & !is.null(end_time)){
    if(start_time < end_time){
      dt_limits <- paste(start_time, end_time, sep = "/")
    }else{
      stop("'start_time' cannot be later than or equal to 'end_time'")}
  }
  
  #If temporal limits provided, add to URL query
  if(exists("dt_limits")){
    query_list$datetime <- dt_limits
    url$query <- query_list
  }
  
  #Check if spatial limits were provided
  #Longitudinal limits
  if(!is.null(lon_limits)){
    #Ensure vector provided is numeric, otherwise print error
    if(is.numeric(lon_limits) == F){
      lon_limits <- tryCatch(expr = as.numeric(lon_limits),
                             warning = function(w){
                               stop("Longitudinal limits provided are not numbers")})
      if(sum(is.na(lon_limits)) > 0){
        stop("Longitudinal limits provided are not numbers")}
    }
    lon_query <- paste0("lon(", paste0(sort(lon_limits), collapse = ":"), ")")
  }
  
  #Latitudinal limits
  if(!is.null(lat_limits)){
    #Ensure vector provided is numeric, otherwise print error
    if(is.numeric(lat_limits) == F){
      lat_limits <- tryCatch(expr = as.numeric(lat_limits),
                             warning = function(w){
                               stop("Latitudinal limits provided are not numbers")})
      if(sum(is.na(lat_limits)) > 0){
        stop("Latitudinal limits provided are not numbers")}
    }
    lat_query <- paste0("lat(", paste0(sort(lat_limits), collapse = ":"), ")")
  }
  
  #If temporal limits provided, add to URL query
  if(exists("lon_query") & exists("lat_query")){
    query_list$subset <- paste(lon_query, lat_query, sep = ",")
    url$query <- query_list
  }else if(exists("lon_query") & !exists("lat_query")){
    query_list$subset <- lon_query
    url$query <- query_list
  }else if(!exists("lon_query") & exists("lat_query")){
    query_list$subset <- lat_query
    url$query <- query_list
  }
  
  #Build URL
  url <- build_url(url)
  
  #Ask for token - Do not show token
  token <- access_dms()
  
  #Connect to API
  ds_conn <- request(url) |>
    req_headers("Authorization" = paste("Bearer", token),
                Accept = "application/json") |>
    req_perform()
  
  #Turn results to JSON
  res_json <- ds_conn |> 
    resp_body_json()
  
  #Extract values for variable of interest
  var_int <- res_json[["ranges"]][[variable_name]][["values"]]
  #If nothing is returned, return an error
  if(is.null(var_int)){
    message(paste0("'", variable_name, "' does not exist in dataset"))
    stop("Check variable name and try again")
  }
  
  # Replace NULL for NA in matrix
  var_int[sapply(var_int, is.null)] <- NA
  #Unlist into a single vector
  var_int <- (unlist(var_int, use.names = FALSE))
  
  #Get dimensions information
  lat_info <- res_json$domain$axes$y
  lon_info <- res_json$domain$axes$x
  time_info <- res_json$domain$axes$time
  
  #Calculate dimensions of data for every time step
  dim_2d <- lat_info$num*lon_info$num
  #If only a single value is return per time step 
  if(dim_2d == 1){
    #Create empty array to save information
    arr <- array(dim = c(lat_info$num, lon_info$num, time_info$num))
    #Loop along time steps
    for(i in seq_len(time_info$num)){
      #Add step along Z dimension (time)
      arr[,,i] <- matrix(var_int[i], nrow = lat_info$num, ncol = lon_info$num, byrow = T)
    }#If there are multiple values for each time step
  }else{
    #Create empty array to save information
    arr <- array(dim = c(lat_info$num, lon_info$num, time_info$num))
    #Set up variables before initialising loop
    s <- 1
    e <- dim_2d
    #Loop along time steps
    for(i in seq_len(time_info$num)){
      #Add step along Z dimension (time)
      arr[,,i] <- matrix(var_int[s:e], nrow = lat_info$num, ncol = lon_info$num, byrow = T)
      s <- s+dim_2d
      e <- dim_2d*(i+1)
    }}
  
  #Convert array into multidimensional raster
  brick <- rast(arr)
  
  #Return raster
  return(brick)
}


x <- "https://pygeoapi.staging.reefdata.io/collections/noaa-crw-dhw/coverage?datetime=2023-01-01/2023-01-03&subset=lon(145.30:146.90),lat(-17:-16.30)"


