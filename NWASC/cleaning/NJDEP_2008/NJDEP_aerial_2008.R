# -------------- #
# NJDEP 2008 aerial bird survey (https://www.nj.gov/dep/dsr/ocean-wind/report.htm)
# -------------- #

# -------------- #
# packages
# -------------- #
require(odbc)
require(RODBC)
require(dplyr)
require(rgdal)
# -------------- #

# -------------- #
# data
# -------------- #
# raw data
fgdb <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/NewJerseyDEP/GIS/Layers/NJDEP Layers.gdb"

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)
print(fc_list)

# Read the feature class
dat <- readOGR(dsn=fgdb,layer="AerialApr2008Bird")

# Determine the FC extent, projection, and attribute information
summary(dat)

# View the feature class
plot(dat)
