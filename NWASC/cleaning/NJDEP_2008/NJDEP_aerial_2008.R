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
dat.effort <- readOGR(dsn=fgdb,layer="AerialApr2008Bird")
dat.obs <- readOGR(dsn=fgdb,layer="AvianSurveySightings") # only boat data, check if all was put in, including Supplemental
dat.boats <- readOGR(dsn=fgdb,layer="Commercial_Vessels_Aerial") #might need to add these data
dat.mm <- readOGR(dsn=fgdb,layer="MammalTurtleSightings_CompleteAerialSurveyData") #might need to add
#dat.obs <- readOGR(dsn=fgdb,layer="ESM_Avian") # environmental sensitivity index map
#dat.obs <- readOGR(dsn=fgdb,layer="AerialApr2008oneffort") # not the right line pattern

# fauna geodatabase
# fgdb <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/NewJerseyDEP/GIS/Layers/fauna.zip/fauna.gdb"
# 
# # List all feature classes in a file geodatabase
# subset(ogrDrivers(), grepl("GDB", name))
# fc_list <- ogrListLayers(fgdb)
# print(fc_list)
# -------------- #


# -------------- #
# format
# -------------- #
# -------------- #
