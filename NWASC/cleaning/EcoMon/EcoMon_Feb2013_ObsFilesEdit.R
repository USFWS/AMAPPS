# --------------------- #
# Quality control EcoMon Sept. 2012 data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# LOAD PACKAGES
# -------------------------------- #
require(RODBC) # odbcConnect
require(lubridate) #fix timestamps
require(zoo) #na.locf
require(dplyr) # %>% 
library(stringr) #extract parts of a string
require(rgeos)
require(sp)
library(geosphere)
# -------------------------------- #


# -------------------------------- #
# DEFINE SURVEY
# -------------------------------- #
surveyFolder = "EcoMon_Feb13"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received/EcoMon"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
obs = read.csv(file.path(dir.in, "ecomon_feb2013_corrected_1_30_2017_TPW.csv"))
#---------------------#


#---------------------#
# fix time
#---------------------#
obs = mutate(obs, date_time = as.POSIXct(paste(paste(YYYY,MM1,DD,sep="/")," ", paste(hh,mm,ss_s,sep=":")), 
                                   format="%Y/%m/%d %H:%M:%S")) %>% 
  select(-YYYY,-MM1,-DD,-hh,-mm,-ss_s) %>% mutate(date = sapply(strsplit(as.character(date_time), " "), head, 1), 
                                                  time = sapply(strsplit(as.character(date_time), " "), tail, 1))
#---------------------#


#---------------------#
# break apart obs and track
#---------------------#  
obs = rename(obs, source_transect_id = Transect) 
colnames(obs) = tolower(names(obs))
obs = obs %>% mutate(comments_tx = paste(comment_1, comment_2, sep = "; ")) %>% 
  select(-comment_1, -comment_2)
obs$comments_tx[obs$comments_tx %in% "NA; NA"] = NA
obs$datafile = "ecomon_feb2013_corrected_1_30_2017_TPW.csv"

# fix start/stops
obs$start_stop[obs$fid %in% 13032] = "stop"
obs$start_stop[obs$fid %in% 19403] = "stop"
obs$start_stop[obs$fid %in% 21931] = NA

track = obs %>% filter(type %in% "GPS") %>% select(-type, -f28) %>% rename(type = spp) %>% mutate(type = as.character(type))
obs = obs %>% filter(type %in% "USER") %>% select(-type, -f28) %>% rename(type = spp) %>% mutate(type = as.character(type))
obs$type[obs$start_stop %in% c("start","stert"," start","atrt")] = "BEGCNT"
obs$type[obs$start_stop %in% c("stop"," stop")] = "ENDCNT"
track$type[track$start_stop %in% c("start","stert"," start","atrt")] = "BEGCNT"
track$type[track$start_stop %in% c("stop"," stop")] = "ENDCNT"
to.add = track[track$type %in% c("BEGCNT", "ENDCNT"),]
obs = rbind(obs, to.add) %>% arrange(fid)
rm(to.add)
track = filter(track, !type %in% c("BEGCNT", "ENDCNT")) 
track$type = "WAYPNT"
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$type

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
#---------------------#


#---------------------#
# other obs edits
#---------------------#
# remove empty cells
obs$type[obs$type %in% " "] = NA
obs = obs[!is.na(obs$type),]

# assign piece names as transect names
to.add = obs %>% select(type, fid) %>% filter(type %in% "BEGCNT") %>% 
  mutate(source_transect_id = seq(1:n()))
obs = left_join(obs, to.add, by=c("fid","type")) %>% select(-source_transect_id.x) %>% 
  rename(source_transect_id = source_transect_id.y)
rm(to.add)
obs$source_transect_id = na.locf(obs$source_transect_id)

# check if there is only one BEG/END per piece
obs %>% select(fid, type, date, time, source_transect_id) %>% 
  filter(type %in% c("BEGCNT","ENDCNT")) %>% group_by(source_transect_id) %>% 
  summarize(n = n()) %>% filter(n %% 2 != 0 )
#---------------------#


#---------------------#
# fix track
#---------------------#
# move BEG/END from obs to track
to.add = obs %>% filter(type %in% c("BEGCNT", "ENDCNT"))
obs = obs %>% filter(!type %in% c("BEGCNT", "ENDCNT"))
track = bind_rows(track, to.add) %>% arrange(fid)
rm(to.add)
track$source_transect_id = na.locf(track$source_transect_id)

#get rid of unused columns
track = select(track, -count, -behavior, -plumage, -age, -original_species_tx, -start_stop)
track = rename(track, visibility_tx = visib, seastate = beaufort, index = fid, 
               point_type = type, track_tm = time, track_dt = date, track_lon = longitude, 
               track_lat = latitude)

distances=matrix(ncol=1,nrow=dim(track)[1],data=NA)
for(n in 2:length(distances)) {
  distances[n] = distHaversine(c(track$track_lon[n-1],track$track_lat[n-1]), 
                               c(track$track_lon[n],track$track_lat[n])) 
}
track$distances=as.vector(distances); rm(distances)
track$distances[track$point_type %in% "BEGCNT"] = NA
tdists = track %>% select(source_transect_id, distances) %>% group_by(source_transect_id) %>% 
  summarise(distance = sum(distances, na.rm=TRUE))
#---------------------#


# ---------------------#
# rename obs
# ---------------------#
obs = rename(obs, index = fid, behavior_tx = behavior, travel_direction_tx = direction, 
             distance_to_animal_tx = distance, plumage_tx = plumage, age_tx = age, 
             seastate_beaufort_nb = beaufort, visibility_tx = visib, spp_cd = type, 
             angle_from_observer_nb = ang, temp_lat = latitude, temp_lon = longitude)
obs = select(obs, -start_stop, -date_time)
# ---------------------#


#---------------------#
# make transect
#---------------------#
transect = track %>% 
  select(track_lat, track_lon, track_dt, source_transect_id, point_type, track_tm, 
         visibility_tx, seastate, datafile) %>% 
  mutate(type = as.character(point_type)) %>% filter(point_type %in% c("BEGCNT","ENDCNT")) %>% 
  group_by(source_transect_id) %>%   arrange(point_type) %>%
  summarize(start_lon = first(track_lon), start_lat = first(track_lat), 
            end_lon = last(track_lon), end_lat = last(track_lat),
            start_tm = first(track_tm),end_tm = last(track_tm),
            end_dt = first(track_dt), visibility_tx = mean(visibility_tx, na.rm=TRUE),
            seastate_beaufort_nb = mean(seastate, na.rm=TRUE), datafile = first(datafile)) %>% 
  mutate(start_dt = end_dt) %>% 
  mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                         units = "mins"))   
transect$transect_width_nb = 300
transect$comments_tx = "Transect numbers are the order in which they occurred since it was not
provided by data supplier. Target speed was 10 knots/hr. Speed listed 
was calculated using distance(m) and time(min) and converted to nm/hr"
transect = left_join(transect, tdists, by="source_transect_id"); rm(tdists)
transect = mutate(transect, traversal_speed_nb =  (distance/(as.numeric(transect_time_min_nb)*60))*1.94384449244)
#---------------------#


#---------------------#
# export cleaned files
#---------------------#
write.csv(obs, file=paste(dir.out, "/", surveyFolder, "_observations.csv", sep=""), row.names = FALSE)
write.csv(track, file=paste(dir.out, "/", surveyFolder, "_track.csv", sep=""), row.names = FALSE)
write.csv(transect, file=paste(dir.out, "/", surveyFolder, "_transects.csv", sep=""), row.names = FALSE)
#---------------------#
