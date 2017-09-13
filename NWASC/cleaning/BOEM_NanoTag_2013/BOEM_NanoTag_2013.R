# --------------------- #
# Quality control BOEM NanoTag 2013 data
# from FWS MB
# prepare it forimport into the NWASC
#
# dataset_id 145 = Aug. 18
# dataset_id 176 = Sep. 04
# dataset_id 177 = Sep. 06
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(rgdal) # read shapefiles
require(dplyr)
#library(maptools)
require(foreign) # read dbf
library(zoo) #na.locf
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "BOEM_NanoTag_Study"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
track.dir <- paste(dir.in, "NanoTag_aerial_gps_tracks_2013", sep="/")
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
data2 = read.csv(file.path(dir.in,"Tern_aerial_survey_NS_2013.csv")) 

colnames(data2) = tolower(names(data2))

# change data2 coordinates from zone 19N
library(rgdal)
coordinates(data2) = ~x_19n + y_19n
sputm <- SpatialPoints(data2, proj4string=CRS("+proj=utm +zone=19 +datum=WGS84"))  
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))
spgeo = as.data.frame(spgeo)     
colnames(spgeo)=c("longitude","latitude")
# combine data2 & lat lon
data2 = as.data.frame(data2)
data2 = cbind(data2,spgeo)
rm(spgeo,sputm)

# format
data2 = dplyr::select(data2, -x_19n, -y_19n, -objectid,-globalid) %>% rename(behavior = behav) %>%
  mutate(date = sapply(strsplit(as.character(data2$date_time_est)," "),head,1),
         time = sapply(strsplit(as.character(data2$date_time_est)," "),tail,1)) 

#change species
data2$original_species_tx = data2$spp
data2$spp="UNTE"

#change behavior
data2$behavior_id = ifelse(data2$behavior=="fly",13,16) #13=fly, 16=forage
data2 = rename(data2, comments=behavior)
data2$date_time_est = as.POSIXct(paste(as.Date(data2$date, format="%m/%d/%Y"), data2$time,sep=" "),fomat= "%m/%d/%y %H:%M")

#break data
data18=data2[1:61,]
data04=data2[62:78,]
data06=data2[79:84,]
rm(data2)
#--------#


#--------#
# load tracks
#--------#
# waypoints are in data above for half of the data
track04 = read.dbf(file.path(track.dir, "Track04Sep13.dbf"), as.is=FALSE)
track06 = read.dbf(file.path(track.dir, "Track06Sep13.dbf"), as.is=FALSE)
track18 = read.dbf(file.path(track.dir, "Track18Aug13.dbf"), as.is=FALSE)
track04$date_time_est = as.POSIXct(track04$time_)-14400
track06$date_time_est = as.POSIXct(track06$time_)-14400
track18$date_time_est = as.POSIXct(track18$time_)-14400

#type
track04$type = ifelse(track04$new_seg=="True","BEGCNT","WAYPNT")
track04$type[which(track04$type=="BEGCNT")-1]="ENDCNT"
track04$type[846]="ENDCNT"

track06$type="WAYPNT"
track06$type[1]="BEGCNT"
track06$type[1020]="ENDCNT"

track18$type = ifelse(track18$new_seg==-1,"BEGCNT","WAYPNT")
track18$type[1]="BEGCNT"
track18$type[which(track18$type=="BEGCNT")-1]="ENDCNT"
track18$type[281]="ENDCNT"
#break coast effort as separate transect
track18$type[103]="BEGCNT"
track18$type[102]="ENDCNT"
track18 = arrange(track18, date_time_est) %>% mutate(id = 1:dim(track18)[1])

track18$transect = ifelse(track18$OBJECTID %in% c(14:115),"coastal","nearshore/offshore")
data18 = arrange(data18, date_time_est) %>% mutate(id = 1:dim(data18)[1])
track18 = arrange(track18, date_time_est) %>% mutate(id = 1:dim(track18)[1])
track18$type[track18$id %in% c(250,254)]="COMMENT"
xx = bind_rows(data18,select(track18[track18$type %in% c("BEGCNT","ENDCNT"),],type,date_time_est,transect)) %>% arrange(date_time_est)
xx$transect = na.locf(xx$transect)
data18 = left_join(data18, select(xx,spp,id,transect),by=c("id","spp"))
data18$offline = 0 
data18$offline[data18$id %in% c(17,21,54,55,57:61)] = 1

data04 = arrange(data04,date_time_est) %>%  mutate(id=1:length(date_time_est),offline=0)
xx = bind_rows(data04,select(track04[track04$type %in% c("BEGCNT","ENDCNT"),],type,date_time_est)) %>% arrange(date_time_est)
data04$offline[data04$id %in% c(1:3)]=1

data06 = arrange(data06,date_time_est) %>%  mutate(id=1:length(date_time_est),offline=0)
xx = bind_rows(data06,select(track06[track06$type %in% c("BEGCNT","ENDCNT"),],type,date_time_est)) %>% arrange(date_time_est)

