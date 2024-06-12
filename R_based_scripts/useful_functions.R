# Useful functions to extract data using polygons
#
# Author: Denisse Fierro Arcos
# Date: 2023-06-07


# Loading libraries -------------------------------------------------------
library(arrow)
library(dplyr)
library(magrittr)
library(stringr)
library(ggplot2)
library(sf)
library(lubridate)
library(httr2)
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
  data_bucket <- s3_bucket("s3://gbr-dms-data-public/gbrmpa-complete-gbr-features/data.parquet")
  #Accessing dataset
  data_df <- open_dataset(data_bucket)
  
  #Extract sites
  sites_all <- data_df %>% 
  #Selecting unique sites included in the dataset
  distinct(UNIQUE_ID, GBR_NAME, LOC_NAME_S, geometry, FEAT_NAME,
           LEVEL_1, LEVEL_2, LEVEL_3) %>%
  #This will load them into memory
  collect()
  
  #Cleaning up data
  sites_all <- sites_all %>% 
    #Turning into sf object and assigning reference system: GDA94 (EPSG: 4283)
    st_as_sf(crs = 4283)
  
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


# Getting access token for DMS API access
dms_token <- function(client_id, client_secret){
  #########
  #This function connects to the Keycloak system are request an access token 
  #using unique user credentials: client_id and client_secret
  #
  #Inputs:
  #client_id (character): CLIENT_ID provided by DMS team. 
  #client_secret (character): CLIENT_SECRET provided by DMS team. 
  
  # Define base keycloak URL
  url <- "https://keycloak.reefdata.io/realms/rimrep-production/protocol/openid-connect/token"
  
  # Send request to keycloak
  resp <- url |>
    request() |> 
    #Authenticate access via client ID and secret
    req_auth_basic(client_id, client_secret) |> 
    #Request access token
    req_body_form(grant_type = "client_credentials") |> 
    #Send request
    req_perform()
  
  #If request is successful
  if(resp$status_code == 200){
    # Extract the access token from the response and store as environmental variable
    return(resp_body_json(resp)$access_token)
    }else{
      #Print error if request is unsuccessful
      stop("'Error retrieving access token. Check your CLIENT_ID and CLIENT_SECRET are correct and try again.'")
      }
}


# Accessing DMS API using credentials provided as input ------------------------
connect_dms_dataset <- function(API_base_url, variable_name, start_time = NULL, 
                                end_time = NULL, bounding_shape = NULL, lon_limits = NULL, 
                                lat_limits = NULL, access_token = NULL,
                                client_id = NULL, client_secret = NULL){
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
  #bounding_shape (sf vector file): This input will be used to calculate a bounding box
  #for raster data extraction. If this is provided, lon_limits and lat_limits will
  #be ignored.
  #lon_limits (numeric vector): minimum and maximum longitudes from where data
  #should be extracted.
  #lat_limits (numeric vector): minimum and maximum latitudes from where data
  #should be extracted.
  #access_token (character): DMS access token generated
  #client_id (character): CLIENT_ID provided by DMS team. 
  #client_secret (character): CLIENT_SECRET provided by DMS team. By default, the
  #function looks for this information in the "CLIENT_SECRET" environmental variable.
  #
  #Outputs:
  #raster (terra SpatRaster): Raster including data for the variable of choice. 
  #If provided, spatio-temporal boundaries are applied to returned data
  #########
  
  #If access token does not exist, check if client_id and client_secret exist
  if(missing(access_token)){
    #If client_id does not exist, check environmental variable
    if(missing(client_id)){
      message("Warning: No 'access_token' and no user credentials were provided as input.")
      message("Checking if 'CLIENT_ID' variable exists.")
      #If environmental variable exists, assign to client_id
      if(tryCatch(expr = !is.na(Sys.getenv("CLIENT_ID", unset = NA)))){
        client_id <- Sys.getenv("CLIENT_ID")
      }else{
        #If CLIENT_ID variable does not exist, stop function
        stop("'CLIENT_ID' does not exist. Provide 'client_id' parameter and try again.")
      }}
    #If client_secret does not exist, check environmental variable
    if(missing(client_secret)){
        message("Warning: No 'access_token' and user credentials were provided as input.")
        message("Checking if 'CLIENT_SECRET' variable exists.")
        #If environmental variable exists, assign to client_secret
        if(tryCatch(expr = !is.na(Sys.getenv("CLIENT_SECRET", unset = NA)))){
          client_secret <- Sys.getenv("CLIENT_SECRET")
          }else{
            #If CLIENT_SECRET variable does not exist, stop function
            stop("'CLIENT_SECRET' does not exist. Provide 'client_secret' parameter and try again.")
          }}
    #Once we have credentials ready, get token
    access_token <- dms_token(client_id, client_secret)
    message("Access token retrieved successfully.")
    }
  
  #Checking URL ending is correct
  if(str_detect(API_base_url, "coverage$", negate = T)){
    url <- str_replace(API_base_url, "/$", "") |> 
      str_c("/coverage?")}
  
  #Initialising query list
  query_list <- NULL
  
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
    query_list <- str_c("datetime=", dt_limits)
    }
  
  #Check if shapefile was provided
  if(!missing(bounding_shape)){
    #Checking that bounding box is in the correct EPSG
    if(st_crs(bounding_shape) != st_crs(4326)){
      bounding_shape <- st_transform(bounding_shape, 4326)
    }
    
    box_lims <- bounding_shape |> 
      #Get bounding box
      st_bbox() |> 
      #Transform to vector
      as.vector() |> 
      #Rounding coordinates to 2 decimal places
      round(2) |> 
      #Format data for query
      paste(collapse = ",")
    
    #Add limits to query
    if(is.null(query_list)){
      query_list <- str_c("bbox=", box_lims)
    }else{
      query_list <- str_c(query_list, "&bbox=", box_lims)
    }
  }else{
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
      lon_query <- sort(lon_limits)
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
      lat_query <- sort(lat_limits)
    }
    
    #If temporal limits provided, add to URL query
    if(exists("lon_query") & exists("lat_query")){
      box_lims <- paste(lon_query[1], lat_query[1], 
                        lon_query[2], lat_query[2], sep = ",")
      if(is.null(query_list)){
        query_list <- str_c("bbox=", box_lims)
      }else{
        query_list <- str_c(query_list, "&bbox=", box_lims)
      }
    }else if(exists("lon_query") & !exists("lat_query")){
      print("Latitudinal limits not provided, cannot apply a bounding box.")
    }else if(!exists("lon_query") & exists("lat_query")){
      print("Longitudinal limits not provided, cannot apply a bounding box.")
    }}
    
    #Add format
    if(is.null(query_list)){
      query_list <- str_c("f=netcdf")
    }else{
      query_list <- str_c(query_list, "&f=netcdf")
    }
  
  #Get URL ready
  url <- str_c(url, query_list) 
  
  #Get temporary file
  t_file <- tempfile("raster_dms_", fileext = ".nc")
  
  #Download data as temporary file
  con <- request(url) |>
    #Pass access token
    req_auth_bearer_token(access_token) |>
    #Download as temporary file
    req_perform()
  
  request(url) |>
    #Pass access token
    req_auth_bearer_token(access_token) |> 
    #Download as temporary file
    req_perform(path = t_file)
  
  #Load temporary file as spat raster
  brick <- rast(t_file)
  
  #Checking layers for variable of interest
  lyrs <- str_subset(names(brick), variable_name)
  if(length(lyrs) == 0){
    print(paste0("Variable ", variable_name, " does not exist. Returning all data."))
    #Return raster
    return(brick)
  }else{
    #Subsetting raster
    brick <- brick[[lyrs]]
    #Return raster
    return(brick)
  }
}


