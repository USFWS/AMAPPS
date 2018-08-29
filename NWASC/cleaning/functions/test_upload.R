#test_upload

# packages
require(dplyr)
require(RODBC)
library(odbc)
require(ggplot2)
require(rgdal)
library(sp)

# pull data
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
datas = sqlQuery(db, paste("select * from dataset"))
ds = sqlQuery(db, paste("select dataset_id from observation"))

# test for one dataset
transects.in.db = sqlQuery(db, paste("select * from transect where dataset_id = 115"))
tracks.in.db = sqlQuery(db, paste("select * from track  where dataset_id = 115"))
obs.in.db = sqlQuery(db, paste("select * from observation where dataset_id = 115"))

# plot
# ggplot(obs.in.db, aes(temp_lon, temp_lat, col=transect_id))+geom_point()+
#   theme_bw()
# 
# ggplot()+
#   geom_point(data = tracks.in.db, aes(x = track_lon, y = track_lat, col=transect_id))+
#   theme_bw()
# 
# ggplot(obs.in.db, aes(temp_lon, temp_lat, col=transect_id))+geom_point()+
#   geom_point(data = tracks.in.db, aes(x = track_lon, y = track_lat), col="tan")+
#   geom_point(data = transects.in.db, aes(x = temp_start_lon, y = temp_start_lat), col="green")+
#   geom_point(data = transects.in.db, aes(x = temp_stop_lon, y = temp_stop_lat), col="red")+
#   theme_bw()
  
#_____________________#

# change names and numbers
obs.in.db = obs.in.db %>% rename(latitude = temp_lat, 
                                 longitude = temp_lon,
                                 obs_tm = obs_start_tm,
                                 seconds_from_midnight = seconds_from_midnight_nb,
                                 camera_reel = reel,
                                 observer_confidence =observer_confidence_tx,
                                 original_sex_tx = animal_sex_tx,
                                 original_age_tx = behavior_tx,
                                 original_behavior_tx = animal_sex_tx,
                                 associations_tx = association_tx,
                                 observer_comments = comments_tx,
                                 observer_position = obs_position,
                                 associations_tx = association_tx)

db2 <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
obs2 = dbGetQuery(db2,"select top 1 * from observation")

obs.in.db = obs.in.db[,c(names(obs.in.db)[names(obs.in.db) %in% names(obs2)],'latitude','longitude')] %>%
  mutate(obs_dt = as.Date(obs_dt,format="%m/%d/%Y"),
         obs_dt = as.character(obs_dt),
         observation_id = observation_id + 804175) %>% rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA))

# updates
source("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/updates/dataset115_updates.R")

# match column names
dummy = obs2
obs.in.db = bind_rows(dummy,obs.in.db); rm(dummy, obs2)

# classes
obs.in.db = obs.in.db %>% 
  mutate(observation_id = as.numeric(observation_id),
         source_obs_id = as.numeric(source_obs_id),
         transect_id = as.numeric(transect_id),
         dataset_id = as.numeric(dataset_id),
         #source_transect_id = as.character(source_transect_id),
         #source_dataset_id = as.character(source_dataset_id),
         obs_dt = as.character(obs_dt),
         obs_tm = as.character(obs_tm),
         original_species_tx = as.character(original_species_tx),
         spp_cd = as.character(spp_cd),
         obs_count_intrans_nb = as.numeric(obs_count_intrans_nb),
         obs_count_general_nb = as.numeric(obs_count_general_nb),
         original_age_tx = as.character(original_age_tx),
         plumage_tx = as.character(plumage_tx),
         original_behavior_tx = as.character(original_behavior_tx),
         travel_direction_tx = as.character(travel_direction_tx),
         flight_height_tx = as.character(flight_height_tx),
         distance_to_animal_tx = as.character(distance_to_animal_tx),
         angle_from_observer_nb = as.numeric(angle_from_observer_nb),
         visibility_tx = as.character(visibility_tx),
         #weather_tx = as.character(weather_tx),
         seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
         wind_speed_tx = as.character(wind_speed_tx),
         wind_dir_tx = as.character(wind_dir_tx),
         #seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
         observer_comments = as.character(observer_comments),
         original_sex_tx = as.character(original_sex_tx),
         #obs_end_tm = as.character(obs_end_tm),
         cloud_cover_tx = as.character(cloud_cover_tx),
         associations_tx = as.character(associations_tx),
         #who_created_tx = as.character(who_created_tx),
         #who_created = as.numeric(who_created),
         #date_created = as.character(date_created),
         latitude = as.numeric(latitude),
         longitude = as.numeric(longitude),
         #date_imported = as.character(date_imported),
         #who_imported = as.numeric(who_imported),
         #salinity_ppt_nb = as.numeric(salinity_ppt_nb),
         admin_notes = as.character(admin_notes),
         #platform_tx = as.character(platform_tx),
         #station_tx = as.character(station_tx),
         #survey_type = as.character(survey_type),
         heading_tx = as.character(heading_tx),
         wave_height_tx = as.character(wave_height_tx),
         observer_position = as.character(observer_position),
         #glare_tx = as.character(glare_tx),
         #whitecaps_tx = as.character(whitecaps_tx),
         #visit = as.character(visit),
         camera_reel = as.character(camera_reel),
         #datafile = as.character(datafile),
         seconds_from_midnight = as.numeric(seconds_from_midnight),
         observer_confidence = as.character(observer_confidence),
         observer_tx = as.character(observer_tx),
         behavior_id = as.numeric(behavior_id),
         age_id = as.numeric(age_id),
         sex_id = as.numeric(sex_id))

# remove geography column to create it in sql
obs.in.db = obs.in.db %>% dplyr::select(-geographyColumn)

# obs.in.db.nas = obs.in.db %>% filter(is.na(latitude) | is.na(longitude)) %>% dplyr::select(-latitude,-longitude)
# obs.in.db2 = obs.in.db %>% filter(!is.na(latitude) | !is.na(longitude))
# coordinates(obs.in.db2) = ~longitude+latitude
# proj4string(obs.in.db2) <- CRS("+init=epsg:4326")

# write to mssql 
db2 <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
dbWriteTable(conn = db2, 
             name = "obs_test", 
             value = obs.in.db,
             overwrite=TRUE) #append = true 

# from here look at the data in sql, make sure its ok, create geography and add to observation table
# use add_observations.sql
