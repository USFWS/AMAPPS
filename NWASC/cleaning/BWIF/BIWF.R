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
data = read_excel(paste(dir.in,"2016-11-09_BIWF OFFSHORE AVIAN DATA 0709 - 0610.xls",sep="/"))
hd.data = read_excel(paste(dir.in,"2016-11-09_BIWF Full Year HD Aerial Data.xlsx",sep="/"), 
                     sheet = "12 month HD data Avian Only")
ons.data = odbcConnectExcel2007(paste(dir.in,"2016-11-09_BIWF ONS 0709 - 0610.xlsx",sep="/"))
on.avian = sqlFetch(ons.data, "DATA - ONSHORE AVIAN")
on.weather = sqlFetch(ons.data, "ONSHORE WEATHER")
on.pt = sqlFetch(ons.data, "PT-Weather Avgs")
on.cormmet = sqlFetch(ons.data, "Corm and Met")
on.dist = sqlFetch(ons.data, "Data for Distance")
odbcCloseAll()
rm(ons.data)

bat.data = read_excel(paste(dir.in,"2016-11-09_BIWF BATS SUMMER 2009.xls",sep="/"))                                                                                                                               
bio.data = read_excel(paste(dir.in,"2016-11-09_BIWF Biological Survey Data Summer Fall 2009 Tt.xls",sep="/"))                                                                                                     
#metadata = read.table(paste(dir.in,"2016-11-09_BIWF_AvianBat_MetaData.xlsx",sep="/"))                                                                                                                             
raptor.data = read_excel(paste(dir.in,"2018-11-09_BIWF RAPTOR DATA 2009 - 2010.xls",sep="/"))                                                                                                                    

bat.pt = readOGR(dir.in,'BIWF_Offshore_Active_Bat_Sampling_Point') # this is where the active bat sampling point locations are offshore
bat.trans = readOGR(dir.in,'BIWF_Offshore_Active_Bat_Sampling_Transect') # just Id, Transect, and line segment
hd.trans = readOGR(dir.in,'BIWF_Offshore_Aerial_HD_Video_Strip_Transects')
trans.segs = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transect_Segments')
trans = readOGR(dir.in,'BIWF_Offshore_Boat-Based_Avian_Survey_Transects')

#radar.merlin = readOGR(dir.in,'BIWF_MERLIN_Radar_Location')
#radar.vesper = readOGR(dir.in,'BIWF_VESPER_Radar_Location')
#radar.ns = readOGR(dir.in,'BIWF_MERLIN_Radar_Nearshore_VSR')
#radar.off = readOGR(dir.in,'BIWF_MERLIN_Radar_Offshore_HSR')
#radar.on = readOGR(dir.in,'BIWF_MERLIN_Radar_Onshore_VSR')
#bat.pt.on = readOGR(dir.in,'BIWF_Onshore_Active_Bat_Sampling_Points')
#avian.on.mon.pt = readOGR(dir.in,'BIWF_Onshore_Avian_Acoustic_Monitoring_Points')
#bat.on.trans = readOGR(dir.in,'BIWF_Onshore_Bat_Survey_Transects')
#bat.on.pass = readOGR(dir.in,'BIWF_Onshore_Passive_Bat_Sampling_Points')
#raptor.on = readOGR(dir.in,'BIWF_Onshore_Raptor_Migration_Survey_Points')
#avian.on.cov = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Coverage')
#avian.on.surv.pt = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Points')
# -------------------------------- #


# -------------------------------- #
# fix and format
# -------------------------------- #
names(on.avian) = gsub(" ", "", names(on.avian), fixed = TRUE)
on.avian = on.avian %>%
  rename(count = '#') %>% 
  mutate(original_species_code = paste(SPECIESNAME, SPECIESCODE, sep = "; "),
         lat = NA, 
         lon = NA, 
         lat = ifelse(POINT == 1, 41.200012, lat),
         lon = ifelse(POINT == 1, -71.574038, lon),
         lat = ifelse(POINT == 2, 41.189686, lat),
         lon = ifelse(POINT == 2, -71.566494, lon),
         lat = ifelse(POINT == 3, 41.172362, lat),
         lon = ifelse(POINT == 3, -71.554446, lon),
         lat = ifelse(POINT == 4, 41.165931, lat),
         lon = ifelse(POINT == 4, -71.59296, lon),
         lat = ifelse(POINT == 5, 41.152282, lat),
         lon = ifelse(POINT == 5, -71.552535, lon),
         lat = ifelse(POINT == 7, 41.151212, lat),
         lon = ifelse(POINT == 7, -71.558179, lon),
         lat = ifelse(POINT == 6, 41.151704, lat),
         lon = ifelse(POINT == 6, -71.555504, lon),
         lat = ifelse(POINT == 8, 41.148526, lat),
         lon = ifelse(POINT == 8, -71.575857, lon),
         lat = ifelse(POINT == 9, 41.147455, lat),
         lon = ifelse(POINT == 9, -71.590879, lon),
         lat = ifelse(POINT == 10, 41.151666, lat),
         lon = ifelse(POINT == 10, -71.608702, lon),
         DISTANCE = ifelse(DISTANCE %in% 1, "0 - 500 m", ifelse(DISTANCE %in% 2, "500 - 1500 m", "1500 - 3000 m")), 
         admin_notes= "Latitude and Longitude estimated based on report map",
         STARTTIME = format(on.avian$STARTTIME, format = "%H:%M:%S"), 
         ENDTIME = format(on.avian$ENDTIME, format = "%H:%M:%S"),
         OBSTIME = format(on.avian$OBSTIME, format = "%H:%M:%S"))
# -------------------------------- #


# -------------------------------- #
# fix species
# -------------------------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist = mutate(spplist, common_name = tolower(common_name)) %>% filter(common_name, spp_cd)

on.avian = left_join(on.avian, spplist, by = c("SPECIESNAME" = "common_name")) 
# -------------------------------- #

