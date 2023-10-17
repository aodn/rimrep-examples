# Installing R libraries to run rimrep-examples repository
#
# `checking_libraries` function checks that all R libraries used in the 
# rimrep-examples repository are in fact installed in your local machine. If 
# any libraries are missing, it will install them automatically.
# 

checking_libraries <- function(){
  #List of packages needed to run all notebooks in repository
  packages_required <- c("arrow", "tidyverse", "wkb", "sf", "rnaturalearth", 
                         "leaflet", "tictoc", "DT", "wordcloud2", "janitor",
                         "magrittr", "tm", "httr", "httr2", "terra", "tcltk")
  
  #Checking packages installed in local machine
  packages_local <- installed.packages()
  
  #Find if there are any packages used in repository missing in local machine
  packages_needed <- packages_required[!packages_required %in% packages_local]
  
  #If packages are missing, install them
  if(length(packages_needed)){
    print(paste0("The following packages will be installed: ", paste(packages_needed, collapse = ", ")))
    install.packages(packages_needed)
    #If no packages are missing, print message
    }else{print("All packages needed to run notebooks in this repository are available in your machine.")}
}

