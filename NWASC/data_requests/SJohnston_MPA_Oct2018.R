# check for data in bounding box
# https://www.ospar.org/work-areas/bdc/marine-protected-areas/ospar-seeks-views-on-the-nomination-proforma-for-the-north-atlantic-current-and-evlanov-seamount-mpa
#
# map downloaded from 
# https://odims.ospar.org/maps/?limit=100&offset=0
# -------------------- #

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
old.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, * from observation ")
dbDisconnect(db)

# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation")
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
all.data = bind_rows(old.obs, new.obs)
# -------------- #

# read in map
outer = readOGR("//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/SJohnston_MPA_Oct2018","ospar_outer_boundary_2016_01")
inner = readOGR("//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/SJohnston_MPA_Oct2018","ospar_inner_boundary_2016_01")

outer@bbox
inner@bbox

plot(outer)
lines(inner, col="red")
points(all.data$longitude,all.data$latitude)
