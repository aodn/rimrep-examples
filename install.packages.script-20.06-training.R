# List of all required packages
packages <- c(
  "DBI", "DT", "KernSmooth", "MASS", "Matrix", "R6", "RColorBrewer", "Rcpp", "arrow", "askpass", "assertthat",
  "backports", "base64enc", "bit", "bit64", "blob", "broom", "bslib", "cachem", "callr", "cellranger", "class",
  "classInt", "cli", "clipr", "colorspace", "commonmark", "conflicted", "cpp11", "crayon", "crosstalk", "curl",
  "data.table", "dbplyr", "digest", "dplyr", "dtplyr", "e1071", "ellipsis", "evaluate", "fansi", "farver", "fastmap",
  "fontawesome", "forcats", "fs", "gargle", "generics", "ggplot2", "glue", "googledrive", "googlesheets4",
  "gridExtra", "gtable", "haven", "highr", "hms", "htmltools", "htmlwidgets", "httr", "ids", "isoband", "jquerylib",
  "jsonlite", "knitr", "labeling", "later", "lattice", "lazyeval", "leaflet", "leaflet.providers", "lifecycle",
  "lubridate", "magrittr", "markdown", "memoise", "mgcv", "mime", "modelr", "munsell", "nlme", "openssl", "pillar",
  "pkgconfig", "png", "prettyunits", "processx", "progress", "promises", "proxy", "ps", "purrr", "ragg", "rappdirs",
  "raster", "readr", "readxl", "rematch", "rematch2", "renv", "reprex", "rlang", "rmarkdown", "rnaturalearth", "pacman",
  "rstudioapi", "rvest", "s2", "sass", "scales", "selectr", "sf", "sp", "stringi", "stringr", "sys", "systemfonts",
  "terra", "textshaping", "tibble", "tictoc", "tidyr", "tidyselect", "tidyverse", "timechange", "tinytex", "tzdb",
  "units", "utf8", "uuid", "vctrs", "viridis", "viridisLite", "vroom", "withr", "wk", "wkb", "xfun", "xml2", "yaml"
)

# Install the packages if they are not already installed
installed_packages <- installed.packages()
packages_to_install <- setdiff(packages, installed_packages[, "Package"])
if (length(packages_to_install) > 0) {
  install.packages(packages_to_install)
}

# Load the packages
lapply(packages, require, character.only = TRUE)

