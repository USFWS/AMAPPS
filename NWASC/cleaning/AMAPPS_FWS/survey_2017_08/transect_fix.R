# transect ids didn't assign to obs and track
# probably because of issues with matching transect ids
# due to incorrect transect upload and track upload
# observatio upload was correct the first time, just missing ids

# THIS IS MESSY!!!
# THIS WILL ONLY BE RUN ONCE TO FIX THE ISSUE
# DO NOT RUN AGAIN
# ONCE THIS IS RUN THERE WILL BE CORRECT DATA IN THE DB
# ran on Sept. 26, 2018

require(RODBC)
require(odbc)
require(dplyr)

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation where dataset_id = 395")
new.tracks <- sqlQuery(db, "select * from track where dataset_id = 395")
new.transects <- sqlQuery(db, "select * from transect where dataset_id = 395")
odbcCloseAll()

new.transects = new.transects %>% mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
                                         end_dt = as.Date(end_dt, format = "%m/%d/%Y"),
                                         new_source_transect_id = paste(paste(substring(as.character(obs_position),1,1),"f",sep=""),
                                                                        format(start_dt,"%Y"),
                                                                        format(start_dt,"%m"),
                                                                        format(start_dt,"%d"),
                                                                        source_transect_id, 
                                                                        sep = "_"))

new.tracks = new.tracks %>% mutate(track_dt = as.Date(track_dt, format = "%Y-%m-%d")) %>%
  rowwise() %>% mutate(new_source_transect_id = paste(paste(substring(as.character(observer_position),1,1),"f",sep=""),
                                                     format(track_dt,"%Y"),
                                                     format(track_dt,"%m"),
                                                     format(track_dt,"%d"),
                                                     source_transect_id, 
                                                     sep = "_"),
                      new_source_transect_id = replace(new_source_transect_id, is.na(source_transect_id), NA))
#new.obs = mutate(new.obs, new_source_transect_id = substring(source_transect_id,10,28))
# need zeros in month and day
new.obs = new.obs %>% mutate(obs_dt = as.Date(obs_dt, format = "%Y-%m-%d")) %>%
  rowwise() %>% mutate(new_source_transect_id = paste(substring(source_transect_id,10,11),
                                                      format(obs_dt,"%Y"),
                                                      format(obs_dt,"%m"),
                                                      format(obs_dt,"%d"),
                                                      substring(source_transect_id,23,28),
                                                      sep="_"),
                       new_source_transect_id = replace(new_source_transect_id, substring(source_transect_id,23,28) %in% "NA", NA))

# add transect ids
# new.tracks = left_join(new.tracks, select(new.transects, new_source_transect_id, transect_id, start_dt), 
#                        by=c("new_source_transect_id", "track_dt" = "start_dt")) %>%
#   rename(transect_id = transect_id.y) %>% select(-transect_id.x)
# 
# new.obs = left_join(new.obs, select(new.transects, new_source_transect_id, transect_id, start_dt), 
#                  by=c("new_source_transect_id", "obs_dt" = "start_dt")) %>%
#   rename(transect_id = transect_id.y) %>% select(-transect_id.x)

# ----------- #

# correct transect table was saved in "//ifw-hqfs1/MB SeaDuck/AMAPPS/clean_data/AMAPPS_2017_08"
library(readr)
data_transect <- read_csv("Z:/AMAPPS/clean_data/AMAPPS_2017_08/AMAPPS_2017_08_transectTbl.csv")

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db <- sqlFetch(db, "transect")
odbcCloseAll()

# format
data_transect = as.data.frame(data_transect)
dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
colnames(dat_transect) = colnames(transects.in.db)

# in case capitalized
colnames(data_transect) = tolower(colnames(data_transect))

# move those variables over that have the same name
same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
dat_transect[,same_nm] = data_transect[,same_nm]

dat_transect$dataset_id = 395
dat_transect$source_dataset_id = "AMAPPS_FWS_Aerial_Summer2017" 

