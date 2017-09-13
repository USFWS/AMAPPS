# ------------------------ #
# combine old and new seabird catalog data
# pull FWS AMAPPS and seaduck data
#
# dataset ids: 141, 142, 164, 118, 140, 138, 137, 139, 100, 97, 147, 146, 113, 106
# include ITIS codes, common names, species names
# change to fit column names of Regional Point Species Database Structure
# do not need track/transect data, only obs
# ------------------------ #


# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
library(dplyr)
library(sp)  # vector data
library(raster)  # raster data
library(rgdal)  # input/output, projections
library(rgeos)  # geometry ops
# ------------------------ #


# ------------------------ #
# load dataset descriptions
# ------------------------ #
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/MTJones_FWS_July2017"
dir.archive = "//IFW9mbm-fs1/SeaDuck/seabird_database/database_export/archive/seabird_database_obs_trans_tbls_April2016"
dir.from.segmentation = "//IFW9mbm-fs1/SeaDuck/Kyle_Working_Folder/Segmentation/Data/transect_shp_files"
# ------------------------ #


# ------------------------ #
# load archive observations
# and transects
# ------------------------ #
# read in old obs data
old_obs = read.csv(file = paste(dir.archive, "vw_obs.csv", sep="/"), header=TRUE, quote="", row.names=NULL, stringsAsFactors = FALSE) %>% 
  mutate(observation_id = as.numeric(as.character(observation_id))) %>% filter(!is.na(observation_id)) %>%
  mutate(transect_id = as.numeric(as.character(transect_id)),
         source_obs_id = as.numeric(as.character(source_obs_id)),
         obs_count_intrans_nb = as.numeric(as.character(obs_count_intrans_nb)),
         obs_count_general_nb = as.numeric(as.character(obs_count_general_nb)),
         angle_from_observer_nb = as.numeric(as.character(angle_from_observer_nb)),
         seastate_beaufort_nb = as.numeric(as.character(seastate_beaufort_nb)),
         seasurface_tempc_nb = as.numeric(as.character(seasurface_tempc_nb)),
         who_created = as.numeric(as.character(who_created)),
         temp_lat = as.numeric(as.character(temp_lat)),
         temp_lon = as.numeric(as.character(temp_lon)),
         who_imported = as.numeric(as.character(who_imported)),
         salinity_ppt_nb = as.numeric(as.character(salinity_ppt_nb)),
         local_obs_id = as.numeric(as.character(local_obs_id)),
         heading_tx = as.character(heading_tx)) %>% 
         filter(!is.na(dataset_id))
# ------------------------ #


# ------------------------ #
# combine datasets
# ------------------------ #
obs.in.db = mutate(obs.in.db, heading_tx = as.character(heading_tx),
                   wind_speed_tx = as.character(wind_speed_tx),
                   wind_dir_tx = as.character(wind_dir_tx),
                   observation_id = obs.in.db$observation_id + 804175) # fix numbers based on data already present

# combine
obs_data = bind_rows(obs.in.db, old_obs)

# fix codes that were deleted when database was updated
obs_data$spp_cd[obs_data$spp_cd %in% "UNPI"]="UNSE" # unidentified pinniped to unidentified seal (no sea lions on east coast)
obs_data$spp_cd[obs_data$spp_cd %in% "CRTE"]="UCRT" # two codes for unidentified common or roseate tern, cut one

rm(old_obs, obs.in.db)
# ------------------------ #


# ------------------------ #
# pull FWS data
# ------------------------ #
obs_data = filter(obs_data, dataset_id %in% c(141, 142, 164, 118, 140, 138, 137, 139, 147, 146, 113 ))
data.in.db = filter(data.in.db, dataset_id %in% c(141, 142, 164, 118, 140, 138, 137, 139, 147, 146, 113 ))
# ------------------------ #

# ------------------------ #
# fix archived observation species codes
# ------------------------ #
tmp <- !obs_data$spp_cd %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs_data$spp_cd[tmp]))

obs_data$spp_cd[obs_data$spp_cd %in% c("TRAW")] = "BOTD"              
# ------------------------ #


# ------------------------ #
# join itis codes and names
# ------------------------ #
obs_data = left_join(obs_data, dplyr::select(spplist,-species_type_cd), by="spp_cd")
# ------------------------ #


# ------------------------ #
# change names
# ------------------------ #
obs_data$obs_dt[grepl("/", obs_data$obs_dt)] = as.character(as.Date(obs_data$obs_dt[grepl("/", obs_data$obs_dt)],"%m/%d/%Y")) # skrewy dates
obs_data = obs_data %>% 
  mutate(individual_count = ifelse(!is.na(obs_count_general_nb),obs_count_general_nb,obs_count_intrans_nb)) %>% 
  rename(longitude = temp_lon, latitude = temp_lat, itis_tsn = itis_cd,
         observation_date = obs_dt, collector=observers_tx, project_id = source_dataset_id,
         GlobalID = observation_id, provided_common_name = common_name) %>% 
  dplyr::select(latitude, longitude, observation_date, itis_tsn, provided_common_name, scientific_name,
                individual_count, collector, source_transect_id, project_id, GlobalID) %>% rowwise %>% 
  mutate(count_type = "individual observation", centroid = "no", 
         observation_date = as.Date(observation_date,"%Y-%m-%d"),
         year = format(observation_date, "%Y"), 
         month = format(observation_date, "%m"), 
         day = format(observation_date, "%d"), 
         time = NA, documentation_link="https://connect.doi.gov/fws/Portal/acjv/seabird/SitePages/Home.aspx",
         individual_count = ifelse(is.na(individual_count) & provided_common_name %in% "boat--trawler/dragger",1,individual_count),
         collector = ifelse(is.na(collector),sapply(strsplit(source_transect_id,"_"),tail,1),collector),
         location_name = "Northwest Atlantic Ocean within the U.S. EEZ") %>%
  dplyr::select(-source_transect_id) 
# ------------------------ #


# ------------------------ #
# export csv
# ------------------------ #
write.csv(obs_data, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
#write.csv(data.in.db, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)
# ------------------------ #
