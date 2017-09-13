# --------------------- #
# NOAA/ NMFS/ NEFSC boat 2016
# Date Created: 1-2017
# Author: Kaycee Coleman
# --------------------- #


# --------------------- #
# load packages
# --------------------- #
require(rgdal)
require(lubridate)
require(RODBC)
require(ggplot2)
require(zoo)
require(dplyr)
# --------------------- #


# --------------------- #
# set paths
# --------------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
surveyFolder = "NOAA NMFS"
yearLabel = "NEFSC_AMAPPS_ship_2016"
dir.in <- paste(dir, surveyFolder, yearLabel, sep = "/") 
dir.out <- paste(gsub("datasets_received", paste("data_import/in_progress", surveyFolder, yearLabel, sep="/"), dir), sep = "/") 
# --------------------- #


# --------------------- #
# load data
# --------------------- #
obs = read.csv(file.path(dir.in,"HB1603Seabirdmerged.csv")) 
obs = obs %>% mutate(long = as.numeric(as.character(long)),
                    lat = as.numeric(as.character(lat)),
                    time = ifelse(nchar(LMT) %in% 5, paste("0",substr(LMT,1,1),":",substr(LMT,2,3),":",substr(LMT,4,5),sep=""),
                                  ifelse(nchar(LMT) %in% 6, paste(substr(LMT,1,2),substr(LMT,3,4),substr(LMT,5,6),sep=":"),LMT))) %>%
  rename(source_transect_id = track.., date = LMT.date) %>% 
  mutate(datetime = as.POSIXct(paste(date,time," "),format="%m/%d/%Y %H:%M:%S")) %>% 
  arrange(datetime) %>%
  mutate(source_transect_id = na.locf(source_transect_id)) %>%
  dplyr::select(-GMT,-LMT,-GMT.date,-LMTDATETIME)
# --------------------- #


#---------------------#
# break apart obs and track
#---------------------#  
track = obs[obs$species %in% "",]
obs = obs[!obs$species %in% "",]
#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)

obs$original_species_tx = obs$species
obs = rename(obs, type = species)
obs$type = as.character(obs$type)

tmp <- !obs$type %in% spplist
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))

obs$type[obs$type %in% ""] = ""     
obs$type[obs$type %in% "DEDE"] = "CODO" # unknown    
obs$type[obs$type %in% "FLOT"] = "FLJE"  
obs$type[obs$type %in% "GLME"] = "LFPW"   
obs$type[obs$type %in% "LHSP"] = "UNSP" #Leach's/Hartcourt's storm-petrel   
obs$type[obs$type %in% "NPSS" & obs$comments %in% "Eurasian Collared-Dove"] = "EUCD" 
obs$type[obs$type %in% "PASS" & obs$comments %in% "Brown-headed Cowbird"] = "BHCO"   
obs$type[obs$type %in% "PASS" & obs$comments %in% "Baltimore Oriole"] = "BAOR"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Palm warbler"] = "PAWA"
obs$type[obs$type %in% "PASS" & obs$comments %in% "unid waterthrush"] = "UNPA"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Common Yellowthroat"] = "COYE"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Barn Swallow"] = "BARS"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Cliff Swallow"] = "CLSW"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Red-breasted Nuthatch landed briefly on canopy"] = "RBNU"
obs$type[obs$type %in% "PASS" & obs$comments %in% "Ovenbird, on foredeck at dawn"] = "OVEN"
obs$type[obs$type %in% "PASS" & obs$comments %in% "probable Tree Swallow"] = "TRES"
obs$type[obs$type %in% "PASS" & obs$comments %in% "same bird as yesterday, spent night on board"] = "UNPA"
obs$type[obs$type %in% "RAPT"] = "OSPR"   
obs$type[obs$type %in% "TRPE"] = "HEPE"  
obs$type[obs$type %in% "UNTR"] = "UNTB" 

# fix codes
sex=as.data.frame(rbind(c(1,"unknown"), c(2,"female"), c(3,"male"))); names(sex)=c("code","desc")
age=as.data.frame(rbind(c(1,"adult"), c(2,"subadult"))); names(age)=c("code","desc")
plumage=as.data.frame(rbind(c(1,"breeding"), c(2,"non-breeding"), c(3,"molting"), 
                            c(4,"unknown"),c(5,"mixed"))); names(plumage)=c("code","desc")
