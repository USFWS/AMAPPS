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
# new.obs <- sqlQuery(db, "select * from observation where dataset_id = 395")
new.tracks <- sqlQuery(db, "select * from track where dataset_id = 395")
new.transects <- sqlQuery(db, "select * from transect where dataset_id = 395")
odbcCloseAll()

# new.transects = new.transects %>% mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
#                                          end_dt = as.Date(end_dt, format = "%m/%d/%Y"),
#                                          new_source_transect_id = paste(paste(substring(as.character(obs_position),1,1),"f",sep=""),
#                                                                         format(start_dt,"%Y"),
#                                                                         format(start_dt,"%m"),
#                                                                         format(start_dt,"%d"),
#                                                                         source_transect_id, 
#                                                                         sep = "_"))

# new.tracks = new.tracks %>% mutate(track_dt = as.Date(track_dt, format = "%Y-%m-%d")) %>%
#   rowwise() %>% mutate(new_source_transect_id = paste(paste(substring(as.character(observer_position),1,1),"f",sep=""),
#                                                      format(track_dt,"%Y"),
#                                                      format(track_dt,"%m"),
#                                                      format(track_dt,"%d"),
#                                                      source_transect_id, 
#                                                      sep = "_"),
#                       new_source_transect_id = replace(new_source_transect_id, is.na(source_transect_id), NA))

#new.obs = mutate(new.obs, new_source_transect_id = substring(source_transect_id,10,28))
# # need zeros in month and day
# new.obs = new.obs %>% mutate(obs_dt = as.Date(obs_dt, format = "%Y-%m-%d")) %>%
#   rowwise() %>% mutate(new_source_transect_id = paste(substring(source_transect_id,10,11),
#                                                       format(obs_dt,"%Y"),
#                                                       format(obs_dt,"%m"),
#                                                       format(obs_dt,"%d"),
#                                                       substring(source_transect_id,23,28),
#                                                       sep="_"),
#                        new_source_transect_id = replace(new_source_transect_id, substring(source_transect_id,23,28) %in% "NA", NA))

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
# data_transect <- read_csv("Z:/AMAPPS/clean_data/AMAPPS_2017_08/AMAPPS_2017_08_transectTbl.csv")
data_tracks<- read_csv("Z:/AMAPPS/clean_data/AMAPPS_2017_08/AMAPPS_2017_08_Track.csv")
  
