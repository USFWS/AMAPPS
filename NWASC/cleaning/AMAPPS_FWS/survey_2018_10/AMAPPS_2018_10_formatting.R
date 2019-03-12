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
load("Z:/AMAPPS/clean_data/AMAPPS_2018_10/obstrack_part1.Rdata")
obstrack = as.data.frame(obstrack)
#---------------------#


#---------------------#
# break apart obstrack
#---------------------#
#separate
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
         source_transect_id = ifelse(!is.na(source_transect_id),paste(key, source_transect_id, sep="_"),NA),
         obs_dt = as.POSIXct(paste(year, month, day, sep="/"), format="%Y/%m/%d"),
         distance_to_animal_tx = as.numeric(distance_to_animal_tx),
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 1, "1: 0-100 meters"), 
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 2, "2: 100-200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, distance_to_animal_tx %in% 3, "3: >200 meters"),
         distance_to_animal_tx = replace(distance_to_animal_tx, is.na(distance_to_animal_tx) | distance_to_animal_tx %in% 0, "0: <200 meters or unknown"),
         distance_to_animal_tx = replace(distance_to_animal_tx, !is.na(distance.to.obs),
                                         paste(distance_to_animal_tx[!is.na(distance.to.obs)], "; ",
                                               distance.to.obs[!is.na(distance.to.obs)],
                                               " (nautical mile(s))", sep=" ")),
         weather_tx = replace(weather_tx, weather_tx %in% 1, "1: worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 2, "2: bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx %in% 3, "3: average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 4, "4: good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx %in% 5, "5: excellent observation conditions"),
         behavior = ifelse(is.na(behavior) & comment %in% c("f","s","f osprey","F","S","S 75%BLSC;25%SUSC"), comment, behavior),
         behavior_id = as.character(behavior),
         behavior_id = replace(behavior_id, behavior_id %in% c("F","f","f osprey"), 13),
         behavior_id = replace(behavior_id, behavior_id %in% c("S","s","S 75%BLSC;25%SUSC"), 35),
         behavior_id = replace(behavior_id, behavior_id %in% "", 44),
         age_id = as.character(age),
         age_id = replace(age_id, age_id %in% c("adult"),1),
         age_id = replace(age_id, age_id %in% "immature",6),
         age_id = replace(age_id, age_id %in% "juvenile",2),
         age_id = replace(age_id, age_id %in% c("subadult"),7),
         age_id = replace(age_id, is.na(age_id),5),
         sex_id = 5,
         obs_position = as.character(obs_position),
         obs_position = replace(obs_position, obs_position %in% "lf","left front of aircraft"),
         obs_position = replace(obs_position, obs_position %in% "rf","right front of aircraft")) %>%
  select(-index,-age,-behavior,-flag1,-flag1b,-flag2,-flag3,-transect2,-transLat,-transLong,-transTransect,-transDist,
         -month, -day, -year,-transect.temp) %>%
  filter(!spp_cd %in% c("COCH","COMMENT"), !is.na(original.spp.codes))
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
         observer_position = replace(observer_position, observer_position %in% "rf","right front of aircraft"),
         type = ifelse(is.na(type),"WAYPNT",type)) %>%
  select(-index,-age,-behavior,-flag1,-flag2,-flag3,
         -month, -day, -year,-transect.temp,-original.spp.codes,-transect)
#---------------------#


#---------------------#
# transect
#---------------------#
transect = track %>%
  filter(type %in% c("BEGCNT","ENDCNT")) %>% 
  group_by(source_transect_id) %>% 
  summarise(temp_start_lon = first(long),
            temp_stop_lon = last(long),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(track_dt)),
            end_dt = as.character(last(track_dt)),
            start_sec = first(seconds_from_midnight_nb), 
            end_sec  = last(seconds_from_midnight_nb),
            observer_position = first(observer_position),
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% 
  as.data.frame %>% 
  arrange(start_dt, source_transect_id, observer_position)
# -------------------- #

id = 397
data = obs
data_track = track
data_transect = transect
rm(obs, track, transect)
