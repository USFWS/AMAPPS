#---------------------#
# load packages
#---------------------#
require(dplyr) # %>% 
require(zoo) # na.locf
require(geosphere) # distVincentySphere
#---------------------#


#---------------------#
# load data
#---------------------#
load("Z:/AMAPPS/clean_data/AMAPPS_2018_08/obstrack_part1.Rdata")
obstrack = as.data.frame(obstrack)
#---------------------#


#---------------------#
# break apart obstrack
#---------------------#
obs = filter(obstrack, !is.na(type), !type %in% c("BEGCNT","ENDCNT"))
track = filter(obstrack, type %in% c("BEGCNT","ENDCNT") | is.na(type))

# add offline counts from transit
x = filter(transit, !is.na(type), !type %in% c("COCH","COMMENT")) %>% 
  mutate(transect = NA) # there were a few offline counts with transects - removed transects
obs = bind_rows(obs, x)
rm(x, obstrack, transit)
#---------------------#


#---------------------#
# obs formatting
#---------------------#
obs = obs %>% 
  rename(source_transect_id = transect, 
         obs_position = seat, 
         seconds_from_midnight_nb = sec,
         spp_cd = type, 
         temp_lat = lat, 
         temp_lon = long, 
         source_obs_id = ID,
         distance_to_animal_tx = band,
         weather_tx = condition) %>%
  mutate(original_species_tx = spp_cd, 
         source_transect_id = paste(key, source_transect_id, sep="_"),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         distance_to_animal_tx = as.numeric(distance_to_animal_tx),
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 1, "1: 0-100 meters"), 
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 2, "2: 100-200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 3, "3: >200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, is.na(distance_to_animal_tx) | distance_to_animal_tx %in% 0, "0: <200 meters or unknown"),
         distance_to_animal_tx = replace(distance_to_animal_tx, !is.na(distance_from_observer),
                                         paste(distance_to_animal_tx[!is.na(distance_from_observer)], "; ",
                                               distance_from_observer[!is.na(distance_from_observer)],
                                               " (nautical mile(s))", sep=" ")),
         weather_tx = replace(weather_tx, weather_tx %in% 1, "1: worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 2, "2: bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx %in% 3, "3: average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 4, "4: good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 5, "5: excellent observation conditions"),
         behavior = ifelse(is.na(behavior) & comment %in% c("f","s"), comment, behavior),
         behavior_id = as.character(behavior),
         behavior_id = replace(behavior_id, behavior_id %in% "f", 13),
         behavior_id = replace(behavior_id, behavior_id %in% "s", 35),
         behavior_id = replace(behavior_id, behavior_id %in% "", 44),
         age_id = as.character(age),
         age_id = replace(age_id, age_id %in% "adult",1),
         age_id = replace(age_id, age_id %in% "immature",6),
         age_id = replace(age_id, age_id %in% "juvenile",2),
         age_id = replace(age_id, age_id %in% "subadult",7),
         age_id = replace(age_id, is.na(age_id),5),
         sex_id = 5,
         obs_position = as.character(obs_position),
         obs_position = replace(obs_position, obs_position %in% "lf","left front of aircraft"),
         obs_position = replace(obs_position, obs_position %in% "rf","right front of aircraft")) %>%
  select(-index,-age,-behavior,-flag1,-flag1b,-flag2,-flag3,-transect2,-transLat,-transLong,-transTransect,-transDist,
         -month, -day, -year,-transect.temp) %>%
  filter(!spp_cd %in% "COCH")
#---------------------#


#---------------------#
# track formating
#---------------------#
track = track %>%
  rename(observer_position = seat, 
         seconds_from_midnight_nb = sec, 
         observer = obs, 
         source_track_id = ID, 
         observer = obs) %>%
  mutate(observer_position = as.character(observer_position),
         source_transect_id = paste(key, transect, sep="_"),
         track_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         observer_position = replace(observer_position, observer_position %in% "lf","left front of aircraft"),
         observer_position = replace(observer_position, observer_position %in% "rf","right front of aircraft")) %>%
  select(-index,-age,-behavior,-flag1,-flag1b,-flag2,-flag3,-transect2,-transLat,-transLong,-transTransect,-transDist,
         -month, -day, -year,-transect.temp,-original.spp.codes)
#---------------------#


#---------------------#
# transect
#---------------------#
transect = track 

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

# -------------------- #

id = 
data = obs
data_track = track
data_transect = transect
rm(obs, track, transect)
