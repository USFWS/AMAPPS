# data checks 

#load packages
require(dplyr)
require(RODBC)
require(odbc)

# repair the date in the new data
# date
#unique(obs.in.db$obs_dt)
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs.in.db = sqlQuery(db, paste("select * from observation"))
odbcCloseAll()

x = obs.in.db[grep("/", obs.in.db$obs_dt),] %>% mutate(obs_dt = as.POSIXct(obs_dt, format="%m/%d/%Y"))
y = obs.in.db[grep("-", obs.in.db$obs_dt),] %>% mutate(obs_dt = as.POSIXct(obs_dt, format="%Y-%m-%d"))
z = obs.in.db[is.na(obs.in.db$obs_dt),]
obs.in.db = bind_rows(x,y,z) %>% arrange(observation_id) #%>% select(-who_created_tx)
  
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
obs.in.old.db = dbGetQuery(db,"select * from observation")
dbDisconnect(db)

obs.in.old.db = obs.in.old.db %>%
  rename(observer_tx = observers_tx,
         seconds_from_midnight_nb = time_from_midnight)

# format
obs.in.old.db  = obs.in.old.db  %>%
  mutate(observation_id = as.numeric(observation_id), transect_id = as.numeric(transect_id), dataset_id = as.numeric(dataset_id),
                     local_obs_id = as.numeric(local_obs_id), local_transect_id = as.numeric(local_transect_id),
                     source_obs_id = as.numeric(source_obs_id), source_transect_id = as.character(source_transect_id),
                     source_dataset_id = as.character(source_dataset_id), obs_dt = as.character(obs_dt),
                     obs_start_tm = as.character(obs_start_tm), original_species_tx = as.character(original_species_tx),
                     spp_cd = as.character(spp_cd), obs_count_intrans_nb = as.numeric(obs_count_intrans_nb),
                     obs_count_general_nb = as.numeric(obs_count_general_nb), animal_age_tx = as.character(animal_age_tx),
                     plumage_tx = as.character(plumage_tx), behavior_tx = as.character(behavior_tx),
                     travel_direction_tx = as.character(travel_direction_tx), flight_height_tx = as.character(flight_height_tx),
                     distance_to_animal_tx = as.character(distance_to_animal_tx), angle_from_observer_nb = as.numeric(angle_from_observer_nb),
                     visibility_tx = as.character(visibility_tx), weather_tx = as.character(weather_tx),
                     seastate_beaufort_nb = as.numeric(seastate_beaufort_nb), wind_speed_tx = as.character(wind_speed_tx),
                     wind_dir_tx = as.character(wind_dir_tx), seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                     comments_tx = as.character(comments_tx), animal_sex_tx = as.character(animal_sex_tx),
                     obs_end_tm = as.character(obs_end_tm), cloud_cover_tx = as.character(cloud_cover_tx),
                     association_tx = as.character(association_tx), #who_created_tx = as.character(who_created_tx),
                     who_created = as.numeric(who_created), date_created = as.character(date_created),
                     temp_lat = as.numeric(temp_lat), temp_lon = as.numeric(temp_lon), date_imported = as.character(date_imported),
                     who_imported = as.numeric(who_imported), salinity_ppt_nb = as.numeric(salinity_ppt_nb),
                     admin_notes = as.character(admin_notes), platform_tx = as.character(platform_tx),
                     station_tx = as.character(station_tx), survey_type = as.character(survey_type),
                     heading_tx = as.character(heading_tx), wave_height_tx = as.character(wave_height_tx),
                     obs_position = as.character(obs_position),  glare_tx = as.character(glare_tx),
                     whitecaps_tx = as.character(whitecaps_tx), visit = as.character(visit),
                     seconds_from_midnight_nb = as.numeric(seconds_from_midnight_nb), observer_tx = as.character(observer_tx)) 
         #reel = as.character(reel),
                     #datafile = as.character(datafile), 
                     #,
                     #observer_confidence_tx = as.character(observer_confidence_tx), 
                     #
                     #behavior_id = as.numeric(behavior_id), age_id = as.numeric(age_id), sex_id = as.numeric(sex_id))

