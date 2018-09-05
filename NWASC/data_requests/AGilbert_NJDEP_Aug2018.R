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
                     from observation where geography.Lat between 38.93 and 41.36")
old.effort = dbGetQuery(db,"select [Geometry].STY as latitude, 
                        [Geometry].STX as longitude, * from transect where [Geometry].STY between 38.93 and 41.36")
old_effort2 = dbGetQuery(db, "select * from effort")
old_effort2 = filter(old.effort, transect_id %in% old.obs$transect_id) # need to test differences

njdep.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, *
                     from observation where dataset_id = 91")
dbDisconnect(db)

sldf = readOGR("C:/Users/kecoleman/shapefiles_from_mssql/njdep_transect.shp") # made using ogr2ogr
spdf = as(sldf, "SpatialPointsDataFrame")                          
njdep.effort = as.data.frame(spdf)
rm(sldf, spdf)
# fix formating and rename names that were clipped when creating shapefile
njdep.effort = njdep.effort %>% 
  rename(transect_id = transect_i,
         source_transect_id = source_tra,
         source_datatset_id = source_da,
         #transect_t = transect_t,
         #transect_d = transect_d,
         #traversal_,
         transect_width = transect_w,
         #observers_,
         seastate_beaufort = seastate_b,
         wind_dir_tx = wind_dir_t,
         #whole_tran = whole_tran,
         #local_tran = local_tran,
         observer_positiion = obs_positi,
         longitude = coords.x1,
         latitude = coords.x2) %>% 
  group_by(transect_id) %>% 
  mutate(track_id = seq(1:length(transect_id))) %>% ungroup() %>% 
  mutate(track_id = paste(transect_id, track_id, sep="_")) %>% 
  dplyr::select(-who_create,-date_creat,-utm_zone,-who_import,
                -temp_start,-temp_sta_1,-temp_stop_,-temp_sto_1,
                -time_from_,-time_fro_1,-date_impor)

# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation where temp_lat between 38.93 and 41.36")
new.tracks <- sqlQuery(db, "select * from track where track_lat between 38.93 and 41.36")
new.transects <- sqlFetch(db, "transect")
new.transects = filter(new.transects, transect_id %in% new.tracks$transect_id)
odbcClose(db)

# missing AMAPPS 2017 effort!!! 

# add NYSERDA

# get dataset table to check share level 
# and species list to check data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
datasets = dbGetQuery(db,"select * from dataset")
spp_list = dbGetQuery(db,"select * from lu_species")
dbDisconnect(db)

# filter data to > share level 3
if(any(datasets$share_level_id[datasets$dataset_id %in% new.obs$dataset_id] %in% c(1,2))){
  new.obs$source_dataset_id[datasets$share_level_id[datasets$dataset_id %in% new.obs$dataset_id] %in% c(1,2)]
} else cat("No limited access datasets in the new data")
if(any(datasets$share_level_id[datasets$dataset_id %in% old.obs$dataset_id] %in% c(1,2))){
  cat(paste(unique(old.obs$source_dataset_id[old.obs$dataset_id %in% datasets$dataset_id[datasets$share_level_id %in% c(1,2)]]),
  unique(old.obs$dataset_id[old.obs$dataset_id %in% datasets$dataset_id[datasets$share_level_id %in% c(1,2)]]),sep=": "))
} else (cat("No limited access datasets in the old data"))
# the datasets that came up are from 2004 and 2010, while they are listed at lower share levels enough time has passed to use 


# format
new.obs = dplyr::rename(new.obs, latitude = temp_lat, 
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
                        associations_tx = association_tx) %>% 
  mutate(obs_dt = as.Date(obs_dt,format="%m/%d/%Y"),
         observation_id = observation_id + 804175) %>% rowwise %>% 
  mutate(obs_count_general_nb = replace(obs_count_general_nb,obs_count_general_nb==obs_count_intrans_nb,NA))


# combine old and new
all.data = bind_rows(old.obs, new.obs)
all.transects = bind_rows(old.effort, new.transects)

# pull up data summaries and join by dataset id
summaries = read_excel("//ifw-hqfs1/MB SeaDuck/seabird_database/documentation/How to and Reference files/NWASC_guidance/dataset_summaries_Aug2018.xlsx")
datasets = filter(datasets, dataset_id %in% all.data$dataset_id)
datasets = join(datasets, summaries, by = c("dataset_id", "Dataset_id"))
# -------------- #
                
