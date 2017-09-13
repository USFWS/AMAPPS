#---------------------#
# format AMAPPS winter 2014 data that was already cleaned
#---------------------#


#---------------------#
# load packages
require(dplyr)
require(gdata)
require(RODBC)
library(geosphere)
#---------------------#


#---------------------#
# set paths
surveyFolder = "AMAPPS_FWS/AMAPPS_2014_02"

dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
speciesPath <- gsub("datasets_received", "data_import/in_progress", dir)
#---------------------#


#---------------------#
# load data
online = read.csv(file.path(dir.in, "TrackFileEdit2014_Final.csv"), header = TRUE)

track = online[online$type %in% c("BEGSEG","BEGCNT","ENDSEG","ENDCNT"),]
track2 = online[as.character(online$type) %in% "",]
track2$type = "WAYPNT"
track$type = as.character(track$type)
track = bind_rows(track, track2) %>% arrange(ID) %>% select(-count)
rm(track2)

online = online[!online$type %in% c("BEGSEG","BEGCNT","ENDSEG","ENDCNT"),]
online = online[!as.character(online$type) %in% "",]
online = rename(online, obs_count_intrans_nb = count)
online$obs_count_general_nb = online$obs_count_intrans_nb

offline = read.csv(file.path(dir.in, "OfflineObs2014_Final.csv"), header = TRUE)
offline = rename(offline, obs_count_general_nb = FlockSize, type = Species, gps_error = GpsError)
offline$gps_error = as.numeric(offline$gps_error)

# combine offline and online data
colnames(online) = tolower(names(online))
colnames(offline) = tolower(names(offline))
obs = bind_rows(online, offline)
rm(online, offline)
#---------------------#


#---------------------#
# fix species
db <- odbcConnectAccess2007(file.path(speciesPath,"NWASC_temp.accdb"))
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$type

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
obs$type = as.character(obs$type)
obs$type[obs$type %in% "ALCD"] = "UNAL"
obs$type[obs$type %in% "BBGU"] = "UBBG" 
obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "DOLP"] = "UNDO"
obs$type[obs$type %in% "DUCK"] = "UNDU"
obs$type[obs$type %in% "DWSC"] = "DASC" 
obs$type[obs$type %in% "EIDE"] = "UNEI"
obs$type[obs$type %in% "GOLD"] = "UNGO" 
obs$type[obs$type %in% "GRST"] = "GRTU"
obs$type[obs$type %in% "GULL"] = "UNGU"
obs$type[obs$type %in% "LEST"] = "LETU"
obs$type[obs$type %in% "LOON"] = "UNLO"
obs$type[obs$type %in% "LOST"] = "LOTU"
obs$type[obs$type %in% "MERG"] = "UNME"
obs$type[obs$type %in% "PORP"] = "UNPO"
obs$type[obs$type %in% "SCOT"] = "UNSC"
obs$type[obs$type %in% "SEAL"] = "UNSE"
obs$type[obs$type %in% "UIST"] = "TURT"
obs$type[obs$type %in% "WHAL"] = "UNWH"
obs$type[obs$type %in% "CAGO"] = "CANG"
obs$type[obs$type %in% "GEAR"] = "FIGE"
obs$type[obs$type %in% "TRAW"] = "BOTD"
obs$type[obs$type %in% "USHO"] = "SHOR"

# get rid of COCH (code change)
obs = obs[!obs$type %in% "COCH",] 

# obs formatting
obs = rename(obs, source_transect_id = transect, seastate_beaufort_nb = condition, obs_position = seat)
obs = mutate(obs, source_transect_id = paste(source_transect_id, obs, sep="_"))
obs$obs_dt = as.POSIXct(paste(obs$year, obs$month, obs$day, sep="/"), format="%Y/%m/%d")
#---------------------#


#---------------------#
#track formating
track = rename(track, source_transect_id = transect, seastate = condition, 
               observer_position = seat, seconds_from_midnight_nb = sec, observer = obs)
track = mutate(track, source_transect_id = paste(source_transect_id, obs, sep="_"))
track$track_dt = as.POSIXct(paste(track$year, track$month, track$day, sep="/"), format="%Y/%m/%d")
track$type[track$type %in% "BEGSEG"] = "BEGCNT"
track$type[track$type %in% "ENDSEG"] = "ENDCNT"


# fix track error (in track and obs)
track$source_transect_id[track$source_transect_id %in% "343100_rms" & track$day == 7] = "343100_rms_half2"
track$source_transect_id[track$source_transect_id %in% "343100_jsw" & track$day == 7] = "343100_jsw_half2"
obs$source_transect_id[obs$source_transect_id %in% "343100_rms" & obs$day == 7] = "343100_rms_half2"
obs$source_transect_id[obs$source_transect_id %in% "343100_jsw" & obs$day == 7] = "343100_jsw_half2"
track$source_transect_id[track$source_transect_id %in% "343100_rms" & track$day == 6] = "343100_rms_half1"
track$source_transect_id[track$source_transect_id %in% "343100_jsw" & track$day == 6] = "343100_jsw_half1"
obs$source_transect_id[obs$source_transect_id %in% "343100_rms" & obs$day == 6] = "343100_rms_half1"
obs$source_transect_id[obs$source_transect_id %in% "343100_jsw" & obs$day == 6] = "343100_jsw_half1"
#---------------------#


#---------------------#
# make transects table, since each obs for one transect is technically a diff transect
transects = track %>% select(lat, long, seconds_from_midnight_nb, source_transect_id, type, observer_position, track_dt, seastate) %>% 
  filter(type %in% c("BEGCNT","ENDCNT")) %>%
  group_by(source_transect_id) %>% 
  arrange(type) %>% summarize(start_lon = first(long), start_lat = first(lat), 
                              end_lon = last(long), end_lat = last(lat),
                              time_from_midnight_start = first(seconds_from_midnight_nb), 
                              time_from_midnight_stop = last(seconds_from_midnight_nb),
                              obs_position = first(observer_position), start_dt = first(track_dt), 
                              end_dt = last(track_dt), seastate_beaufort_nb = median(seastate)) %>% rowwise %>% 
  mutate(distance =  as.numeric(distm(c(start_lat, start_lon), c(end_lat, end_lon), fun = distHaversine)),
         transect_time_min_nb = (time_from_midnight_stop - time_from_midnight_start)/60) %>% 
  as.data.frame()
#---------------------#