obs.in.db  = obs.in.db  %>% 
  mutate(observation_id = as.numeric(observation_id), transect_id = as.numeric(transect_id), dataset_id = as.numeric(dataset_id),
         local_obs_id = as.numeric(local_obs_id), local_transect_id = as.numeric(local_transect_id),
         source_obs_id = as.numeric(source_obs_id), source_transect_id = as.character(source_transect_id),
         source_dataset_id = as.character(source_dataset_id), obs_dt = as.character(obs_dt),
         obs_start_tm = as.character(obs_start_tm), original_species_tx = as.character(original_species_tx),
         spp_cd = as.character(spp_cd), obs_count_intrans_nb = as.numeric(obs_count_intrans_nb),
         obs_count_general_nb = as.numeric(obs_count_general_nb), animal_age_tx = as.character(animal_age_tx),
         plumage_tx = as.character(plumage_tx), behavior_tx = as.character(behavior_tx),
         travel_direction_tx = as.character(travel_direction_tx), flight_height_tx = as.character(flight_height_tx),
         distance_to_animal_tx = as.character(distance_to_animal_tx), angle_from_observer_nb = as.numeric(angle_from_observer_nb),
         visibility_tx = as.character(visibility_tx), weather_tx = as.character(weather_tx),
         seastate_beaufort_nb = as.numeric(seastate_beaufort_nb), wind_speed_tx = as.character(wind_speed_tx),
         wind_dir_tx = as.character(wind_dir_tx), seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
         comments_tx = as.character(comments_tx), animal_sex_tx = as.character(animal_sex_tx),
         obs_end_tm = as.character(obs_end_tm), cloud_cover_tx = as.character(cloud_cover_tx),
         association_tx = as.character(association_tx), #who_created_tx = as.character(who_created_tx),
         who_created = as.numeric(who_created), date_created = as.character(date_created),
         temp_lat = as.numeric(temp_lat), temp_lon = as.numeric(temp_lon), date_imported = as.character(date_imported),
         who_imported = as.numeric(who_imported), salinity_ppt_nb = as.numeric(salinity_ppt_nb),
         admin_notes = as.character(admin_notes), platform_tx = as.character(platform_tx),
         station_tx = as.character(station_tx), survey_type = as.character(survey_type),
         heading_tx = as.character(heading_tx), wave_height_tx = as.character(wave_height_tx),
         obs_position = as.character(obs_position),  glare_tx = as.character(glare_tx),
         whitecaps_tx = as.character(whitecaps_tx), visit = as.character(visit), reel = as.character(reel),
         datafile = as.character(datafile), seconds_from_midnight_nb = as.numeric(seconds_from_midnight_nb),
         observer_confidence_tx = as.character(observer_confidence_tx), observer_tx = as.character(observer_tx),
         behavior_id = as.numeric(behavior_id), age_id = as.numeric(age_id), sex_id = as.numeric(sex_id))

# combine
# fix numbers based on data already present
obs.in.db$observation_id = obs.in.db$observation_id + 804175
min(obs.in.db$observation_id)
max(obs.in.old.db$observation_id)

combined.obs = bind_rows(obs.in.db, obs.in.old.db) %>% arrange(dataset_id, observation_id)

# # get temp_lat/long out of geometry/geography
# 
# 
# # export as spatial
# require(spatial)
# all.data = obs.in.old.db#combined.obs
# #coordinates(all.data) = ~longitude + latitude
# #proj4string(all.data) = CRS("+init=epsg:4269")
# writeOGR(all.data, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019",
#          layer = "old.obs", driver = "ESRI Shapefile")


# check spp
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spp = dbGetQuery(db, "select * from lu_species")
dbDisconnect(db)

tmp <- !combined.obs$spp_cd %in% spp$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(combined.obs$spp_cd[tmp]))
rm(spp)

