# Useful functions to extract data using polygons
#
# Author: Denisse Fierro Arcos
# Date: 2023-06-28

#Calling libraries
from pyarrow import parquet as pq
import pandas as pd
import re
import dask_geopandas
import geopandas as gpd
import matplotlib.pyplot as plt
from matplotlib import colormaps as cmaps
import cartopy.crs as ccrs
import cartopy.feature as cf

########
#Defining functions
#These functions are called by the gbr_features function to subset GBR features by name, ID or both
def sub_site(site_name, sites):
    '''
    Inputs:
    site_name: string. Name of the site to be extracted. If not specified, all sites will be returned.
    sites: geopandas data frame. Containing all GBR features.
    '''
    
    #Checking the type of the input for site_name
    if type(site_name) == str:
        site_name = [site_name.lower()]
    elif type(site_name) == list:
        #Check if all items in list are strings
        [print(f'{i} is not a string. "site_name" must be a string or lists of strings') for i in site_name if type(i) != str]
        site_name = [i.lower() for i in site_name if type(i) == str]
    else:
        #If they are not strings, print error message and return empty site_name
        print(f'{site_name} is not a string. "site_name" must be a string or lists of strings.')
        site_name = []

    #Checking that site names provided as input exist in list of unique site names in the GBR features
    #Forcing site_name and LOC_NAME_S to be in lower case to make them case insensitive
    # true_site = sites[sites.LOC_NAME_S.str.lower().str.contains(site_name.lower())]
    if len(site_name) == 0:
        true_site = []
    else:
        #Going through every site name provided and matching with site names in GBR features
        true_site = []
        for s in site_name:
            #Subset GBR features by site name (partial match)
            sub = sites[sites.LOC_NAME_S.str.lower().str.contains(s)]
            #If there are no matches, print error message
            if len(sub) == 0:
                print(f'Site "{s}" does not exist. Check site names')
            else:
                #Otherwise save subsetted GBR features
                print(f'Subsetting GBR features by {s}')
                true_site.append(sub)
        #If there are no matches, an error will be raised
        if len(true_site) == 0:
            true_site = []
        else:
            #Otherwise, concatenate all subsets
            true_site = pd.concat(true_site)
    
    return true_site


def sub_id(site_id, sites):
    '''
    Inputs:
    site_id: string, integer or list of strings and integers. Site IDs to be extracted. If not specified, all sites will be returned.
    sites: geopandas data frame. Containing all GBR features.
    '''
    
    #Checking the type of the input for site_name
    #If site_id is of integer type, turn to string
    if type(site_id) == int:
        site_id = str(site_id)
        #Check that site_id is 11 characters long
        if len(site_id) < 11:
            print('Site ID must be 11 characters long.')
            #Return empty site_id
            site_id = []
        else:
            #Otherwise, turn site_id into a list
            site_id = [site_id]
    #If site_id is of string type, check that it is 11 characters long    
    elif type(site_id) == str:
        if len(site_id) < 11:
            print('Site ID must be 11 characters long.')
            #Return empty site_id if not 11 characters long
            site_id = []
        else:
            #Otherwise, turn site_id into a list
            site_id = [site_id]
    #If site_id is of list type, check that all items in list are of type string
    elif type(site_id) == list:
        #Initialise empty list to store valid site IDs
        valid_id = []
        #Check every ID provided in list
        for s in site_id:
            #If item is not a string, try to change to string
            if type(s) != str:
                try:
                    s = str(s)
                    #Save item as valid ID
                    valid_id.append(s)
                except:
                    #If item cannot be changed to string, print error message
                    print(f'{s} is not a valid site ID. Site ID must be a string or an integer')
            #If item is of type string, save as valid ID
            elif type(s) == str:
                valid_id.append(s)

        #Check if items in valid_id list are 11 characters long. If not, print error message
        [print(f'{i} is not a valid ID. "site_id" must be 11 characters long') for i in valid_id if len(i) != 11]
        #Keep only items that are 11 characters long
        site_id = [i for i in valid_id if len(i) == 11]
    else:
        #If site_id is of any other time, print error message
        print(f'{site_id} is not an string, integer, or a list containing strings and integers. Check ID provided.')
        site_id = []

    #If no site_id provided are not valid, return all GBR features
    if len(site_id) == 0:
        print('Returning all GBR features.')
        true_site = []
    #If site_id provided are valid, subset GBR features by site_id
    else:
        true_site = []
        for s in site_id:
            sub = sites[sites.UNIQUE_ID == s]
            if len(sub) == 0:
                print(f'Site "{s}" does not exist. Check site ID')
            else:
                print(f'Subsetting GBR features by {s}')
                true_site.append(sub)
        #If there are no matches, an error will be raised
        if len(true_site) == 0:
            print('Site IDs given do not exist. Check site IDs, returning all GBR features.')  
            true_site = []
        else:
            #If there are matches, concatenate all dataframes in true_site list
            true_site = pd.concat(true_site)
            return true_site
        

## Getting shapefile with Great Barrier Reef features ---------------------
def gbr_features(**kwargs):
    '''
    Inputs:
    None required. This function will load all GBR features available in the s3 bucket.
    Optional:
    site_name: string. Name of the site to be extracted. If not specified, all sites will be returned.
    site_id: string. Unique ID of the site to be extracted. If not specified, all sites will be returned.
    '''

    dask_geo_df = dask_geopandas.read_parquet('s3://rimrep-data-public/gbrmpa-complete-gbr-features/data.parquet',
                                              #Specifying which columns to read
                                              columns = ['UNIQUE_ID', 'GBR_NAME', 'LOC_NAME_S', 'geometry'],
                                              #Specifying the column to be used as index
                                              index = 'fid',
                                              #Connecting anonimously as no authentication is needed for this s3 bucket (it is public)
                                              storage_options = {"anon": True}) 

    # Transforming to pandas dataframe
    sites_all = dask_geo_df.compute()

    # If optional arguments are provided, they are assigned to the corresponding variables
    if 'site_name' in kwargs.keys() and 'site_id' in kwargs.keys():
        name_sub = sub_site(kwargs.get('site_name'), sites_all)
        ids_sub = sub_id(kwargs.get('site_id'), sites_all)
        if len(name_sub) > 0 and len(ids_sub) > 0:
            sites_sub = pd.concat([name_sub, ids_sub])
        elif len(name_sub) > 0 and len(ids_sub) == 0:
            print('Site IDs given do not exist. Check site IDs, GBR features filtered by site names.')
            sites_sub = name_sub
        elif len(name_sub) == 0 and len(ids_sub) > 0:
            print('Site names given do not exist. Check site names, GBR features filtered by site IDs.')
            sites_sub = ids_sub
        else:
            print('Site names and IDs given do not exist. Check site names and IDs, returning all GBR features.')
            return sites_all
        return sites_sub
    elif 'site_name' in kwargs.keys():
        name_sub = sub_site(kwargs.get('site_name'), sites_all)
        if len(name_sub) > 0:
            return name_sub
        else:
            print('Site names given do not exist. Check site names, returning all GBR features.')
            return sites_all
    elif 'site_id' in kwargs.keys():
        ids_sub = sub_id(kwargs.get('site_id'), sites_all)
        if len(ids_sub) > 0:
            return ids_sub
        else:
            print('Site IDs given do not exist. Check site IDs, returning all GBR features.')
            return sites_all
    else:
        return sites_all