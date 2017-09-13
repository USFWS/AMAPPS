# ------------------------------------------------------------------------- #
## written by: Kaycee Coleman
## Oct. 2015
##
## This script should be run after processSurveyData_part1.R
## It will finalize the data for use
##
## This script was based off Jeff Lierness' ObsTrackEdit script
# ------------------------------------------------------------------------- #


# -------------------- #
# install packages
# -------------------- #
require(rgdal) # read shapefiles
require(parallel) # used to make a cluster
library(gmt) #geodist
require(geosphere) #dist2Line
library(sp) #SpatialLines from SpatialLinesDataFrame
library(FNN) #nearest neighbor
require(xlsx) # read excel file
require(RODBC) # odbcConnect
library(rgeos)
library(dplyr) # %>%
# -------------------- #


# -------------------- #
# Set dir
# -------------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder"
setwd(dir)
surveyFolder = "AMAPPS"
dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
yearLabel = "AMAPPS_2014_10"
survey = "2014 Fall AMAPPS"
surveyNbr = 15
#source(file.path(paste(dir,"DataProcessing/Code",sep=""),"surveyPrompt.R"))
dir.out <- paste(dir,"DataProcessing/Surveys", surveyFolder, yearLabel, sep = "/") 
# -------------------- #


# -------------------- #
# Link R functions
# -------------------- #
source(file.path(dir, "_Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "_Rfunctions"))
# -------------------- #


# -------------------- #
# Upload obstack 
# -------------------- #
#obstrack = read.csv(paste(dir.out, "obstrack_part1.csv",sep="/"))
load(paste(dir.out,"obstrack_part1.Rdata",sep="/")) # use obstrack_part1.csv if workspace corrupt
# -------------------- #


# -------------------- #
# redo because dir out changed when we load part1
# -------------------- #
dir <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder"
dir.out <- paste(dir,"DataProcessing/Surveys", surveyFolder, yearLabel, sep = "/") 
dir.in = paste(dir.out, "edited_shapefiles",sep="/")
# -------------------- #


# -------------------- #
### STEP 14: IMPORT EDITED SHAPEFILES
# -------------------- #
# These shapefiles have been edited from the original and
# flagged points deemed unworthy have been deleted
# flag 1: greater than 2 km from the defined transect line
#         there might be a typo in the transect for these files
# flag 2: greater than a right turn (bearing > 100) from the point prior
# flag 3: obstrack$transLat == 0 | obstrack$sbearing < 70 | (obstrack$sbearing > 110 & obstrack$sbearing < 250) | obstrack$sbearing > 290
# onLand: points on land

# check that all shapefiles have been edited and are in the edited shapefiles folder
fileNames = unique(obstrack$key)
shapefileNames = unique(unlist(strsplit(list.files(dir.in, pattern = "Crew"),".",fixed=T)))
shapefileNames = shapefileNames[nchar(shapefileNames)>4]
ifelse(all(sort(shapefileNames)==sort(fileNames)),
       "All shapefiles are edited",
       stop("You are missing a shapefile"))


# read in shapefiles
# combine into one dataframe
shapefileDataframe = as.data.frame(matrix(ncol=35,nrow=0))
colnames(shapefileDataframe) = c(colnames(obstrack)[3:35],"coords.x1","coords.x2")
BuildDataframe <- function(shapefile) {
  newShapefile = readOGR(dsn = dir.in, layer = shapefile)
  newShapefileDataframe <- as(newShapefile, "data.frame")
  shapefileDataframe = rbind(shapefileDataframe, newShapefileDataframe)
  return(shapefileDataframe)
}
shapefileDataframe = lapply(shapefileNames, function(x) BuildDataframe(x[1]))
shapefileDataframe = as.data.frame(do.call(rbind, shapefileDataframe))

# rename to compare to obstrack
shapefileDataframe = rename(shapefileDataframe, long = coords.x1, lat = coords.x2)

# remove duplicates that might have occured in this process
shapefileDataframe = shapefileDataframe[!duplicated(shapefileDataframe), ]

# compare old workspace with edited shapefiles to see what was deleted   
deletedPoints = rbind(shapefileDataframe, obstrack)
rm(obstrack, obs.i)
rownames(deletedPoints) = NULL #remove row.names
ind = paste(deletedPoints$key,deletedPoints$sec, deletedPoints$type, sep="_")
deletedPoints = deletedPoints[!(duplicated(ind) | duplicated(ind, fromLast=TRUE)),]
rm(ind)
deletedPoints = deletedPoints[!is.na(deletedPoints$day),]
# not using all rows for duplicates since some have NA or empty which come up as different rather than duplicate

# visually inspect that no files were deleted, and that edits look about right...
#plot(shapefileDataframe$long,shapefileDataframe$lat)
#points(deletedPoints$long,deletedPoints$lat,col="red")
ifelse(any(!deletedPoints$type %in% c("WAYPNT","BEGCNT","ENDCNT") & deletedPoints$offline == 0),
       stop("You deleted an online observation point, please investigate this before continuing"),
       "No online observations were deleted in your edits")

# investigate deleted points
# grab those that are species observaitons
# add if offline and was deleted by accident or change to offline
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")$spp_cd
sppcode <- sqlFetch(db, "lu_species")$species_type_cd # used later when breaking apart data
odbcClose(db)

if(any(deletedPoints$type %in% spplist)) {
  x = deletedPoints[deletedPoints$type %in% spplist,]
  deletedPoints = deletedPoints[!deletedPoints$type %in% spplist,]
  x$offline = 1
  shapefileDataframe = bind_rows(shapefileDataframe,x) 
  rm(x)
}

# corrections from investigation 
if (file.exists(paste(dir.out,"postGISEdits.R",sep="/"))) {
  source(paste(dir.out,"postGISEdits.R",sep="/"))}
# -------------------- #


# -------------------- #
### STEP 15: IF THERE ARE STILL DISTANCE ERRORS (e.g. labeled as wrong transect) 
# REDEFINE TRANSECT
# -------------------- #
if(any(shapefileDataframe$flag1==1)) {
  # find closest point to line 
  coordinates(shapefileDataframe) = cbind(shapefileDataframe$long, shapefileDataframe$lat)
  data = shapefileDataframe[shapefileDataframe$flag1==1,]
  data$dataChange = paste(data$dataChange, "; Changed transect from ", data$transect, sep="")
  
  trans <- readOGR(dsn = file.path(paste(dbpath, "GIS", sep="")), layer = "amapps_transects_new2014")
  if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
    trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  }
  
  m = gDistance(data, trans, byid=TRUE)
  data$transect = trans@data$latidext[as.numeric(apply(m, 2, function(X) rownames(m)[order(X)][1]))+1] # +1 since row starts at 0 instead of 1
  shapefileDataframe$transect[shapefileDataframe$ID %in% data$ID] = as.numeric(as.character(data$transect))
  rm(data, trans, m)
}
# -------------------- #


# -------------------- #
### STEP 16: ADD NECESSARY BEG/END ROWS TO GIS EDITED TRACK FILES
# this takes a while...
# -------------------- #
shapefileDataframe = as.data.frame(shapefileDataframe)
track.final = addBegEnd_GISeditObsTrack(shapefileDataframe)

# after inspection, corrections if BEG/END counts are added when not needed 
if (file.exists(paste(dir.out,"postGIS_BEGEND_Edits.R",sep="/"))) {
  source(paste(dir.out,"postGIS_BEGEND_Edits.R",sep="/"))}
# -------------------- #


# -------------------- #
### STEP 17: check condition code errors
# -------------------- #
track.final = conditionCodeErrorChecks(track.final)
# -------------------- #


# -------------------- #
### STEP 18: ADD REPLICATE COLUMN IF TRANSECT WAS FLOWN TWICE
# -------------------- #
# Create replicate column for if a transect was flown more than one day in a survey
track.final$replicate = 1
track.final$comment= as.character(track.final$comment)
ind = unique(paste(track.final$transect, track.final$seat, track.final$day,sep="_"))
if (any(duplicated(substr(ind,1,9)))) {
  track.final$replicate[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                          track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) & 
                          track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)] = 2
  track.final$comment[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                        track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) &
                        track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)] = 
    paste(track.final$comment[track.final$transect %in% substr(ind[duplicated(substr(ind,1,9))],1,6) &
                                track.final$seat %in% substr(ind[duplicated(substr(ind,1,9))],8,9) &
                                track.final$day %in% substr(ind[duplicated(substr(ind,1,9))],11,12)],
          "; Transect flown more than one day ", sep="")
}
rm(ind)
#
###### this code snippet needs work since a replicate could occur on the same day 
###### and since a transect can be flown on two different days without overlap (against protocal but happens)
# -------------------- #


