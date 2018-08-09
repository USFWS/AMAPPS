# -------------------------------- #
# QA/QC NYSERDA
#
# dataset names
#   "NYSERDA_OPA_Survey1_Summer 2016" 
#   "NYSERDA_OPA_Survey2_Fall 2016"   
#   "NYSERDA_OPA_Survey3_Winter 2017"
#   "NYSERDA_OPA_Survey4_Spring 2017" 
#   "NYSERDA_WEA_Survey1_Summer 2016" 
#   "NYSERDA_WEA_Survey2_Fall 2016"  
#   "NYSERDA_WEA_Survey3_Winter 2017" 
#   "NYSERDA_WEA_Survey4_Spring 2017"
# -------------------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(rgdal) # read shapefiles
require(dplyr)
library(readxl)
require(ggplot2)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "NYSERDA"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


# -------------------------------- #
# load data 
# -------------------------------- #
data = read_excel(paste(dir.in,"Submit NWASC - NYSERDA Year1 - TargetObs.xlsx",sep="/"))
# -------------------------------- #


# -------------------------------- #
# validate species
# -------------------------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist = mutate(spplist, common_name = tolower(common_name)) %>% dplyr::select(common_name, spp_cd)

# ------- #