# db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
# transects.in.db <- sqlFetch(db, "transect")
# odbcCloseAll()
# 
# # format
# data_transect = as.data.frame(data_transect)
# dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
# colnames(dat_transect) = colnames(transects.in.db)
# 
# # in case capitalized
# colnames(data_transect) = tolower(colnames(data_transect))
# 
# # move those variables over that have the same name
# same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
# dat_transect[,same_nm] = data_transect[,same_nm]
# 
# dat_transect$dataset_id = 395
# dat_transect$source_dataset_id = "AMAPPS_FWS_Aerial_Summer2017" 
# 
# if(any(colnames(data_transect) %in% c("transect","transect_id"))) {
#   dat_transect$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]
# }
# if(any(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))) {
#   dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]
# }
# if(any(colnames(data_transect) %in% c("startlatdd","start_lat", "begin_lat","start_latitude",  "begin_latitude"))) {
#   dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("startlatdd","start_lat","begin_lat","start_latitude", "begin_latitude"))]
# }
# if(any(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude", "end_long", "stop_long"))) {
#   dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
# }
# if(any(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))) {
#   dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))]
# }
# if(any(colnames(data_transect) %in% c("date","start_dt","start_date"))) {
#   dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))],format="%Y-%m-%d"),'%m/%d/%Y')
# }
# if(any(colnames(data_transect) %in% c("date","end_dt","end_date"))) {
#   dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))],format="%Y-%m-%d"),'%m/%d/%Y')
# }
# if(any(colnames(data_transect) %in% c("observer","observers","observer_tx","obs"))) {
#   dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("obs","observer","observers","observer_tx"))]
# }
# if(any(colnames(data_transect) %in% c("observer_position","seat"))) {
#   dat_transect$obs_position = data_transect[,which(colnames(data_transect) %in% c("observer_position","seat"))]
# }
# if(any(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))){
#   dat_transect$transect_distance_nb = data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))]
# }
# if(any(colnames(data_transect) %in% c("start_sec"))) {
#   dat_transect$time_from_midnight_start = data_transect[,which(colnames(data_transect) %in% c("start_sec"))]
# }
# if(any(colnames(data_transect) %in% c("stop_sec","end_sec"))) {
#   dat_transect$time_from_midnight_stop = data_transect[,which(colnames(data_transect) %in% c("stop_sec","end_sec"))]
# }
# 
# 
# # redo new key and match to obs/track in db
# dat_transect = dat_transect %>% mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
#                                        end_dt = as.Date(end_dt, format = "%m/%d/%Y"),
#                                        new_source_transect_id = paste(obs_position,
#                                                                         format(start_dt,"%Y"),
#                                                                         format(start_dt,"%m"),
#                                                                         format(start_dt,"%d"),
#                                                                         source_transect_id, 
#                                                                         sep = "_"))
# 
# # cut transects already in the database
# transects.in.db.already = filter(dat_transect, new_source_transect_id %in% new.transects$new_source_transect_id)
# dat_transect = filter(dat_transect, !new_source_transect_id %in% new.transects$new_source_transect_id)
# 
# # assign transect to those not in the database
# dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
# 
# # join transect already in database to get id numbers
# transects.in.db.already = left_join(transects.in.db.already, 
#                                     select(new.transects, transect_id, new_source_transect_id), 
#                                     by="new_source_transect_id") %>%
#   rename(transect_id = transect_id.y) %>% dplyr::select(-transect_id.x)
# 
# # then recombine dat_transect
# dat_transect = rbind(transects.in.db.already, dat_transect)
# dat_transect = dplyr::select(dat_transect, -new_source_transect_id) %>%
#   mutate(start_dt = format(start_dt, "%m/%d/%Y"), 
#          end_dt = format(end_dt, "%m/%d/%Y"))
# 
# # MAKE SURE OLD TRANSECT TABLE IS REMOVED!!! 
# # THEN UPLOAD NEW TRANSECT TABLE
# db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
# sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
# odbcCloseAll()
# write.csv(dat_transect, file="//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/transect_395.csv", row.names = FALSE)
# 
# # reassign correct transect numbers
# # add transect ids
# new.tracks = left_join(new.tracks, select(dat_transect, new_source_transect_id, transect_id, start_dt), 
#                        by=c("new_source_transect_id", "track_dt" = "start_dt")) %>%
#   rename(transect_id = transect_id.y) %>% select(-transect_id.x) %>%
#   dplyr::select(-new_source_transect_id) %>%
#   mutate(track_dt = format(track_dt, "%m/%d/%Y"))
# 
# new.obs = left_join(new.obs, select(dat_transect, new_source_transect_id, transect_id, start_dt), 
#                     by=c("new_source_transect_id", "obs_dt" = "start_dt")) %>%
#   rename(transect_id = transect_id.y) %>% select(-transect_id.x) %>%
#   dplyr::select(-new_source_transect_id) %>%
#   mutate(obs_dt = format(obs_dt, "%m/%d/%Y"))
# 
# # add to NWASC temporary db
# # CHECK THAT OLD TABLE ROWS ARE REMOVED
# db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
# sqlQuery(db, "delete from observation where dataset_id = 395")
# sqlSave(db, new.obs, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
# odbcClose(db) 
# 
# db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
# sqlQuery(db, "delete from track where dataset_id = 395")
# sqlSave(db, new.tracks, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
# odbcClose(db) 
# # STILL MISSING SOME TRACK DATA THAT NEEDS TO BE ADDED
# # BUT ALL TRANSECT INFORMATION IS THERE

# ----------------- #
# match to see what is already in the db
# so that we can add new records for track files that were missing
data_tracks = mutate(data_tracks,
                     seat = replace(seat, seat %in% "lf","left"),
                     seat = replace(seat, seat %in% "rf","right"),
                     track_dt = as.Date(paste(month, day, year, sep="/"), format="%m/%d/%Y"),
                     sec = as.character(floor(as.numeric(as.character(sec)))),
                     mystery.key = paste(track_dt, seat, sec, sep="_"))