# -------------------- #
### STEP 19: SAVE DELETED POINTS CSVs and DEFINE POINTS TO KEEP
# -------------------- #
# save deleted points as a .csv
write.csv(deletedPoints, file =paste(dir.out,"/", yearLabel, "_DeletedShapefilePoints.csv", sep=""), row.names=FALSE)
rm(deletedPoints)
# -------------------- #


# -------------------- #
### STEP 20: SAVE MARINE MAMMALS/ FISH DATA TO SEND TO NOAA AMAPPS
# ID: 2 (mammals), 3 (reptiles), 4 (fish) in NWASC_codes table
# -------------------- #
# GET SPECIES_INFORMATION TABLE 
# PULL MARINE DATA
tmp = track.final$type %in% c(as.character(spplist[sppcode=="2" | sppcode=="3" | sppcode=="4"]),
                              "HOCR","ALGA","BAIT","CAJE","KRILL","MACR","PMOW","RCKW","SARG","UNJE","ZOOP")
sort(unique(track.final$type[tmp]))
forNOAA = track.final[tmp,]
forNOAA = forNOAA[,!names(forNOAA) %in% c("dataError","transLat", "transLong", "bearing", "sbearing", "replicate")]
forNOAA.with.effort = track.final[track.final$key %in% forNOAA$key,]

