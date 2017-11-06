# -------------------------------- #
# QA/QC Deepwater Wind Block Island
# -------------------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(rgdal) # read shapefiles
require(dplyr)
library(readxl)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "BIWF"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


# -------------------------------- #
# load boat data and transects
# -------------------------------- #
track = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transects')
track_segments = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transect_Segments')
#onshore_avian_survey_coverage = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Coverage')
#onshore_avian_survey_points = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Points')
hd_track = readOGR(dir.in,'BIWF_Offshore_Aerial_HD_Video_Strip_Transects')

data = read_excel(paste(dir.in,"2016-11-09_BIWF OFFSHORE AVIAN DATA 0709 - 0610.xls",sep="/"))
hd_data = read_excel(paste(dir.in,"2016-11-09_BIWF Full Year HD Aerial Data.xlsx",sep="/"))
#ons_data = read.table(paste(dir.in,"2016-11-09_BIWF ONS 0709 - 0610",sep="/"),header="TRUE")
# -------------------------------- #


# -------------------------------- #
# fix species
# -------------------------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

# -------------------------------- #


# -------------------------------- #
# camera data
# -------------------------------- #