if(any(colnames(data_transect) %in% c("transect","transect_id"))) {
  dat_transect$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]
}
if(any(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))) {
  dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
}
if(any(colnames(data_transect) %in% c("startlatdd","start_lat", "begin_lat","start_latitude",  "begin_latitude"))) {
  dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("startlatdd","start_lat","begin_lat","start_latitude", "begin_latitude"))]
}
if(any(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude", "end_long", "stop_long"))) {
  dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
}
if(any(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))) {
  dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))]
}
if(any(colnames(data_transect) %in% c("date","start_dt","start_date"))) {
  dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))],format="%Y-%m-%d"),'%m/%d/%Y')
}
if(any(colnames(data_transect) %in% c("date","end_dt","end_date"))) {
  dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))],format="%Y-%m-%d"),'%m/%d/%Y')
}
if(any(colnames(data_transect) %in% c("observer","observers","observer_tx","obs"))) {
  dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("obs","observer","observers","observer_tx"))]
}
if(any(colnames(data_transect) %in% c("observer_position","seat"))) {
  dat_transect$obs_position = data_transect[,which(colnames(data_transect) %in% c("observer_position","seat"))]
}
if(any(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))){
  dat_transect$transect_distance_nb = data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))]
}
if(any(colnames(data_transect) %in% c("start_sec"))) {
  dat_transect$time_from_midnight_start = data_transect[,which(colnames(data_transect) %in% c("start_sec"))]
}
if(any(colnames(data_transect) %in% c("stop_sec","end_sec"))) {
  dat_transect$time_from_midnight_stop = data_transect[,which(colnames(data_transect) %in% c("stop_sec","end_sec"))]
}


# redo new key and match to obs/track in db
dat_transect = dat_transect %>% mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
                                       end_dt = as.Date(end_dt, format = "%m/%d/%Y"),
                                       new_source_transect_id = paste(obs_position,
                                                                        format(start_dt,"%Y"),
                                                                        format(start_dt,"%m"),
                                                                        format(start_dt,"%d"),
                                                                        source_transect_id, 
                                                                        sep = "_"))

# cut transects already in the database
transects.in.db.already = filter(dat_transect, new_source_transect_id %in% new.transects$new_source_transect_id)
dat_transect = filter(dat_transect, !new_source_transect_id %in% new.transects$new_source_transect_id)

# assign transect to those not in the database
dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))

# join transect already in database to get id numbers
transects.in.db.already = left_join(transects.in.db.already, 
                                    select(new.transects, transect_id, new_source_transect_id), 
                                    by="new_source_transect_id") %>%
  rename(transect_id = transect_id.y) %>% dplyr::select(-transect_id.x)

# then recombine dat_transect
dat_transect = rbind(transects.in.db.already, dat_transect)
dat_transect = dplyr::select(dat_transect, -new_source_transect_id) %>%
  mutate(start_dt = format(start_dt, "%m/%d/%Y"), 
         end_dt = format(end_dt, "%m/%d/%Y"))

# MAKE SURE OLD TRANSECT TABLE IS REMOVED!!! 
# THEN UPLOAD NEW TRANSECT TABLE
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
odbcCloseAll()
write.csv(dat_transect, file="//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/transect_395.csv", row.names = FALSE)

# reassign correct transect numbers
# add transect ids
new.tracks = left_join(new.tracks, select(dat_transect, new_source_transect_id, transect_id, start_dt), 
                       by=c("new_source_transect_id", "track_dt" = "start_dt")) %>%
  rename(transect_id = transect_id.y) %>% select(-transect_id.x) %>%
  dplyr::select(-new_source_transect_id) %>%
  mutate(track_dt = format(track_dt, "%m/%d/%Y"))

new.obs = left_join(new.obs, select(dat_transect, new_source_transect_id, transect_id, start_dt), 
                    by=c("new_source_transect_id", "obs_dt" = "start_dt")) %>%
  rename(transect_id = transect_id.y) %>% select(-transect_id.x) %>%
  dplyr::select(-new_source_transect_id) %>%
  mutate(obs_dt = format(obs_dt, "%m/%d/%Y"))

# add to NWASC temporary db
# CHECK THAT OLD TABLE ROWS ARE REMOVED
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
sqlQuery(db, "delete from observation where dataset_id = 395")
sqlSave(db, new.obs, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
odbcClose(db) 

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
sqlQuery(db, "delete from track where dataset_id = 395")
sqlSave(db, new.tracks, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
odbcClose(db) 
# STILL MISSING SOME TRACK DATA THAT NEEDS TO BE ADDED
# BUT ALL TRANSECT INFORMATION IS THERE
# ------------------------ #

# ------------------------ #
# export as csv in case we need to rebuild the database
# ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/"
write.csv(new.obs, file=paste(dir.out,"observations_395.csv", sep=""), row.names = FALSE)
write.csv(new.tracks, file=paste(dir.out,"track_395.csv", sep=""), row.names = FALSE)
# ------------------------ #

rm(list=ls())
odbcCloseAll()