new.tracks = mutate(new.tracks,
                   track_dt = as.Date(track_dt, format="%m/%d/%Y"),
                   seconds_from_midnight_nb = as.character(seconds_from_midnight_nb),
                   observer_position = as.character(observer_position),
                   observer_position = replace(observer_position, observer_position %in% "left ","left"),
                   mystery.key = paste(track_dt, observer_position, seconds_from_midnight_nb, sep="_"))

x1 = unique(new.tracks$mystery.key)
x2 = unique(data_tracks$mystery.key)
x3 = unique(c(x1,x2)) # check numbers

x = x2[!x2 %in% x1]

new.data_tracks = data_tracks[data_tracks$mystery.key %in% x,]

x = sort(unique(new.data_tracks$transect))
y = sort(unique(new.tracks$source_transect_id))
z = x[x %in% y]
x1 = new.data_tracks[new.data_tracks$transect %in% z,]
x2 = new.tracks[new.tracks$source_transect_id %in% z,]

# visually check overlapping transect numbers
for(a in 12){ # 1:17 one at a time to compare for overlap
  x3 = x1[x1$transect %in% z[a],] %>% arrange(sec)
  x4 = x2[x2$source_transect_id %in% z[a],] %>% arrange(seconds_from_midnight_nb)
}
rm(x1,x2,x3,x4,x,y,z)
# 431600 - missing twp, only mdk in db. 
# 432100 - missing twp, only mdk in db. 
# 432600 - missing twp, only mdk in db. 
# 433100 - missing twp, only mdk in db. 
# 433600 - missing twp, only mdk in db.  
# 434100 - missing twp, only mdk in db. 
# 434600 - missing twp, only mdk in db.
# 435100 - missing twp, only mdk in db. 
# 442100 - missing twp, only mdk in db. 
# 442101 - missing twp, only mdk in db. 
# 442600 - missing twp, only mdk in db. 
# 442601 - missing twp, only mdk in db. 
# 442602 - missing twp, only mdk in db. 
# 443100 - missing twp, only mdk in db. 
# 443600 - missing twp, only mdk in db. 
# 444100 - missing twp, only mdk in db.
# 444600 - missing twp, only mdk in db.

# check twp tracks with errors in data_tracks to see if correct there?
data_tracks[data_tracks$transect %in% 431600 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 432100 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 434100 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 434600 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),]
data_tracks[data_tracks$transect %in% 442601 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 442602 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 444100 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),] 
data_tracks[data_tracks$transect %in% 444600 & data_tracks$type %in% c("BEGCNT", "ENDCNT"),]

# assign numbers track id numbers
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
tracks.in.db <- sqlQuery(db, "select * from track")
max(tracks.in.db$track_id) #1289746
odbcClose(db)

data_track = new.data_tracks 

dat_track = as.data.frame(matrix(ncol=dim(tracks.in.db)[2], nrow=dim(data_track)[1], data=NA)) 
colnames(dat_track) = colnames(tracks.in.db)

# in case capitalized 
colnames(data_track) = tolower(colnames(data_track))

# move those variables over that have the same name
same_nm = colnames(data_track[colnames(data_track) %in% colnames(dat_track)])
dat_track[,same_nm] = data_track[,same_nm]

dat_track$dataset_id = 395
dat_track$track_id = c((max(tracks.in.db$track_id)+1):(max(tracks.in.db$track_id)+dim(data_track)[1]))