assoc=as.data.frame(rbind(c(2,"association with another individidual"), c(3,"assoc. unknown"), 
                          c(1,"solitary bird"),c(0,"none"),c(10,"fish shoal"),c(11,"cetaceans"),
                          c(13,"convergence zone"),c(14,"floating litter"),c(17,"floating weeds"),
                          c(26,"fishing vessel"))); names(assoc)=c("code","desc")
behavior=as.data.frame(rbind(c(1,"sitting"), c(10,"milling"),c(11,"pattering"),c(12,"porpoising"),
                             c(13,"diving"),c(14,"forage flight"),c(15,"unknown flight"),
                             c(16,"flocking"),c(17,"dead"),c(3,"following ship"),c(4,"feeding"),
                             c(5,"piracy"),c(6,"other"),c(7,"unknown"),c(8,"direct flight"),
                             c(9,"non-directional flight"))); names(behavior)=c("code","desc")
assoc$code=as.numeric(assoc$code)
age$code=as.numeric(age$code)
plumage$code=as.numeric(plumage$code)
sex$code=as.numeric(sex$code)
behavior$code=as.numeric(behavior$code)

obs$plumage[obs$plumage %in% c("4 1", "3 1")]=5
obs$plumage=as.numeric(obs$plumage)

obs = left_join(obs,assoc,by = c("association"="code")) %>% dplyr::select(-association) %>% rename(association = desc) %>%
  left_join(.,age,by = c("age"="code")) %>% dplyr::select(-age) %>% rename(age = desc) %>%
  left_join(.,sex,by = c("sex"="code")) %>% dplyr::select(-sex) %>% rename(sex = desc) %>%
  left_join(.,plumage,by = c("plumage"="code")) %>% dplyr::select(-plumage) %>% rename(plumage = desc) %>%
  left_join(.,behavior,by = c("behavior"="code")) %>% dplyr::select(-behavior) %>% rename(behavior = desc)
rm(age,sex,behavior,assoc,plumage)


db <- odbcDriverConnect('driver={SQL Server};server=ifw-dbcsqlcl1.fws.doi.net;database=NWASC;trusted_connection=true')
lu_behavior = sqlFetch(db, "lu_behaviors")
lu_age = sqlFetch(db,"lu_age")
lu_sex = sqlFetch(db,"lu_sex")
odbcClose(db)

obs = left_join(obs,lu_age,by = c("age"="age_ds")) %>% 
  left_join(.,lu_sex,by = c("sex"="sex_ds")) %>% 
  left_join(.,lu_behavior,by = c("behavior"="behavior_ds"))
rm(lu_age,lu_sex,lu_behavior)

# fix behaviors that don't match those in the look up table
obs = obs %>% mutate(behavior_id = ifelse(behavior %in% "pattering",42,behavior_id),
                     behavior_id = ifelse(behavior %in% "porpoising",25,behavior_id), #need to fix spelling in LU table
                     behavior_id = ifelse(behavior %in% "following ship",15,behavior_id),
                     behavior_id = ifelse(behavior %in% "forage flight",16,behavior_id),
                     behavior_id = ifelse(behavior %in% "unknown flight",13,behavior_id))

# fix association for following ship
obs = obs %>% mutate(association = as.character(association),
                     association = ifelse(behavior %in% "following ship" & association %in% c("solitary bird","none",NA),"BOAT",association))
#---------------------#


#---------------------#
# add start/stops to track
#---------------------#
track = track %>%
  mutate(type = ifelse(event %in% 1,"BEGCNT",ifelse(event %in% 3,"ENDCNT","WAYPNT")),
         id = 1:length(type))

# if there is <30 seconds between stop and new start on the same day and transect,
# remove that stop and start for simplicity since no real time or space has passed
s = track %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% 
  dplyr::select(id, type, date, source_transect_id, datetime)

ss = s %>% group_by(source_transect_id, date) %>% 
  summarize(start = first(id),stop=last(id)) %>% 
  ungroup %>% arrange(start)
track = track %>% mutate(hardstop = ifelse(id %in% ss$start | id %in% ss$stop,type,"WAYPNT"))

innerss = s %>%  mutate(dt = difftime(datetime,lag(datetime),units="secs")) %>% 
  filter(!id %in% ss$start, !id %in% ss$stop, type %in% "BEGCNT", dt>30)
