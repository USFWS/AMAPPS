#---------------------#
# format AMAPPS fall 2014 data that was already cleaned
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
surveyFolder = "AMAPPS_FWS/AMAPPS_2014_10"

dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
#---------------------#


#---------------------#
# load data
#---------------------#
track = read.csv(file.path(dir.in, "AMAPPS_2014_10_Tracks.csv"), header = TRUE)
obs = read.csv(file.path(dir.in, "AMAPPS_2014_10_Observations.csv"), header = TRUE)
#---------------------#


#---------------------#
# get rid of COCH (code change)
#---------------------#
track = track[!track$type %in% "COCH",] 
#---------------------#


#---------------------#
# obs formatting
#---------------------#
obs = obs %>% 
  rename(source_transect_id = transect, obs_position = seat, seconds_from_midnight_nb = Time_secs,
         spp_cd = SpeciesId, temp_lat = latitude_dd, temp_lon = longitude_dd, source_obs_id = ID) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(source_transect_id, obs, day, sep="_"),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         surveyband = as.numeric(surveyband),
         distance_to_animal_tx = surveyband,
         distance_to_animal_tx = replace(distance_to_animal_tx, is.na(distance_to_animal_tx), surveyband[is.na(distance_to_animal_tx)]),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==1, "1: 0-100 meters"), 
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==2, "2: 100-200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==3, "3: >200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, surveyband==0, "0: <200 meters or unknown"),
         distance_to_animal_tx = replace(distance_to_animal_tx, !is.na(distance.from.observer),
                                         paste(distance_to_animal_tx[!is.na(distance.from.observer)], "; ",
                                               distance.from.observer[!is.na(distance.from.observer)],
                                               " (meter(s) or nautical mile(s) if not specified)", sep=" "))) %>%
  select(-index)
obs = obs %>% mutate(behavior = as.character(behavior),
                     behavior = replace(behavior,behavior=="swimming","sitting")) # need to correct in post.gis script
#---------------------#


#---------------------#
# track formating
#---------------------#
track = track %>%
  rename(source_transect_id = transect, observer_position = seat, seconds_from_midnight_nb = sec, 
         observer = obs, source_track_id = ID, observer = obs) %>%
  mutate(source_transect_id = paste(source_transect_id, observer, day, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT"))
#---------------------#


#---------------------#
# Redo transect table for each piece rather than each transect
#---------------------#
# bind track and obs
a = obs %>% select(source_transect_id, source_obs_id, obs_dt, seconds_from_midnight_nb, temp_lon, 
                   temp_lat, spp_cd, ConditionCode, obs_position, obs) %>%
  rename(date = obs_dt, long = temp_lon, lat = temp_lat, type = spp_cd, 
         condition = ConditionCode, ID = source_obs_id, seat = obs_position, observer = obs)
b = track %>% select(source_transect_id, source_track_id, track_dt, seconds_from_midnight_nb, long, 
                   lat, type, condition, observer_position, observer) %>%
  rename(date = track_dt, ID = source_track_id, seat = observer_position)
track.final = bind_rows(a, b) %>% arrange(ID) %>% filter(!type %in% "WAYPNT")
rm(a,b)

# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(track.final, type %in% c("BEGCNT")) %>%
  group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(source_transect_id, ID, start.stop.index)
new.key = left_join(track.final, break.at.each.stop, by=c("ID","source_transect_id")) %>% 
  mutate(start.stop.index = na.locf(start.stop.index), 
         newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% select(-start.stop.index)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(long, default = last(long), order_by = ID),
         lagged.lat = lead(lat, default = last(lat), order_by = ID)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(long, lat), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>% 
  mutate(condition = replace(condition, condition==0, NA)) %>%
  group_by(newkey) %>%  
  summarise(observer_position = first(seat),
            observer = first(observer),
            source_transect_id = first(source_transect_id),
            AvgCondition = as.numeric(weighted.mean(condition, distance, na.rm=TRUE)), 
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(long),
            temp_stop_lon = last(long),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_sec = first(seconds_from_midnight_nb), 
            end_sec  = last(seconds_from_midnight_nb),
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id, observer_position)

# group by old key
transect = df %>% group_by(source_transect_id) %>%
  summarise(observer_position = first(observer_position),
            observer = first(observer),
            AvgCondition = as.numeric(weighted.mean(AvgCondition, transect_distance_nb, na.rm=TRUE)), 
            transect_distance_nb = sum(transect_distance_nb),
            start_dt = first(start_dt),
            end_dt = last(end_dt),
            temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            start_dt = start_dt[row_number()==1],
            end_dt = end_dt[row_number()==1],
            time_from_midnight_start = first(start_sec),
            time_from_midnight_stop = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb)) %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id, observer_position) %>%
  mutate(weather_tx = round(AvgCondition),
         weather_tx = replace(weather_tx, weather_tx==1, "1: worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==2, "2: bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx==3, "3: average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==4, "4: good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==5, "5: excellent observation conditions"),
         weather_tx = replace(weather_tx,weather_tx=="NaN",NA),
         observer_position = as.character(observer_position), 
         observer_position = replace(observer_position,observer_position=="lf","left front of aircraft"),
         observer_position = replace(observer_position,observer_position=="rf","right front of aircraft")) %>%
  select(-AvgCondition)


rm(break.at.each.stop, df, new.key, track.final)    
# -------------------- #

