#---------------------#
# format AMAPPS fall 2013 data that was already cleaned
#---------------------#


#---------------------#
# load packages
#---------------------#
require(dplyr) # %>% 
require(zoo) # na.locf
require(geosphere) # distVincentySphere
#---------------------#


#---------------------#
# set paths
#---------------------#
surveyFolder = "AMAPPS_FWS/AMAPPS_2013_09"

dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
#---------------------#


#---------------------#
# load data
#---------------------#
load(paste(dir.in,"obstrack_final.Rdata",sep="/")) # use csv if workspace corrupt
rm(shapefileDataframe, track.final)
#---------------------#


#---------------------#
# get rid of COCH (code change)
#---------------------#
trackTbl = trackTbl[!trackTbl$type %in% "COCH",] 
#---------------------#


#---------------------#
# obs formatting
#---------------------#
obsTbl = obsTbl %>% 
  rename(source_transect_id = transect, 
         obs_position = seat,
         observer_tx = obs,
         seconds_from_midnight_nb = Time_secs,
         spp_cd = SpeciesId, 
         temp_lat = latitude_dd, 
         temp_lon = longitude_dd, 
         source_obs_id = ID) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(source_transect_id, observer_tx, sep="_"),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         surveyband = as.numeric(surveyband),
         distance_to_animal_tx = surveyband,
         distance_to_animal_tx = replace(distance_to_animal_tx, is.na(distance_to_animal_tx), surveyband[is.na(distance_to_animal_tx)]),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==1, "1: 0-100 meters"), 
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==2, "2: 100-200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==3, "3: >200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==0, "0: <200 meters or unknown")) %>%
  select(-index)
#---------------------#


#---------------------#
# track formating
#---------------------#
trackTbl = trackTbl %>%
  rename(source_transect_id = transect, observer_position = seat, seconds_from_midnight_nb = sec, 
         observer = obs, source_track_id = ID, observer = obs) %>%
  mutate(source_transect_id = paste(source_transect_id, observer, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT"))
#---------------------#


#---------------------#
# transect formating
#---------------------#
transectTbl = transectTbl %>% 
  mutate(source_transect_id = paste(transect, obs, sep="_")) %>%
  rename(observers_tx = obs,
         obs_position = seat) %>% 
  select(-transect, -AvgCondition, -key)
#---------------------#