track = track %>% mutate(hardstop = ifelse(id %in% innerss$id,type,hardstop))

track = track %>% mutate(hardstop = ifelse(id %in% s$id[which(s$id %in% innerss$id)-1],type,hardstop))
rm(ss,innerss,s)

# check if there are an even number of starts/stops per transect day
s = track %>% filter(hardstop %in% c("BEGCNT","ENDCNT")) %>% 
  dplyr::select(id, date, source_transect_id, hardstop) 
group_by(s,source_transect_id, date) %>% 
  summarize(nb = n()) %>% filter(nb %% 2!=0)

# fix transect
#x = select(track,type,datetime,source_transect_id,id,date,long,lat) %>% 
#  mutate(date=as.character(date)) %>%
#  filter(source_transect_id %in% 23 & date %in% "8/20/2016") %>% 
#  arrange(datetime)

track$type[track$id %in% 5148]="COMMENT"
track$hardstop[track$id %in% 5148]="WAYPNT"

# check that they're in the right order
s = track %>% filter(hardstop %in% c("BEGCNT","ENDCNT")) %>% 
  dplyr::select(id, date, source_transect_id, hardstop) %>% 
  mutate(newid = 1:length(hardstop))
if(all(s$hardstop=="BEGCNT" & s$newid %% 2!=0)==FALSE){
  s$id[s$hardstop=="BEGCNT" & s$newid %% 2==0]}else(print("All BEGCNT's are odd"))
if(all(s$hardstop=="ENDCNT" & s$newid %% 2==0)==FALSE){
  s$id[s$hardstop=="ENDCNT" & s$newid %% 2!=0]}else(print("All ENDCNT's are even"))
rm(s)

track = track %>% select(-type) %>% rename(type = hardstop)

# fix offline since used na.locf before fixing the beg/ends
s = track %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% 
  dplyr::select(id, date, source_transect_id, type) %>%
  mutate(newid=1:length(type))
ss = as.data.frame(matrix(nrow=length(s$type)/2,ncol=3,data=NA))
names(ss)=c("start","stop","transect")
ss = mutate(ss, start = s$id[s$type %in% "BEGCNT"], 
            stop = s$id[s$type %in% "ENDCNT"],
            transect = s$source_transect_id[s$type %in% "BEGCNT"]) %>% 
  rowwise %>% mutate(l = list(c(start:stop)))

track = mutate(track, source_transect_id = ifelse(track$id %in% unlist(ss$l),source_transect_id,NA),
               offline = ifelse(is.na(source_transect_id),1,0))
rm(s,ss)

# add offline to obs
obs = obs %>% arrange(datetime) %>%
  mutate(id = 1:length(type)) %>%
  bind_rows(., select(track,datetime,offline,type)) %>% 
  arrange(datetime) %>% mutate(offline = na.locf(offline)) %>% 
  filter(!type %in% c("BEGCNT","ENDCNT","WAYPNT"))
#---------------------#


#---------------------#
# export
#---------------------#
obs = select(obs, ID, date,lat,long,Beaufort,wind.speed,wind.direction,source_transect_id,
             type,number,distance,flight.direction,flight.height,angle,comments,time,
             original_species_tx,plumage,age_id,sex_id,behavior_id,offline)
track = select(track, ID, date,lat,long,Beaufort,wind.speed,wind.direction,source_transect_id,
             type,distance,comments,time,offline)
write.csv(obs, paste(dir.out, "NOAA_AMAPPS_2016_obs.csv",sep="/"))
write.csv(track, paste(dir.out, "NOAA_AMAPPS_2016_track.csv",sep="/"))
#---------------------#


#---------------------#
##plots
#x = sort(unique(track$source_transect_id))

#n=2
#test = bind_rows(obs[obs$source_transect_id %in% x[n],],
#                 track[track$source_transect_id %in% x[n],]) %>% arrange(datetime)
#y = sort(unique(test$date))

#t = test[test$date==y[3],]
#plot(t$long,t$lat,col="grey")
#points(t$long[t$type!="WAYPNT"],t$lat[t$type!="WAYPNT"],col="orange")
#points(t$long[t$type=="ENDCNT"],t$lat[t$type=="ENDCNT"],col="red",pch=15)
#points(t$long[t$type=="BEGCNT"],t$lat[t$type=="BEGCNT"],col="green",pch=16)
#---------------------#