rm(xx)

#fix names
data04 = data04 %>% mutate(transect = ifelse(offline==0,"transect04",NA)) %>% 
  rename(type=spp)
data06 = data06 %>% mutate(transect = ifelse(offline==0,"transect06",NA)) %>% 
  rename(type=spp)
data18 = data18 %>% rename(type=spp)
track18 = track18 %>% 
  rename(date = ltime) %>% 
  mutate(time = sapply(strsplit(as.character(date_time_est)," "), tail, 1)) %>% 
  dplyr::select(Latitude,Longitude,type,id,transect,altitude,date,time) 
track04 = track04 %>% 
  rename(date = ltime) %>% arrange(date_time_est) %>% 
  mutate(time = sapply(strsplit(as.character(date_time_est)," "), tail, 1),
         transect = "transect04",
         id = 1:length(transect)) %>% 
  dplyr::select(Latitude,Longitude,type,id,transect,altitude,date,time,id) 
track06 = track06 %>% 
  rename(date = ltime) %>% arrange(date_time_est) %>% 
  mutate(time = sapply(strsplit(as.character(date_time_est)," "), tail, 1),
         transect = "transect06",
         id = 1:length(transect)) %>% 
  dplyr::select(Latitude,Longitude,type,id,transect,altitude,date,time,id) 

# fix dates
data04$date = as.Date(data04$date,format="%m/%d/%Y")
data06$date = as.Date(data06$date,format="%m/%d/%Y")
data18$date = as.Date(data18$date,format="%m/%d/%Y")
#--------#


#------------------#
# export data
#------------------#
write.csv(data04,paste(dir.out,"data04",sep="/"),row.names=FALSE)
write.csv(data06,paste(dir.out,"data06",sep="/"),row.names=FALSE)
write.csv(data18,paste(dir.out,"data18",sep="/"),row.names=FALSE)
write.csv(track04,paste(dir.out,"track04",sep="/"),row.names=FALSE)
write.csv(track06,paste(dir.out,"track06",sep="/"),row.names=FALSE)
write.csv(track18,paste(dir.out,"track18",sep="/"),row.names=FALSE)
#------------------#


#--------#
#load transect design
#--------#
#transect0406 = readOGR(dsn = track.dir, layer = "Aerial_Tran_04_06Sep13")
#transect18 = readOGR(dsn = track.dir, layer = "Aerial_Tran_18Aug13")

#aug_sldf <- spTransform(transect18, "+proj=longlat +datum=WGS84")
#sep_sldf <- spTransform(transect0406, "+proj=longlat +datum=WGS84")
#---------------------#

#x = track06
#y = data06
#plot(x$Longitude,x$Latitude,col="grey")
#points(x$Longitude[x$type=="ENDCNT"],x$Latitude[x$type=="ENDCNT"],col="red",pch=15,cex=1.5)
#points(x$Longitude[x$type=="BEGCNT"],x$Latitude[x$type=="BEGCNT"],col="darkgreen",pch=15,cex=1.5)
#points(y$longitude,y$latitude,col="orange",pch=16)
#points(y$longitude[y$offline==1],y$latitude[y$offline==1],col="purple",pch=16)

#plot(x$Longitude[x$transect=="coastal"],x$Latitude[x$transect=="coastal"],col="grey")
#points(y$longitude[y$transect=="coastal"],y$latitude[y$transect=="coastal"],col="orange",pch=16)
#points(x$Longitude[x$type=="ENDCNT" & x$transect=="coastal"],x$Latitude[x$type=="ENDCNT" & x$transect=="coastal"],col="red",pch=15,cex=1.5)
#points(x$Longitude[x$type=="BEGCNT"& x$transect=="coastal"],x$Latitude[x$type=="BEGCNT"& x$transect=="coastal"],col="darkgreen",pch=15,cex=1.5)

#plot(x$Longitude[x$transect=="nearshore/offshore"],x$Latitude[x$transect=="nearshore/offshore"],col="grey")
#points(y$longitude[y$transect=="nearshore/offshore"],y$latitude[y$transect=="nearshore/offshore"],col="orange",pch=16)
#points(y$longitude[y$transect=="nearshore/offshore" & y$offline==1],y$latitude[y$transect=="nearshore/offshore" & y$offline==1],col="purple",pch=16)
#points(x$Longitude[x$type=="ENDCNT" & x$transect=="nearshore/offshore"],x$Latitude[x$type=="ENDCNT" & x$transect=="nearshore/offshore"],col="red",pch=15,cex=1.5)
#points(x$Longitude[x$type=="BEGCNT"& x$transect=="nearshore/offshore"],x$Latitude[x$type=="BEGCNT"& x$transect=="nearshore/offshore"],col="darkgreen",pch=15,cex=1.5)
