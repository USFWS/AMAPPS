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

ofs.data = odbcConnectExcel2007(paste(dir.in,"4.5 BIWF_Tables_OFS_PHYLO.xlsx",sep="/"))
ofs.avian = sqlFetch(ofs.data, "OFFSHORE AVIAN")

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
avian.on.surv.pt = readOGR(dir.in,'BIWF_Onshore_Sea_Watch_Avian_Survey_Points')
# -------------------------------- #


# -------------------------------- #
# fix and format
# -------------------------------- #
names(on.avian) = gsub(" ", "", names(on.avian), fixed = TRUE)
on.avian = on.avian %>%
  rename(count = '#') %>% 
  mutate(original_species_code = paste(SPECIESNAME, SPECIESCODE, sep = "; "),
         SPECIESNAME = tolower(SPECIESNAME),
          DISTANCE = ifelse(DISTANCE %in% 1, "0 - 500 m", ifelse(DISTANCE %in% 2, "500 - 1500 m", "1500 - 3000 m")), 
         STARTTIME = format(on.avian$STARTTIME, format = "%H:%M:%S"), 
         ENDTIME = format(on.avian$ENDTIME, format = "%H:%M:%S"),
         OBSTIME = format(on.avian$OBSTIME, format = "%H:%M:%S"))

avian.on.surv.pt = spTransform(avian.on.surv.pt, CRS("+proj=longlat +datum=WGS84")) #change projection
avian.on.surv.pt = as.data.frame(avian.on.surv.pt) %>% rename(lat = coords.x2, lon = coords.x1)

on.avian = left_join(on.avian, dplyr::select(avian.on.surv.pt, Point, lat, lon), by = c("POINT" = "Point"))
rm(avian.on.surv.pt)
# ------- #

# ------- #
names(ofs.avian) = gsub(" ", "", names(ofs.avian), fixed = TRUE)
ofs.avian = ofs.avian %>%
  rename(count = '#') %>% 
  mutate(original_species_code = paste(SPECIESNAME, SPECIESCODE, sep = "; "),
         SPECIESNAME = tolower(SPECIESNAME),
         DISTANCE = ifelse(DISTANCE %in% 1, "0 - 500 m", ifelse(DISTANCE %in% 2, "500 - 1500 m", "1500 - 3000 m")), 
         STARTTIME = format(STARTTIME, format = "%H:%M:%S"), 
         ENDTIME = format(ENDTIME, format = "%H:%M:%S"),
         OBSTIME = format(on.avian$OBSTIME, format = "%H:%M:%S"),
         Time = format(Time, format = "%H:%M:%S"))
# ------- #
# -------------------------------- #


# -------------------------------- #
# fix species
# -------------------------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist = mutate(spplist, common_name = tolower(common_name)) %>% dplyr::select(common_name, spp_cd)

# ------- #
on.avian = left_join(on.avian, spplist, by = c("SPECIESNAME" = "common_name")) %>%
  mutate(spp_cd = replace(spp_cd, original_species_code %in% "American golden-plover; AMGP","AMGP"),
         spp_cd = replace(spp_cd, original_species_code %in% "Unidentified accipiter; UNAC", "UAHA"),
         spp_cd = replace(spp_cd, original_species_code %in% "Unidentified Larus gull; ULGU","UNGU")) %>% 
  dplyr::select(-SPECIESCODE, -SPECIESNAME, -MONTH)
# ------- #

# ------- #
ofs.avian = left_join(ofs.avian, spplist, by = c("SPECIESNAME" = "common_name")) %>%
  mutate(spp_cd = replace(spp_cd, original_species_code %in% "American golden-plover; AMGP","AMGP"),
         spp_cd = replace(spp_cd, original_species_code %in% "Unidentified accipiter; UNAC", "UAHA"),
         spp_cd = replace(spp_cd, original_species_code %in% "Unidentified Larus gull; ULGU","UNGU")) %>% 
  dplyr::select(-SPECIESCODE, -SPECIESNAME, -MONTH)
# ------- #
# -------------------------------- #


# -------------------------------- #
# effort
# -------------------------------- #
on.avian.transect = on.avian %>% group_by(POINT, DATE) %>% 
  summarize(start_time = first(STARTTIME), end_time = first(ENDTIME),
            start_lat = first(lat), end_lat = first(lat),
            start_lon = first(lon), end_lon = first(lon))

# ------- #
# ofs.avian.transect 
# trans
# trans.segs
trans.segs2 = spTransform(trans.segs, CRS("+proj=longlat +datum=WGS84")) #change projection
trans.segs2 = as.data.frame(trans.segs2) 

# -------------------------------- #
