# -------------- #
# packages
# -------------- #
library(readxl)
require(RODBC)
require(odbc)
require(dplyr)
require(rgdal)
require(ggplot2)
# -------------- #


# -------------- #
# data
# -------------- #
# old data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
old.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, * from observation 
                     where spp_cd in ('PIPL','REKN','ROST','ROTE')")
dbDisconnect(db)

# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation where spp_cd in ('PIPL','REKN','ROST','ROTE')")
odbcClose(db)

# format
new.obs = dplyr::rename(new.obs, latitude = temp_lat, 
                        longitude = temp_lon,
                        obs_tm = obs_start_tm,
                        seconds_from_midnight = seconds_from_midnight_nb,
                        camera_reel = reel,
                        observer_confidence =observer_confidence_tx,
                        observer_comments = comments_tx,
                        observer_position = obs_position,
                        observers_tx = observer_tx) %>% 
  mutate(obs_dt = as.Date(obs_dt,format="%m/%d/%Y"),
         observation_id = observation_id + 804175,
         source_dataset_id = as.character(source_dataset_id),
         source_obs_id = as.character(source_obs_id),
         visibility_tx = as.character(visibility_tx),
         wind_speed_tx = as.character(wind_speed_tx),
         wind_dir_tx = as.character(wind_dir_tx),
         heading_tx = as.character(heading_tx)) %>% 
  rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA))


# combine old and new
old.obs = mutate(old.obs, obs_dt = as.Date(obs_dt))
all.data = bind_rows(old.obs, new.obs) %>%
  mutate(spp_cd = replace(spp_cd, spp_cd %in% "ROTE", "ROST")) %>%
  dplyr::select(-date_created, -date_imported, -who_created, -who_created_tx, 
                -Geometry, -geography, -boem_lease_block_id, -seasurface_tempc_nb, 
                -utm_zone, -temp_lat, -temp_lon, -datafile, -who_imported,
                -age_id, -sex_id, -behavior_id)

# pull up data summaries and join by dataset id
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
datasets = dbGetQuery(db,"select * from dataset")
dbDisconnect(db)

summaries = read_excel("//ifw-hqfs1/MB SeaDuck/seabird_database/documentation/How to and Reference files/NWASC_guidance/dataset_summaries_Aug2018.xlsx")
summaries = summaries[,1:5] %>% rename(dataset_id = Dataset_id)

datasets = filter(datasets, dataset_id %in% all.data$dataset_id) %>%
  mutate(dataset_type_cd = replace(dataset_type_cd, dataset_type_cd %in% "de","derived effort"),
         dataset_type_cd = replace(dataset_type_cd, dataset_type_cd %in% "og","original general observation"),
         dataset_type_cd = replace(dataset_type_cd, dataset_type_cd %in% "ot","original transect"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "a","airplane"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "b","boat"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "c","camera"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "f","fixed ground survey"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "g","area-wide ground survey"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "byc","bycatch"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "cbc","Christmas Bird count"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "cts","continuous time strip"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "dth","discrete time horizon"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "dts","discrete time strip"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% c("go","go "),"general observation"),
         survey_method_cd = replace(survey_method_cd, survey_method_cd %in% "tss","targeted species survey")) %>%
  dplyr::select(-responsible_party,-in_database,-metadata,-share_level_id,-platform_name_id)

datasets = left_join(datasets, summaries, by = "dataset_id")
# -------------- #

# -------------- #
# export 
# -------------- #
write.csv(datasets, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/DBigger_ESAspp_Oct2018/datasets.csv",
          row.names = F)
write.csv(all.data, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/DBigger_ESAspp_Oct2018/observations.csv",
          row.names = F)

# export as spatial
all.data = filter(all.data, !is.na(longitude), !is.na(latitude))
coordinates(all.data) = ~longitude + latitude
proj4string(all.data) = CRS("+init=epsg:4269")
writeOGR(all.data, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/DBigger_ESAspp_Oct2018",
         layer = "observations", driver = "ESRI Shapefile")
# # -------------- #

