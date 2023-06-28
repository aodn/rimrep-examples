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
# def sub_site(site_name, sites):


# def sub_id(site_id, sites):

## Getting shapefile with Great Barrier Reef features ---------------------
def gbr_features(**kwargs):
    '''
    Inputs:
    None required. This function will load all GBR features available in the s3 bucket.
    Optional:
    site_name: string. Name of the site to be extracted. If not specified, all sites will be returned.
    site_id: string. Unique ID of the site to be extracted. If not specified, all sites will be returned.
    '''
    # If optional arguments are provided, they are assigned to the corresponding variables
    if 'site_name' in kwargs.keys():
        site_name = kwargs.get('site_name')
    if 'site_id' in kwargs.keys():
        site_id = kwargs.get('site_id')
    
    
    dask_geo_df = dask_geopandas.read_parquet('s3://rimrep-data-public/gbrmpa-complete-gbr-features/data.parquet',
                                              #Specifying which columns to read
                                              columns = ['UNIQUE_ID', 'GBR_NAME', 'LOC_NAME_S', 'geometry'],
                                              #Specifying the column to be used as index
                                              index = 'fid',
                                              #Connecting anonimously as no authentication is needed for this s3 bucket (it is public)
                                              storage_options = {"anon": True}) 

    # Transforming to pandas dataframe
    sites = dask_geo_df.compute()

    #Return shapefile
    return sites