combined.obs$spp_cd[combined.obs$spp_cd %in% "GULL"] = "UNGU"    
combined.obs$spp_cd[combined.obs$spp_cd %in% "HEGU"] = "HERG"   
combined.obs$spp_cd[combined.obs$spp_cd %in% "KRILL"] = "ZOOP"  
combined.obs$spp_cd[combined.obs$spp_cd %in% "LUDU"] = "LTDU"  
combined.obs$spp_cd[combined.obs$spp_cd %in% "CAGO"] = "CANG" 
combined.obs$spp_cd[combined.obs$spp_cd %in% "CRTE"] = "UCRT" # two codes for unidentified common or roseate tern, cut one  
combined.obs$spp_cd[combined.obs$spp_cd %in% "NONE"] = "UNKN"   
combined.obs$spp_cd[combined.obs$spp_cd %in% "PEEP"] = "SHOR" # removed PEEP   
combined.obs$spp_cd[combined.obs$spp_cd %in% "PHAL"] = "UNPH"   
combined.obs$spp_cd[combined.obs$spp_cd %in% "ROTE"] = "ROST" 
combined.obs$spp_cd[combined.obs$spp_cd %in% "SKUA"] = "UNSK"    
combined.obs$spp_cd[combined.obs$spp_cd %in% "TERN"] = "UNTE"   
combined.obs$spp_cd[combined.obs$spp_cd %in% "TRAW"] = "BOTD"   
combined.obs$spp_cd[combined.obs$spp_cd %in% "UMMM"] = "UNMM"    
combined.obs$spp_cd[combined.obs$spp_cd %in% "UNCT"] = "UCRT"#? or UNKN   
combined.obs$spp_cd[ combined.obs$spp_cd %in% "UNPI"] = "UNSE" # unidentified pinniped to unidentified seal (no sea lions on east coast)   
combined.obs$spp_cd[ combined.obs$spp_cd %in% "TEAL"] = "UNTL"
combined.obs$spp_cd[ combined.obs$spp_cd %in% "SURF"] = "SUSC"   
combined.obs$spp_cd[ combined.obs$spp_cd %in% "--"] = "SPDF"      
combined.obs$spp_cd[ combined.obs$spp_cd %in% "3"] = "UNSC"  
combined.obs$spp_cd[ combined.obs$spp_cd %in% "GLSP"] = "PIWH"  
combined.obs$spp_cd[ combined.obs$spp_cd %in% "MOSP"] = "UNMO"
combined.obs$spp_cd[ combined.obs$spp_cd %in% "SASP"] = "USAN"
combined.obs$spp_cd[ combined.obs$spp_cd %in% "SCRE"] = "EASO"
combined.obs$spp_cd[ combined.obs$spp_cd %in% "SPSP"] = "UNSP"  
combined.obs$spp_cd[ combined.obs$spp_cd %in% "UNPL"] = "CHAR" 
combined.obs$spp_cd[ combined.obs$spp_cd %in% c("1","12","CASP","BASW","AWSD", "COMD", 
                                                "DRSP","RODO","SHEA","SHSP","YTVI")] = "UNKN"    
   
combined.obs$spp_cd[ combined.obs$spp_cd %in% "Comment"] = "COMMENT"   
#"BEGCNT"  "BEGSEG" "COMMENT" "ENDCNT"  "TRAN"    -> should be cut/moved
     
