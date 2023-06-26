#Function checking that all packages used in repository are installed
checking_libraries <- function(){
  #List of packages needed to run all notebooks in repository
  packages_required <- c("arrow", "tidyverse", "wkb", "sf", "rnaturalearth", "leaflet", "tictoc", "DT")
  
  #Checking packages installed in local machine
  packages_local <- installed.packages()
  
  #Find if there are any packages used in repository missing in local machine
  packages_needed <- packages_required[!packages_required %in% packages_local]
  
  #If packages are missing, install them
  if(length(packages_needed)){
    install.packages(packages_needed)
    #If no packages are missing, print message
    }else{print("All packages needed to run notebooks in this repository are available in your machine.")}
}

