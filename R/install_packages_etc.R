# just R code to install the packages needed for running the notebooks

# get the packages needed from CRAN
install.packages(
  c(
    "ape",
    "broom",
    "callr",
    "car",
    "cowplot",
    "ggsn",
    "ggspatial",
    "knitr",
    "lubridate",
    "nlme",
    "pander",
    "parallel",
    "phangorn",
    "plotly",
    "ppcor",
    "raster",
    "remotes",
    "rmarkdown",
    "rubias",
    "sessioninfo",
    "sf",
    "sjPlot",
    "tidyverse",
    "vcfR",
    "viridis",
    "zoo"
  ),
  repos = "http://cran.rstudio.com"
)

# Note that, on the cluster, since I don't have admin access,
# I needed to get the sysadmin to get rgdal installed and to 
# install libudunits2.so in order to complete the install of:
# units, rgdal, sf, rosm, lwgeom, ggsn, ggspatial



# get the packages needed from BioConductor
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", repos = "http://cran.rstudio.com")

BiocManager::install("ggtree")
BiocManager::install("treeio")


# Get package ecaRbioinf at https://github.com/eriqande/ecaRbioinf
# This is a package of useful functions by Eric C. Anderson. We
# used commit `6972defd`.  Get it like this:
remotes::install_github("eriqande/ecaRbioinf", ref = "6972defd")