# #write files
nonsp.comb.obs = select(combined.obs, -geography, -Geometry, -temp_lat, -temp_lon)
write.csv(nonsp.comb.obs, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/combinedObs.csv")

abbv.comb.obs = select(combined.obs, observation_id,dataset_id,longitude,latitude,spp_cd,original_species_tx,
                       obs_dt, obs_start_tm, seconds_from_midnight_nb, obs_count_general_nb, obs_count_intrans_nb)
write.csv(abbv.comb.obs, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/abbvCombinedObs.csv")

write.csv(spp, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/speciesList.csv")

db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
datasets = dbGetQuery(db, "select * from dataset")
dbDisconnect(db)
write.csv(datasets, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/datasetList.csv")

# ------------------ #

# effort
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
tracks.in.db = sqlQuery(db, paste("select * from track"))
transects.in.db = sqlQuery(db, paste("select * from transect"))
odbcCloseAll()

db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
effort.in.old.db = dbGetQuery(db,"select * from all_effort")
dbDisconnect(db)

new.dataset_id = sort(unique(effort.in.old.db$dataset_id))
new.effort = filter(tracks.in.db, !dataset_id %in% new.dataset_id) %>% 
  rename(start_tm = track_tm,
         latitude = track_lat,
         longitude = track_lon,
         comments_tx = comment,
         observers_tx = observer,
         seastate_beaufort_nb = seastate) %>% 
  mutate(track_id = track_id+2888973, # adding since old and new numbers were not in sequence - since old tracks didnt have #s only transects did
         start_dt = as.POSIXct(track_dt, format="%m/%d/%Y"),
         start_dt = as.character(start_dt),
         track_id = as.integer(track_id),     
         start_tm = as.character(start_tm), 
         latitude = as.double(latitude),
         longitude = as.double(longitude),
         point_type = as.character(point_type),
         source_survey_id = as.character(source_survey_id), 
         source_transect_id = as.character(source_transect_id), 
         observer_position = as.character(observer_position), 
         observers_tx = as.character(observers_tx), 
         offline = as.integer(offline),   
         seastate_beaufort_nb = as.character(seastate_beaufort_nb),
         comments_tx = as.character(comments_tx), 
         transect_id = as.character(transect_id),#transect_id = as.integer(transect_id), 
         dataset_id = as.character(dataset_id), #dataset_id = as.integer(dataset_id), 
         #track_gs = as.character(track_gs), 
         #piece = as.integer(piece),  
         source_track_id = as.double(source_track_id),
         seconds_from_midnight_nb = as.integer(seconds_from_midnight_nb),
         datafile = as.character(datafile)) %>% 
  select(-track_dt,-datafile,-piece,-track_gs)

new.tracks = bind_rows(effort.in.old.db, new.effort)
rm(new.effort,new.dataset_id)

write.csv(new.tracks, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/combinedTracks.csv")
# checks
#x = new.tracks[is.na(new.tracks$latitude),] # ~100 which is fine
#x = new.tracks[grep("/", new.tracks$start_dt),] # none


# transects
new.dataset_id = sort(unique(transects.in.db$dataset_id))
new.effort = filter(new.tracks, !dataset_id %in% new.dataset_id) 
old.transects = new.effort %>% 
  rename(obs_position = observer_position) %>%
  group_by(transect_id) %>%
  arrange(start_dt, start_tm, seconds_from_midnight_nb) %>%
  summarize(start_dt = first(start_dt),
            start_tm = first(start_tm),
            end_dt = last(end_dt),
            end_tm = last(end_tm),
            source_transect_id = first(source_transect_id),
            dataset_id = first(dataset_id), 
            #source_dataset_id = first(source_dataset_id), 
            transect_time_nb = NA, 
            transect_distance_nb = NA, 
            traversal_speed_nb = NA, 
            observers_tx = first(observers_tx), 
            obs_position = first(obs_position), 
            weather_tx = NA, 
            seastate_beaufort_nb = NA, 
            wind_speed_tx = NA, 
            wind_dir_tx = NA, 
            comments_tx = NA, 
            conveyance_name_tx = first(conveyance_name_tx),
            heading_tx = NA, 
            wave_height_tx = NA, 
            whole_transect = first(whole_transect),
            time_from_midnight_stop = last(seconds_from_midnight_nb),
            time_from_midnight_start = first(seconds_from_midnight_nb),
            temp_start_lat = first(latitude),           
            temp_start_lon = first(longitude),                 
            temp_stop_lat = last(latitude),                  
            temp_stop_lon = last(longitude)) %>% 
  mutate(transect_id = as.numeric(transect_id)) %>%
  arrange(transect_id)

old.transects = old.transects %>% mutate(transect_id = as.numeric(transect_id),
                                       dataset_id = as.numeric(dataset_id),
                                       source_transect_id = as.character(source_transect_id),
                                       #source_dataset_id = as.character(source_dataset_id),
                                       start_dt = as.character(start_dt),
                                       start_tm = as.character(start_tm),
                                       end_dt = as.character(end_dt),
                                       end_tm = as.character(end_tm),
                                       #transect_time_min_nb = as.numeric(transect_time_min_nb),
                                       transect_distance_nb = as.numeric(transect_distance_nb),
                                       traversal_speed_nb = as.numeric(traversal_speed_nb),
                                       #transect_width_nb = as.numeric(transect_width_nb),
                                       observers_tx = as.character(observers_tx),
                                       #visability_tx = as.character(visability_tx),
                                       weather_tx = as.character(weather_tx),
                                       seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                                       wind_speed_tx = as.character(wind_speed_tx),
                                       wind_dir_tx = as.character(wind_dir_tx),
                                       #seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                                       comments_tx = as.character(comments_tx),
                                       #track_gs = as.character(track_gs),
                                       conveyance_name_tx = as.character(conveyance_name_tx),
                                       heading_tx = as.character(heading_tx),
                                       wave_height_tx = as.character(wave_height_tx),
                                       #spatial_type_tx = as.character(spatial_type_tx),
                                       #who_created = as.character(who_created),
                                       #date_created = as.character(date_created),
                                       #utm_zone = as.character(utm_zone),
                                       whole_transect = as.character(whole_transect),
                                       #local_transect_id = as.character(local_transect_id),
                                       #who_imported = as.character(who_imported),
                                       temp_start_lat = as.numeric(temp_start_lat),
                                       temp_start_lon = as.numeric(temp_start_lon),
                                       temp_stop_lat = as.numeric(temp_stop_lat),
                                       temp_stop_lon = as.numeric(temp_stop_lon),
                                       obs_position = as.character(obs_position),
                                       #visit = as.character(visit),
                                       time_from_midnight_start = as.character(time_from_midnight_start),
                                       time_from_midnight_stop = as.character(time_from_midnight_stop))
                                       #date_imported = as.character(date_imported),
                                       #local_survey_id = as.character(local_survey_id),
                                       #local_transect_id2 = as.character(local_transect_id2),
                                       #survey_type = as.character(survey_type),
                                       #datafile = as.character(datafile),
                                       #altitude_nb_m = as.numeric(altitude_nb_m))

transects.in.db = transects.in.db %>% 
  mutate(transect_id = as.numeric(transect_id),
         dataset_id = as.numeric(dataset_id),
         source_transect_id = as.character(source_transect_id),
         start_dt = as.POSIXct(start_dt, format="%m/%d/%Y"),
         start_dt = as.character(start_dt),
         start_tm = as.character(start_tm),
         end_dt = as.character(end_dt),
         end_tm = as.character(end_tm),
         transect_distance_nb = as.numeric(transect_distance_nb),
         traversal_speed_nb = as.numeric(traversal_speed_nb),
         observers_tx = as.character(observers_tx),
         weather_tx = as.character(weather_tx),
         seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
         wind_speed_tx = as.character(wind_speed_tx),
         wind_dir_tx = as.character(wind_dir_tx),
         comments_tx = as.character(comments_tx),
         conveyance_name_tx = as.character(conveyance_name_tx),
         heading_tx = as.character(heading_tx),
         wave_height_tx = as.character(wave_height_tx),
         whole_transect = as.character(whole_transect),
         temp_start_lat = as.numeric(temp_start_lat),
         temp_start_lon = as.numeric(temp_start_lon),
         temp_stop_lat = as.numeric(temp_stop_lat),
         temp_stop_lon = as.numeric(temp_stop_lon),
         obs_position = as.character(obs_position),
         time_from_midnight_start = as.character(time_from_midnight_start),
         time_from_midnight_stop = as.character(time_from_midnight_stop))

combinedTransects = bind_rows(old.transects, transects.in.db) %>% 
  arrange(transect_id)
  
write.csv(combinedTransects, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_export/Arliss_March2019/combinedTransects.csv")

