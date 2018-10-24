# -------------- #
# pull all njdep and nj data
#
# We are looking for the following:
#   
# 1) NJDEP Ecological baseline Studies survey observations and effort data 
# from the Seabird Catalog.
# 
# 2) All birds observed within New Jersey waters to the EEZ, basically 
# between 38.93N and 41.36N latitude (the south and north most latitudes) 
# or state territorial waters extended out to the EEZ, whichever is 
# easiest from the Seabird Catalog.
#
### had to export effort linestrings and multilinestrings as shapefiles
### commands code below
# ogr2ogr -f "ESRI Shapefile" "C:/Users/kecoleman/shapefiles_from_mssql" 
# "MSSQL:server=ifw9mbmsvr008; database = SeabirdCatalog; trusted_connection=yes; driver = SQL server;"
# -sql "select * from transect where dataset_id = 91" 
# -overwrite -nln njdep_transect -nlt LINESTRING -a_srs "EPSG:4269"
# -------------- #


# -------------- #
# packages
# -------------- #
library(readxl)
require(RODBC)
require(odbc)
require(dplyr)
require(rgdal)
# -------------- #


# -------------- #
# data
# -------------- #
# old data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
old.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, *
                     from observation where geography.Lat between 38.45 and 41.36")

#old.effort = dbGetQuery(db,"select [Geometry].STY as latitude, 
#                        [Geometry].STX as longitude, * from transect where [Geometry].STY between 38.93 and 41.36")
#njdep.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, *
#                     from observation where dataset_id = 91")
dbDisconnect(db)

# njdep.obs = njdep.obs %>% 
#   dplyr::select(-Geometry,-geography,-utm_zone,-time_from_midnight,
#                 -date_imported,-who_imported,-temp_lat,-temp_lon)
# coordinates(njdep.obs) = ~longitude + latitude
# proj4string(njdep.obs) = CRS("+init=epsg:4269")
# njdep.obs = as.data.frame(njdep.obs) 
# 
# sldf = readOGR("C:/Users/kecoleman/shapefiles_from_mssql/njdep_transect.shp") # made using ogr2ogr
# spdf = as(sldf, "SpatialPointsDataFrame")                          
# njdep.effort = as.data.frame(spdf)
# rm(sldf, spdf)
# # fix formating and rename names that were clipped when creating shapefile
# njdep.effort = njdep.effort %>% 
#   rename(transect_id = transect_i,
#          source_transect_id = source_tra,
#          source_datatset_id = source_dat,
#          transect_time_min_nb = transect_t,
#          transect_distance_nb = transect_d,
#          traversal_speed_nb = traversal_,
#          transect_width_nb = transect_w,
#          observers_tx = observers_,
#          seastate_beaufort_nb = seastate_b,
#          wind_speed_tx = wind_speed,
#          wind_dir_tx = wind_dir_t,
#          comments_tx = comments_t,
#          conveyance_name_tx = conveyance, 
#          wave_height_tx = wave_heigh,
#          whole_transect = whole_tran,
#          local_transect_id = local_tran,
#          temp_start_lat = temp_start,
#          temp_start_lon = temp_sta_1,
#          temp_stop_lat = temp_stop_,
#          temp_stop_lon = temp_sto_1,
#          observer_positiion = obs_positi,
#          local_survey_id = local_surv,
#          local_transect_id2 = local_tr_1,
#          longitude = coords.x1,
#          latitude = coords.x2) %>% 
#   group_by(transect_id) %>% 
#   mutate(track_id = seq(1:length(transect_id))) %>% ungroup() %>% 
#   mutate(track_id = paste(transect_id, track_id, sep="_")) %>% 
#   dplyr::select(-who_create,-date_creat,-utm_zone,-who_import,
#                 -time_from_,-time_fro_1,-date_impor,-seasurface,
#                 -survey_typ,-spatial_ty)
# # reformat and select for matching with new data
# njdep.track = njdep.effort %>% 
#   rename(track_dt = start_dt,
#          track_tm = start_tm,
#          comments = comments_tx) %>%
#   select(track_id,transect_id,dataset_id,track_dt,track_tm,comments,latitude,longitude)
# njdep.transect = njdep.effort %>% group_by(transect_id) %>%
#  # arrange(track_id) %>% 
#   summarise(dataset_id = first(dataset_id),
#             source_transect_id = first(source_transect_id),
#             start_dt = first(start_dt),
#             start_lat = first(latitude),
#             start_lon = first(longitude),
#             stop_lat = last(latitude),
#             stop_lon = last(longitude)) %>% 
#   arrange(start_dt)
# 
# sldf = readOGR("C:/Users/kecoleman/old_nwasc/nwasc_old_effort_lines.shp") # made using ogr2ogr
# spdf = as(sldf, "SpatialPointsDataFrame")                          
# old.effort.lines = as.data.frame(spdf) #no longer a line df, just used for naming purposes 
# rm(sldf, spdf)
# # spdf = readOGR("C:/Users/kecoleman/old_nwasc/nwasc_old_effort_points.shp") # made using ogr2ogr
# # old.effort.points = as.data.frame(spdf)
# # rm(spdf)
# 
# # export njdep
# write.csv(njdep.obs,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/njdep/njdep_obs.csv",row.names = F)
# write.csv(njdep.track,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/njdep/njdep_track.csv",row.names = F)
# write.csv(njdep.transect,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/njdep/njdep_transects.csv",row.names = F)
# # export njdep as spatial 
# coordinates(njdep.obs) = ~longitude + latitude
# proj4string(njdep.obs) = CRS("+init=epsg:4269")
# writeOGR(njdep.obs, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/njdep", 
#          layer = "njdep.obs", driver = "ESRI Shapefile")
# coordinates(njdep.track) = ~longitude + latitude
# proj4string(njdep.track) = CRS("+init=epsg:4269")
# writeOGR(njdep.track, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/njdep", 
#          layer = "njdep.track", driver = "ESRI Shapefile")


# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation where temp_lat between 38.45 and 41.36")
#new.tracks <- sqlQuery(db, "select * from track where track_lat between 38.45 and 41.36")
new.transects <- sqlFetch(db, "transect")
new.transects = filter(new.transects, transect_id %in% new.tracks$transect_id)
odbcClose(db)


# # filter data to > share level 3
# if(any(datasets$share_level_id[datasets$dataset_id %in% new.obs$dataset_id] %in% c(1,2))){
#   new.obs$source_dataset_id[datasets$share_level_id[datasets$dataset_id %in% new.obs$dataset_id] %in% c(1,2)]
# } else cat("No limited access datasets in the new data")
# if(any(datasets$share_level_id[datasets$dataset_id %in% old.obs$dataset_id] %in% c(1,2))){
#   cat(paste(unique(old.obs$source_dataset_id[old.obs$dataset_id %in% datasets$dataset_id[datasets$share_level_id %in% c(1,2)]]),
#   unique(old.obs$dataset_id[old.obs$dataset_id %in% datasets$dataset_id[datasets$share_level_id %in% c(1,2)]]),sep=": "))
# } else (cat("No limited access datasets in the old data"))
# # the datasets that came up are from 2004 and 2010, while they are listed at lower share levels enough time has passed to use 


# format
new.obs = dplyr::rename(new.obs, latitude = temp_lat, 
                        longitude = temp_lon,
                        obs_tm = obs_start_tm,
                        seconds_from_midnight = seconds_from_midnight_nb,
                        camera_reel = reel,
                        observer_confidence =observer_confidence_tx,
                        #original_sex_tx = animal_sex_tx,
                        #original_age_tx = behavior_tx,
                        #original_behavior_tx = animal_behavior_tx,
                        #associations_tx = association_tx,
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
all.data = bind_rows(old.obs, new.obs)
#all.transects = bind_rows(old.effort, new.transects)
#all.data = all.data %>% filter(!dataset_id %in% 395) # remove AMAPPS 2017 for now
all.data = all.data %>% dplyr::select(-date_created, -date_imported, -who_created, -who_created_tx, 
                                    -Geometry, -geography, -boem_lease_block_id, -seasurface_tempc_nb, 
                                    -utm_zone, -temp_lat, -temp_lon, -datafile, -who_imported,
                                    -age_id, -sex_id, -behavior_id)
rm(old.obs, new.obs)
# -------------- #


# -------------- #
# tests
# -------------- #
# and species list to check data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
spp_list = dbGetQuery(db,"select * from lu_species")
dbDisconnect(db)
spp_list = select(spp_list, -order, -family, -subfamily)
  
if(any(!all.data$spp_cd %in% spp_list$spp_cd)){unique(all.data$spp_cd[!all.data$spp_cd %in% spp_list$spp_cd])}
all.data = all.data %>% 
  mutate(spp_cd = replace(spp_cd, spp_cd %in% c("UNPL","PEEP"), "SHOR"),
         spp_cd = replace(spp_cd, spp_cd %in% c("UNCT","CASP","RODO","LUDU",
                                                "RUTO","SHEA","SHSP","YTVI"),"UNKN"),
         spp_cd = replace(spp_cd, spp_cd %in% "CRTE", "UCRT"), 
         spp_cd = replace(spp_cd, spp_cd %in% "KRILL", "ZOOP"),
         spp_cd = replace(spp_cd, spp_cd %in% "NONE", "UNKN"), 
         spp_cd = replace(spp_cd, spp_cd %in% "UNPI", "UNSE"), 
         spp_cd = replace(spp_cd, spp_cd %in% "GLSP","PIWH"), 
         spp_cd = replace(spp_cd, spp_cd %in% "ROTE", "ROST"),
         spp_cd = replace(spp_cd, spp_cd %in% "HEGU", "HERG"), 
         spp_cd = replace(spp_cd, spp_cd %in% "GULL", "UNGU"),
         spp_cd = replace(spp_cd, spp_cd %in% "3", "UNSC"),
         spp_cd = replace(spp_cd, spp_cd %in% "CAGO", "CANG"),
         spp_cd = replace(spp_cd, spp_cd %in% "BASW", "BARS"), 
         spp_cd = replace(spp_cd, spp_cd %in% "TRAW", "BOTD"), 
         spp_cd = replace(spp_cd, spp_cd %in% "SURF", "SUSC"), 
         spp_cd = replace(spp_cd, spp_cd %in% "UMMM", "UNMM"),
         spp_cd = replace(spp_cd, spp_cd %in% "PHAL", "UNPH"),
         spp_cd = replace(spp_cd, spp_cd %in% "TEAL", "UNTL"),
         spp_cd = replace(spp_cd, spp_cd %in% "TERN", "UNTE"),
         spp_cd = replace(spp_cd, spp_cd %in% "SKUA", "UNSK"),
         spp_cd = replace(spp_cd, spp_cd %in% "SCRE", "EASO"),
         spp_cd = replace(spp_cd, spp_cd %in% "COMD", "CODO"),
         spp_cd = replace(spp_cd, spp_cd %in% "SPSP", "UNSP"),
         spp_cd = replace(spp_cd, spp_cd %in% "MOSP", "UNMO"),
         spp_cd = replace(spp_cd, spp_cd %in% "DRSP", "GRDA"),
         spp_cd = replace(spp_cd, spp_cd %in% "SASP", "USAN")) %>%
  filter(!spp_cd %in% c("TRAN","BEGSEG","Comment","COMMENT","12","1","AWSD","--"))
if(any(!all.data$spp_cd %in% spp_list$spp_cd)){unique(all.data$spp_cd[!all.data$spp_cd %in% spp_list$spp_cd])}
rm(spp_list)

# birds only
all.data = all.data %>% filter(spp_cd %in% spp_list$spp_cd[spp_list$species_type_id %in% c(1,8)])

# basic plot tests
plot(all.data$obs_dt)

plot(all.data$longitude, all.data$latitude)
# -------------- #

# -------------- #
# effort
# -------------- #
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
effort = dbGetQuery(db,"select * from all_effort where latitude between 38.45 and 41.36")
dbDisconnect(db)

# -------------- #
# transects
# -------------- #
nt1 = filter(new.transects, transect_id %in% all.data$transect_id)
nt2 = filter(new.transects, transect_id %in% effort$transect_id)
nt = rbind(nt1,nt2) 
nt = nt[!duplicated(nt),]
rm(nt1,nt2,new.transects)
# -------------- #

# -------------- #
# pull up data summaries and join by dataset id
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
datasets = dbGetQuery(db,"select * from dataset")
ll = dbGetQuery(db,"select * from links_and_literature")
dbDisconnect(db)

summaries = read_excel("//ifw-hqfs1/MB SeaDuck/seabird_database/documentation/How to and Reference files/NWASC_guidance/dataset_summaries_Aug2018.xlsx")
summaries = summaries[,1:5] %>% rename(dataset_id = Dataset_id)
names(summaries) = tolower(names(summaries))

source("//ifw-hqfs1/MB SeaDuck/seabird_database/Rfunctions/transformDatasets.R")
datasets = transformDataset(datasets)

datasets = left_join(datasets, summaries, by = "dataset_id") %>% 
  filter(dataset_id %in% unique(c(effort$dataset_id, all.data$dataset_id, nt$dataset_id))) %>% 
  dplyr::select(-source_dataset_id,-data_url, -report, -data_citation, -publications, -publication_url, 
                -publication_DOI, -dataset_summary.x, -dataset_quality.x, -dataset_processing.x) %>% 
  rename(dataset_summary = dataset_summary.y, 
          dataset_quality = dataset_quality.y, 
          dataset_processing = dataset_processing.y) %>% 
  left_join(., select(ll,-id), by = "dataset_id")
#njdep.dataset = filter(datasets, dataset_id == 91)

rm(ll,db, summaries)
# -------------- #


# -------------- #
# export 
# -------------- #
write.csv(datasets, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/MABdatasets.csv",row.names = F)
write.csv(all.data,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/MABdata_obs.csv",row.names = F)
write.csv(effort,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/MABdata_effort.csv",row.names = F)
write.csv(spp_list,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/MABspecies.csv",row.names = F)
write.csv(nt,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018/newTransects.csv",row.names = F)

# export as spatial
all.data = filter(all.data, !is.na(longitude), !is.na(latitude))
coordinates(all.data) = ~longitude + latitude
proj4string(all.data) = CRS("+init=epsg:4269")
writeOGR(all.data, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018",
         layer = "MABobs", driver = "ESRI Shapefile")


effort = filter(effort, !is.na(longitude), !is.na(latitude))
coordinates(effort) = ~longitude + latitude
proj4string(effort) = CRS("+init=epsg:4269")
writeOGR(effort, dsn = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/AGilbert_NJDEP_Aug2018",
         layer = "MABeffort", driver = "ESRI Shapefile")
# # -------------- #

                