# fill in unmatched variables
data_track=as.data.frame(data_track)
if(any(colnames(data_track) %in% c("lon", "longitude", "long"))) {dat_track$track_lon = data_track[,which(colnames(data_track) %in% c("lon", "longitude", "long"))]}
if(any(colnames(data_track) %in% c("lat", "latitude"))) {dat_track$track_lat = data_track[,which(colnames(data_track) %in% c("lat", "latitude"))]}
if(any(colnames(data_track) %in% c("type","spp"))) {dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type","spp"))]}
if(any(colnames(data_track) %in% c("beaufort"))) {dat_track$seastate = data_track[,which(colnames(data_track) %in% c("beaufort"))]}
if(any(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))) {dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))]),format='%m/%d/%Y')}
if(any(colnames(data_track) %in% c("time"))) {dat_track$track_tm = data_track[,which(colnames(data_track) %in% c("time"))]}
if(any(colnames(data_track) %in% c("transect","transect_id"))) {dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id"))]}
if(any(colnames(data_track) %in% c("index"))) {dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]} 
if(any(colnames(data_track) %in% c("sec","secs","seconds")) & !any(colnames(data_track) %in% c("time"))) {dat_track$seconds_from_midnight_nb = data_track[,which(colnames(data_track) %in% c("sec","secs","seconds"))]}
if(any(colnames(data_track) %in% c("eventdesc"))) {dat_track$comment = data_track[,which(colnames(data_track) %in% c("eventdesc"))]}
if(any(colnames(data_track) %in% c("seat"))) {dat_track$observer_position = data_track[,which(colnames(data_track) %in% c("seat"))]}
if(any(colnames(data_track) %in% c("obs"))) {dat_track$observer = data_track[,which(colnames(data_track) %in% c("obs"))]}

if(all(is.na(dat_track$source_track_id))) {dat_track$source_track_id = 1:dim(data_track)[1]}

dat_track = dat_track %>% mutate(track_id = as.integer(track_id),           
                                 track_dt = as.character(track_dt),           
                                 track_tm = as.character(track_tm),           
                                 track_lat = as.double(track_lat),                
                                 track_lon = as.double(track_lon),               
                                 point_type = as.character(point_type),          
                                 source_survey_id = as.character(source_survey_id),    
                                 source_transect_id = as.character(source_transect_id),  
                                 observer_position = as.character(observer_position),   
                                 observer = as.character(observer),           
                                 offline = as.integer(offline),                  
                                 seastate = as.character(seastate),           
                                 comment = as.character(comment),            
                                 transect_id = as.integer(transect_id),             
                                 dataset_id = as.integer(dataset_id),              
                                 track_gs = as.character(track_gs),            
                                 piece = as.integer(piece),                 
                                 source_track_id = as.double(source_track_id),
                                 seconds_from_midnight_nb = as.integer(seconds_from_midnight_nb),
                                 datafile = as.character(datafile))

# match to transects
new.transects = new.transects %>% mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
                                       end_dt = as.Date(end_dt, format = "%m/%d/%Y"),
                                       new_source_transect_id = paste(obs_position,
                                                                        format(start_dt,"%Y"),
                                                                        format(start_dt,"%m"),
                                                                        format(start_dt,"%d"),
                                                                        source_transect_id,
                                                                        sep = "_"))
dat_track = mutate(dat_track,
                   observer_position = replace(observer_position, observer_position %in% "left", "lf"), 
                   observer_position = replace(observer_position, observer_position %in% "right", "rf"), 
                   track_dt = as.Date(track_dt, format = "%Y-%m-%d"),
                   new_source_transect_id = paste(observer_position,
                                                  format(track_dt,"%Y"),
                                                  format(track_dt,"%m"),
                                                  format(track_dt,"%d"),
                                                  source_transect_id,
                                                  sep = "_"))

dat_track = left_join(dat_track, select(new.transects, new_source_transect_id, transect_id, start_dt),
                       by=c("new_source_transect_id", "track_dt" = "start_dt")) %>%
  rename(transect_id = transect_id.y) %>% select(-transect_id.x) %>%
  dplyr::select(-new_source_transect_id) %>%
  mutate(track_dt = format(track_dt, "%m/%d/%Y"))

# test
any(is.na(dat_track$transect_id[!is.na(dat_track$source_transect_id)]))

# new corrected tracks (with missing data lines)
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
odbcClose(db) 

# # ------------------------ #
# 
# # ------------------------ #
# # export as csv in case we need to rebuild the database
# # ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/"
write.csv(dat_track, file=paste(dir.out,"track_395_additions.csv", sep=""), row.names = FALSE)
# write.csv(new.obs, file=paste(dir.out,"observations_395.csv", sep=""), row.names = FALSE)
# write.csv(new.tracks, file=paste(dir.out,"track_395.csv", sep=""), row.names = FALSE)
# # ------------------------ #
# 
rm(list=ls())
odbcCloseAll()
