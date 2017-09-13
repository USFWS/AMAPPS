#---------------------------#
# format MassCEC data for NWASC
#---------------------------#


#---------------------------#
# packages
#---------------------------#
require(dplyr)
require(zoo)
require(geosphere)
#---------------------------#


#---------------------------#
# directories
#---------------------------#
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/VOWTAP"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
load("Z:/seabird_database/data_import/in_progress/VOWTAP/VOWTAP_Avian_Data.Rdata")
id = 134
#---------------------------#


#---------------------------#
# formatting
#---------------------------#
obs$index=1:dim(obs)[1]

obs$transect = NA
obs$transect[obs$lat>36.94]=6
obs$transect[obs$lat>36.93 & obs$lat<36.94]=5
obs$transect[obs$lat>36.91 & obs$lat<36.93]=4
obs$transect[obs$lat>36.89 & obs$lat<36.91]=3
obs$transect[obs$lat>36.88 & obs$lat<36.89]=2
obs$transect[obs$lat<36.88]=1
obs$transect[obs$offline==1]=NA

tracks$source_transect_id = paste(tracks$date, tracks$piece, sep="_")
obs$source_transect_id = paste(as.Date(obs$date), obs$transect, sep="_")
obs$source_transect_id[obs$offline==1] = NA

tracks = select(tracks, -transect) %>% 
  arrange(date, desc(piece), type) %>%
  mutate(type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT"),
         index = 1:n())
obs = select(obs, -transect, -date_text) %>%
  mutate(flight_hei = replace(flight_hei, flight_hei %in% "NULL", NA),
         flight_dir = replace(flight_dir, flight_dir %in% "NULL", NA),
         age = replace(age, age %in% "NULL", NA),
         behavior = replace(behavior, behavior %in% "NULL", NA)) 
#---------------------------#


#---------------------------#
# make transect table
#---------------------------#
rm(transect)
data_transect = tracks %>% group_by(source_transect_id) %>%
  arrange(index) %>% summarise(start_lat = first(lat),
                              start_lon = first(lon),
                              end_lat = last(lat),
                              end_lon = last(lon),
                              start_dt = first(date),
                              end_dt = last(date),
                              index = first(index),
                              transect_distance_nb = distVincentySphere(c(start_lon, start_lat), c(end_lon, end_lat))) %>% 
  ungroup %>% arrange(index) %>% mutate(index = 1:n())
#---------------------------#


#---------------------------#
# formatting
#---------------------------#
data = obs; rm(obs)
data_track = tracks; rm(tracks)
data$date = as.character(as.Date(data$date))
data_track$date = as.character(as.Date(data_track$date))
data_transect$start_dt = as.character(as.Date(data_transect$start_dt))
data_transect$end_dt = as.character(as.Date(data_transect$end_dt))
#---------------------------#
