#--------------#
# data request: A. Gilbert, June 29 2017
# all MassCEC data
# dataset ids: 135, 161, 162
#--------------#

#--------------#
# load packages
#--------------#
require(RODBC)
require(dplyr)
#--------------#


#--------------#
# get data
#--------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db = sqlFetch(db, "transect")
tracks.in.db = sqlFetch(db, "track")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
lu_spp = sqlFetch(db, "lu_species")
odbcClose(db)

# pull MassCEC data
obs = obs.in.db %>% filter(dataset_id %in% c(135,161,162)) %>% 
  dplyr::select(observation_id, transect_id, dataset_id, source_obs_id, 
                source_transect_id, source_dataset_id, obs_dt, spp_cd, obs_count_intrans_nb, 
                obs_count_general_nb, behavior_tx, weather_tx, temp_lat, temp_lon, 
                seconds_from_midnight_nb, observer_tx) %>% 
  rename(latitude = temp_lat, longitude = temp_lon) %>%
  left_join(., lu_spp, by="spp_cd") %>% dplyr::select(-species_type_cd)
track = tracks.in.db %>% filter(dataset_id %in% c(135,161,162)) %>%
  dplyr::select(-datafile, -track_gs,-piece,-seastate,-observer_position,-source_survey_id,-track_tm) %>%
  rename(latitude = track_lat, longitude = track_lon) %>% 
  mutate(point_type = ifelse(point_type %in% "BEGCNT","start",
                             ifelse(point_type %in% "ENDCNT","stop","waypoint"))) %>%
  arrange(track_id)
trans = transects.in.db %>% filter(dataset_id %in% c(135,161,162)) %>%
  dplyr::select(transect_id,dataset_id, source_transect_id, source_dataset_id, 
                start_dt, end_dt, observers_tx, temp_start_lat, temp_start_lon, 
                temp_stop_lat, temp_stop_lon, time_from_midnight_start, time_from_midnight_stop) %>%
  rename(start_latitude = temp_start_lat, start_longitude = temp_start_lon, 
         end_latitude = temp_stop_lat, end_longitude = temp_stop_lon)
dat = data.in.db %>% filter(dataset_id %in% c(135,161,162)) %>%
  dplyr::select(dataset_id, survey_type_cd, survey_method_cd, dataset_type_cd, 
                source_dataset_id, survey_width_m, abstract, 
                individual_observation_width_m, pooled_observations) %>% 
  mutate(survey_type_cd=as.character(survey_type_cd),
         survey_method_cd=as.character(survey_method_cd),
         dataset_type_cd=as.character(dataset_type_cd),
         survey_type_cd=replace(survey_type_cd, survey_type_cd %in% "a", "airplane"),
         survey_method_cd=replace(survey_method_cd,survey_method_cd %in% "cts","continuous time strip"),
         dataset_type_cd=replace(dataset_type_cd,dataset_type_cd %in% "ot","original transect"),
         pooled_observations=replace(pooled_observations,pooled_observations %in% 0,"no"))

rm(tracks.in.db,transects.in.db,obs.in.db,data.in.db,lu_spp)

# fix errors
track$point_type[track$track_id %in% 505277]="start" #double stop typo?
obs = obs[!obs$spp_cd %in% "BEGSEG",] #remove BEGSEG
#--------------#


#--------------# 
# export
#--------------#
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/AndrewGilbert_June2017_MassCEC/"
write.csv(obs, paste(dir.out, "MassCEC_observations.csv",sep="/")) 
write.csv(track, paste(dir.out, "MassCEC_track.csv",sep="/")) 
write.csv(trans, paste(dir.out, "MassCEC_transects.csv",sep="/")) 
write.csv(dat, paste(dir.out, "MassCEC_data_descriptions.csv",sep="/")) 
#--------------#
