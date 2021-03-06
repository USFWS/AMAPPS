# ------------ # 
# Pull AMAPPS DCCO data from last winter survey
# ------------ # 


# ------------ # 
# packages
# ------------ # 
require(RODBC)
require(dplyr)
# ------------ # 


# ------------ # 
# load data
# ------------ # 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db = sqlQuery(db, paste("select * from transect where dataset_id = 139"))
tracks.in.db = sqlQuery(db, paste("select * from track where dataset_id = 139"))
obs.in.db = sqlQuery(db, paste("select * from observation 
                               where dataset_id = 139 
                               and spp_cd = 'DCCO'"))
obs.in.db = rename(obs.in.db, longitude = temp_lon, latitude = temp_lat) %>%
  mutate(obs_count_general_nb = ifelse(!is.na(transect_id), NA, obs_count_general_nb),
         obs_count_intrans_nb = ifelse(is.na(transect_id), NA, obs_count_intrans_nb))
# ------------ # 


# ------------ # 
# formatting 
# ------------ # 
transect.list = sort(unique(obs.in.db$transect_id))
tracks.in.db = tracks.in.db %>% filter(transect_id %in% transect.list)
transects.in.db = transects.in.db %>% filter(transect_id %in% transect.list)
# ------------ # 


# ------------ # 
# export
# ------------ # 
write.csv(obs.in.db, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/SarahYates_DCCO_June2018/DCCO_AMAPPS_Jan2014.csv")
write.csv(tracks.in.db, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/SarahYates_DCCO_June2018/tracks_AMAPPS_Jan2014.csv")
write.csv(transects.in.db, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/SarahYates_DCCO_June2018/transects_AMAPPS_Jan2014.csv")
# ------------ # 


# plot
require(ggplot2)
ggplot()+geom_point(data = obs.in.db, aes(x=longitude, y=latitude, size = obs_count_intrans_nb))