write.csv(forNOAA.with.effort, file = paste(dir.out, "/", yearLabel, "_forNOAA.csv", sep=""), row.names=FALSE)
rm(forNOAA, forNOAA.with.effort)
# -------------------- #



# -------------------- #
# RENAME TO MATCH HEADERS IN DOCUMENTS
if(is.null(track.final$flightStatus) & is.null(track.final$FlightStatus)) {track.final$FlightStatus = NA}
track.final$SurveyNbr = surveyNbr
track.final = dplyr::select(track.final, -flag1, -flag2, -flag3, -onLand, -begend,
                            -coords.x1, -coords.x2, -transLat, -transLong)
# -------------------- #


# -------------------- #
# TRACK TABLE
# -------------------- #
track.final$type[track.final$type %in% c(""," ",NA)] = "WAYPNT" 
trackTbl = track.final%>%
  filter(type %in% c("WAYPNT","BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH")) %>%
  mutate(type = replace(type, type=="BEGSEG","BEGTRAN" ),
                           type = replace(type, type=="ENDSEG","ENDTRAN")) %>%
  arrange(SurveyNbr, transect, replicate, crew, seat, obs, year, month, day, sec, ID) %>% 
  select(-count,-index,-behavior)
write.csv(trackTbl, file =paste(dir.out,"/", yearLabel, "_Tracks.csv", sep=""), row.names=FALSE)
# -------------------- #


# -------------------- #
# ADD COVARIATES TO OBSERVATIONS (DISTANCE TO COAST)
# -------------------- #
track.final = track.final[!track.final$type %in% c("WAYPNT","COCH"),]
track.final = rename(track.final, Lat=lat, Long=long)

nnSearch <- function(inCoords, refCoords, covariate, toPull) {
  x = inCoords[,c("Lat","Long")]  
  ref = refCoords[,c("Lat","Long")]  # note names have to be the same
  nns <- get.knnx(ref, x, k=1) 
  matched <- covariate[nns$nn.index, toPull] # to pull = c("lat","lon") or "depth" etc. variable name in ref df
  return(matched)
}

# coastline
coastline <- read.csv(paste(dir,"/DataProcessing/coastline.csv",sep=""))
nnCoords = nnSearch(track.final, coastline, coastline, c("Long","Lat"))
track.final$nnLong = nnCoords$Long
track.final$nnLat = nnCoords$Lat
track.final$Dist2Coast_m = distVincentySphere(cbind(track.final$Long, track.final$Lat), 
                                              cbind(track.final$nnLong,track.final$Lat))
track.final$Dist2Coast_nm = track.final$Dist2Coast_m * 0.000539957
track.final = track.final[,!colnames(track.final) %in% c("nnLong","nnLat")]
rm(coastline, nnCoords)
# -------------------- #


# -------------------- #
# TRANSECT TABLE 
# -------------------- #
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(track.final, type %in% c("BEGSEG","BEGTRAN","BEGCNT")) %>%
  group_by(key) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(key, ID, start.stop.index)
new.key = left_join(track.final, break.at.each.stop, by=c("ID","key")) %>% 
  mutate(start.stop.index = na.locf(start.stop.index), 
         newkey = paste(key, start.stop.index, sep="_")) %>% select(-start.stop.index)
  
# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lon = lead(Long, default = last(Long), order_by = ID),
         lat = lead(Lat, default = last(Lat), order_by = ID)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(Long, Lat), c(lon, lat))) %>%
  select(-lon, -lat) %>% #mutate(distance = replace(distance, type=="BEGCNT", NA)) %>%
  mutate(condition = replace(condition, condition==0, NA)) %>%
  group_by(newkey) %>%  
  summarise(transect = first(transect),
            seat = first(seat),
            obs = first(obs),
            key = first(key),
            AvgCondition = as.numeric(weighted.mean(condition, distance, na.rm=TRUE)), 
            DistFlown_nm = sum(distance, na.rm=TRUE)*0.000539957,
            transect_distance_nb = sum(distance, na.rm=TRUE),
            start_dt = as.POSIXct(paste(first(year),first(month),first(day), sep="/")),
            end_dt = as.POSIXct(paste(last(year),last(month),last(day), sep="/")),
            start_sec = sec[row_number()==1], 
            end_sec  = sec[row_number()==n()],
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, transect, seat)

# group by old key
transectTbl = df %>% group_by(key) %>%
  summarise(transect = first(transect),
            seat = first(seat),
            obs = first(obs),
            AvgCondition = as.numeric(weighted.mean(AvgCondition, DistFlown_nm, na.rm=TRUE)), 
            DistFlown_nm = sum(DistFlown_nm),
            transect_distance_nb = sum(transect_distance_nb),
            start_dt = first(start_dt),
            end_dt = last(end_dt),
            start_sec = first(start_sec),
            end_sec = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb)) %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, transect, seat)

rm(break.at.each.stop, df, new.key)    

# Check that the output looks ok...
View(transectTbl)

# Check that there isn't an Av. condition of zero
if(any(transectTbl$AvgCondition %in% c(0,NA))) {
  write.csv(transectTbl [transectTbl $AvgCondition %in% c(0,NA),], file.path(dir.out, "AvgCondition.0.csv"),  row.names = FALSE, na = "")
  print("Average condition of zero. The following transects need to be investigated: ")
  transectTbl [transectTbl$AvgCondition %in% c(0,NA),]
}
# 
transectTbl = transectTbl %>% 
  mutate(weather_tx = round(AvgCondition),
         weather_tx = replace(weather_tx, weather_tx==1, "1 - worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==2, "2 - bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx==3, "3 - average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==4, "4 - good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==5, "5 - excellent observation conditions"))
write.csv(transectTbl, file = paste(dir.out, "/", yearLabel, "_transectTbl.csv", sep=""), row.names=FALSE)
# -------------------- #

# -------------------- #
# OBSERVATION TABLE
# -------------------- #
obsTbl = track.final %>% filter(!type %in% c("WAYPNT","BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH")) %>% 
  mutate(comment = paste(comment, dataChange, sep = "; "),
         weather_tx = round(condition),
         weather_tx = replace(weather_tx, weather_tx==1, "1 - worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==2, "2 - bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx==3, "3 - average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==4, "4 - good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==5, "5 - excellent observation conditions")) %>% 
  select(-dataChange) %>% 
  rename(longitude_dd = Long, latitude_dd = Lat, Time_secs = sec, surveyband = band, 
         Count = count, ConditionCode = condition, SpeciesId = type) %>% 
  arrange(ID)
write.csv(obsTbl, file = paste(dir.out,"/", yearLabel,"_Observations.csv", sep=""), row.names=FALSE)
# -------------------- #


# -------------------- #
### STEP 23: OUTPUT FINAL EDITED TRACK FILE (observations with track BEG and END records but not WAYPNT records)
# -------------------- #
# This includes all observations (even marine)
#obsTrackFinalOutput(track.final, yearLabel, dir.out)
write.csv(track.final, file =paste(dir.out,"/", yearLabel, "_Obstrack_Final.csv", sep=""), row.names=FALSE)
save.image(paste(dir.out,"obstrack_final.Rdata",sep="/"))
# -------------------- #


# -------------------- #
# NEXT STEP...
# TO IMPORT DATA INTO THE ACS DATABASE USE add2ACSDatabase.R
# THIS DATABASE IS IN TRANSITION
# A NEW SQL SERVER DATABASE HAS BEEN CREATED AND IS BEING TESTED
# -------------------- #