# Applying function to SpatRaster -----------------------------------------
raster_calc <- function(ras, period, fun, na.rm = F){
  ############
  #This function uses the tapp function from terra to apply a function to a 
  #SpatRaster object. Any functions accepted by app can be used here. Raster
  #will be grouped either by year or month before applying the function.
  #
  #Inputs:
  #ras (SpatRaster): Raster object to which the function will be applied. It 
  #must contain a time dimension.
  #period (character): Period for which the function will be applied. It can
  #be either "monthly" or "yearly".
  #fun (function): Function to be applied to the raster. It must be a function
  #accepted by the tapp function from terra.
  #na.rm (logical): If TRUE, NA values will be removed before applying the
  #function. Default is FALSE.
  
  #Get the time information from the raster
  time_ras <- time(ras)
  
  #Get units from the raster
  units_ras <- units(ras) |> 
    unique()
  
  #If period is monthly, we will get the month and year
  if(period == "monthly"){
    mystamp <- stamp("2020-01", order = "%Y-%m")
    #Get month and year combinations
    per_int <- mystamp(time_ras)
  }else if (period == "yearly"){
    #Get years
    per_int <- year(time_ras) |> 
      as.character()
  }else{
    stop("Period should be either 'monthly' or 'yearly'")
  }
  
  #Initialise empty vector to store results
  ras_out <- tapp(ras, index = per_int, fun = fun, na.rm = na.rm)
  
  #Update variable name
  varnames(ras_out) <- paste(fun, varnames(ras), sep = "_")
  
  #New name for layer - including time
  names(ras_out) <- paste(fun, unique(per_int), sep = "_")
  
  #Update time information
  if(period == "monthly"){
    time(ras_out) <- ym(unique(per_int))
  }else{
    time(ras_out) <- ymd(paste0(unique(per_int), "-01-01"))
  }
  
  #Add units
  units(ras_out) <- units_ras
  
  #Return SpatRaster
  return(ras_out)
}



# Extracting time series from SpatRaster ----------------------------------
ras_to_ts <- function(ras, fun, na.rm = F){
  ############
  #This function uses the global function from terra to calculate global 
  #statistics from a SpatRaster object. Any functions accepted by global can
  #be used here. It will also return the maximum monthly value of the time
  #series
  #
  #Inputs:
  #ras (SpatRaster): Raster object to which the function will be applied. It 
  #must contain a time dimension.
  #fun (function): Function to be applied to the raster. It must be a function
  #accepted by the global function from terra.
  #na.rm (logical): If TRUE, NA values will be removed before applying the
  #function. Default is FALSE.
  
  #Get time information from raster
  time_ras <- time(ras) |> 
    #Transform to date format
    as.Date(origin = lubridate::origin)
  #Get unit information from raster
  unit_ras <- units(ras)
  #Get the time series of the raster
  ras_ts <- global(ras, fun = fun, na.rm = na.rm) |> 
    #Add time and units to the time series
    mutate(time = time_ras, unit = unit_ras) |> 
    #Store rownmaes as column
    rownames_to_column("layer_name")
  
  #Return maximum values per month
  max_df <- ras_ts |>
    mutate(month = month(time, label = T)) |>
    #Group by month
    group_by(month) |> 
    #Identify the maximum monthly value
    summarise(max_monthly_val = max(get(names(ras_ts)[2])))
  
  return(list(time_series = ras_ts,
              max_monthly_ts = max_df))
}



