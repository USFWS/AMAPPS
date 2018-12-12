# ---------------------------------------------------------------------------- #
# processSurveyData_part1.R
# Author: Jeffery Leirness
# Date Created: 2015-03-20
# Edited by: Kaycee Coleman, 2016
#
# Description: This program reads in the pilot and observer raw observation 
# files and creates a header row. It then checks for general errors & 
# BEGSEG/ENDSEG errors and outputs a .csv file documenting these errors 
# (ObsFiles_Errors.csv). It then fixes the observation file errors, reads in 
# the pilot and observer raw track files and creates a header row, compares 
# the track files to the observation files, and outputs the edited track 
# files containing only the survey segments.
# ---------------------------------------------------------------------------- #

#processSurveyData_part1 <- function(dir.in, dir.out, errfix.file, py.exe) {

# ----------------------------- #
# LOAD PACKAGES 
# ----------------------------- #
require(geosphere) # used in fixSeconds function
require(parallel) # used to make a cluster
require(rgdal) # for writeOGR
require(zoo) # fill in missing points
require(dplyr) # %>% 
require(RODBC) # connect to database
require(odbc) # connect to database
require(ggplot2) #ggplot
# ----------------------------- #


# ----------------------------- #
# DEFINE SURVEY, CHANGE THIS!!!
# ----------------------------- #
surveyFolder = "AMAPPS"
yearLabel = "AMAPPS_2018_08"
# ----------------------------- #


# ----------------------------- #
# SET INPUT/OUTPUT DIRECTORY PATHS
# ----------------------------- #
dir <- paste("//ifw-hqfs1/MB SeaDuck/", surveyFolder, sep="")
setwd(dir)
dir.in <- paste(dir, "raw_data", yearLabel, sep = "/") 
dir.out <- paste(dir, "clean_data", yearLabel, sep = "/") 
gis.path = paste(dir, "amapps_gis", sep = "/") 
  
# SOURCE R FUNCTIONS
source(file.path(dir, "code/cleaning_raw_data/Rfunctions/sourceDir.R"))
sourceDir(file.path(dir, "code/cleaning_raw_data/Rfunctions"))

# SET PATH TO R FILE THAT FIXES DATA ERRORS
errfix.file <- file.path(dir.out, paste(yearLabel, "_ObsFilesFix.R", sep = ""))

# SET PATH TO python.exe FILE
#py.exe = "E:/Python27/ArcGISx6410.2/python.exe"
#py.exe = "C:/Python27/ArcGIS10.3/python.exe" #32 bit
py.exe = "C:/Python27/ArcGISx6410.3/python.exe" #64 bit

  # SET TIMER
  #ptm <- proc.time()
  
  
  # STORE CREW FOLDER AND FILENAME REFERENCES
  crews <- list.files(dir.in, pattern = "Crew")
  # ----------------------------- #  
  
  # ---------------------------------------------------------------------------- #
  # STEP 1: READ IN RAW OBSERVATION DATA
  # ---------------------------------------------------------------------------- #
  # CHECK IF THERE ARE RAW DATA FILES TO SPLIT/FIX SO JEFF'S SCRIPTS RUN SMOOTHER 
  if (length(list.files(dir.out, pattern = "FixFile")) == 1) {
    source(paste(dir.out, list.files(dir.out, pattern = "FixFile"), sep = "/"))
  }
  #
  obsfiles <- list.files(dir.in, pattern = "_birds", recursive = TRUE, full.names = TRUE) #changed from "_birds.txt"
  obs <- lapply(setNames(obsfiles, basename(obsfiles)), getObsFiles)
  obs <- lapply(obs, function(x) data.frame(cbind(x, "crew" = as.character(unlist(strsplit(basename(dirname(x$file)), "_"))[1]))))
  
  # SHOW WHICH OBSERVATION FILES ARE AVAILABLE
  out.obsfiles <- gsub(dir.in, "", obsfiles)
  
  # CREATE BAND AND BEHAVIOR COLUMNS
  obs <- lapply(obs, createBandBehavior)
  
  # ORGANIZE OBSERVATION DATA INTO A DATA FRAME; CREATE CREW COLUMN
  obs <- do.call(rbind.data.frame, obs)
  obs$crew <- as.character(obs$crew)
  row.names(obs) <- NULL
  
  # QUICK LOOK AT NUMBER OF RECORDS AVAILABLE
  out.obstab1 <- table(obs$crew, obs$seat)
  out.obstab1
  out.obstab2 <- table(obs$obs, obs$seat)
  out.obstab2
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 2: READ IN RAW TRACK DATA
  # ---------------------------------------------------------------------------- #
  trackfiles <- list.files(dir.in, pattern = "_track", recursive = TRUE, #changed from "_track.txt"
                           full.names = TRUE)
  track <- lapply(setNames(trackfiles, basename(trackfiles)), getTrackFiles)
  #track <- lapply(track, function(x) data.frame(cbind(x, "crew" = unlist(strsplit(basename(dirname(dirname(x$file))), "_"))[1])))
  track <- lapply(track, function(x) data.frame(cbind(x, "crew" = unlist(strsplit(basename(dirname(x$file)), "_"))[1])))
  
  # SHOW WHICH TRACK FILES ARE AVAILABLE
  out.trackfiles <- gsub(dir.in, "", trackfiles)
  
  # ORGANIZE TRACK DATA INTO A DATA FRAME; CREATE CREW COLUMN
  track <- do.call(rbind.data.frame, track)
  track$crew <- as.character(track$crew)
  
  # QUICK LOOK AT NUMBER OF RECORDS AVAILABLE
  out.tracktab <- table(track$crew, track$seat)
  out.tracktab
  
  # read in design
  design = readOGR(gis.path,"amapps_transects_new2014")
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 3: OUTPUT COAST SURVEY DATA; FIX OBSERVATION FILE ERRORS
  # ---------------------------------------------------------------------------- #
  obs <- commonErrors(obs)
  #obs <- fixMixed(obs) # pull apart MIXD obs
  
  if (!file.exists(errfix.file)) {
    warning("Error fix R file is missing and will not be sourced.")
  } else source(errfix.file, local = TRUE)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 4: CHECK OBSERVATION FILES FOR ERRORS, DOCUMENT IN .CSV FILE
  # ---------------------------------------------------------------------------- #
  obs <- errorCheckObsFiles(obs, dir.out, error.flag = TRUE)
  
  # STOP IF ERRORS STILL EXIST IN OBSERVATION FILES
  if (obs[["errorStatus"]] == 1) {
    stop("Errors still exist in observation files. These must be fixed before continuing.")
  } else obs <- obs[["data"]]
  
  # SUMMARIZE CERTAIN DATA COLUMNS
  tmp <- !is.na(obs$count) & obs$offline == 0 & 
    !(obs$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH"))
  if (!is.null(obs$band)) {
    out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count", "band")])
  } else {
    out.obssum <- summary(obs[tmp, c("lat", "long", "sec", "GPSerror", "count")])
  }
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 5: RE-ORGANIZE OBSERVATION AND TRACK DATA INTO SEPARATE LISTS CONTAINING 
  #         UNIQUE DATA FRAMES - ONE DATA FRAME FOR EACH COMBINATION OF OBSERVER 
  #         AND DAY
  # ---------------------------------------------------------------------------- #
  # RE-ORGANIZE OBSERVATION DATA
  obs$key <- paste(obs$crew, obs$seat, obs$year, obs$month, obs$day, sep = "_")
  obs <- split(obs, list(obs$key))
  
  # RE-ORGANIZE TRACK DATA
  track$key <- paste(track$crew, track$seat, track$year, track$month, track$day, sep = "_")
  track <- split(track, list(track$key))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 6: FIX MISSING SECONDS VALUES IN OBSERVATION FILES
  # ---------------------------------------------------------------------------- #
  obs <- lapply(setNames(names(obs), names(obs)), function(x) fixSeconds(obs[[x]], track[[x]]))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 7: ADD BEG/END POINTS WHERE NEEDED IN OBSERVATION FILES
  # ---------------------------------------------------------------------------- #
  #obs <- suppressMessages(lapply(obs, addBegEnd_obs))
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 8: COMBINE OBSERVATION FILES & TRACK FILES, OUTPUT EDITED
  #         TRACK FILES CONTAINING ONLY SURVEY SEGMENTS (WITH OBSERVATIONS)
  # ---------------------------------------------------------------------------- #
  alt.list = names(obs)[!names(obs) %in% names(track)]
  
  if(length(alt.list)>0) {
    if(any(substr(alt.list, 10, 10) %in% "l")) { 
      cat("\
          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\
          !!!!!!!!! THERE IS A PILOT FILE MISSING !!!!!!!!!!\
          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")
      } else {
        alt.list = gsub("_rf_","_lf_",alt.list)
        alt.tracks = track[names(track) %in% alt.list]
        alt.tracks = do.call(rbind.data.frame, alt.tracks)
        alt.tracks$key = gsub("_lf_", "_rf_", alt.tracks$key)
        alt.tracks$seat = "rf"
    
        track = do.call(rbind.data.frame, track)
        obs = do.call(rbind.data.frame, obs)
        obstrack = bind_rows(obs, track, alt.tracks) %>% arrange(key, sec)
        rm(alt.tracks)}
    } else {
      track = do.call(rbind.data.frame, track)
      obs = do.call(rbind.data.frame, obs)
      obstrack = bind_rows(obs, track) %>% arrange(key, sec)}
  
  # alt is the alternate track to use if there isn't one supplied, like use lf if rf track not available
  # this took too long -> rewrote but leaving in case of error with next data set
  #obstrack <- lapply(setNames(names(obs), names(obs)), function(x) {
  #  alt <- names(track)[sapply(strsplit(names(track), "_"), 
  #                             function(y) all(y[-2] == strsplit(x, "_")[[1]][-2]))]
  #  combineObsTrack(obs[[x]], track[[x]], track[[alt[alt != x][1]]])
  #})
  #obstrack <- do.call(rbind.data.frame, obstrack)
  
  obstrack <- arrange(obstrack, crew, seat, year, month, day, sec, index)
  row.names(obstrack) <- NULL
  obstrack$ID <- as.numeric(row.names(obstrack))
  rm(obs, track, trackfiles, obsfiles)

  # This file is for obvious track errors that should not be included in GIS file
  # or transects where no observations occurred but only one observer recoreded the BEG and END
  # This will help cut down on manually deleting the points, however you need to visually
  # inspect the data to find obvious errors
  if (file.exists(paste(dir.out,"postObstrackEdits.R",sep="/"))) {
    source(paste(dir.out,"postObstrackEdits.R",sep="/"))}
  
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 9: RELABEL TRANSECTS
  # ---------------------------------------------------------------------------- #
  # fix transect points first that have NA for transect due to how the data now comes to us
  # cut track lines before BEGCNT and after ENDCNT for this process (all transit data)
  # and cut offline obs since we don't need to check their transect
  # both can be added back later
  starts = filter(obstrack, type %in% c("BEGCNT"), !offline %in% 1) %>%
    group_by(key,transect) %>% 
    arrange(sec) %>%
    mutate(start.stop.index = seq(1:n())) %>% 
    ungroup() %>% 
    select(key, sec, type, start.stop.index,transect) %>% 
    arrange(key,transect,sec,start.stop.index)
  stops = filter(obstrack, type %in% c("ENDCNT"), !offline %in% 1) %>%
    group_by(key,transect) %>% 
    arrange(sec) %>%
    mutate(start.stop.index = seq(1:n())) %>% 
    ungroup() %>% 
    select(key, sec, type, start.stop.index, transect) %>% 
    arrange(key,transect,sec,start.stop.index)
  breaks = bind_rows(starts,stops) %>% arrange(key,transect,sec,start.stop.index) %>% 
    mutate(break.key = paste(key,transect,start.stop.index,sep="_")) %>% group_by(break.key) %>%
    summarise(start.sec = first(sec), stop.sec=last(sec), 
              transect=first(transect), key=first(key))
rm(starts, stops)

  cl <- makeCluster(as.numeric(detectCores()-1))
   clusterExport(cl, "breaks", envir = environment())
   invisible(clusterEvalQ(cl, c(fill.trans <- function(k, s) {
     y = breaks$transect[breaks$key %in% k & breaks$start.sec <= s & breaks$stop.sec >= s]
     if(!length(y) %in% 1){y = NA}
     return(y)
   })))
   obstrack$transect2 = parRapply(cl, obstrack, function(x) fill.trans(x[30],x[12]))
   stopCluster(cl)
   
   obstrack$transect[is.na(obstrack$obs) & !obstrack$offline %in% 1] = obstrack$transect2[is.na(obstrack$obs) & !obstrack$offline %in% 1] 
   obstrack$dataChange[is.na(obstrack$obs) & !is.na(obstrack$transect)] = "Added TRANSECT based on observers BEG/END times"
   
   obstrack = obstrack %>% arrange(ID, key, sec) %>%
     mutate(ss = NA, 
            ss = replace(ss, type %in% "BEGCNT" & !offline %in% 1,1),
            ss = replace(ss, type %in% "ENCNT" & !offline %in% 1,2),
            ss = replace(ss, ID < ID[type %in% "BEGCNT" & !offline %in% 1][1], 2),
            ss = na.locf(ss),
            ss = replace(ss, type %in% "ENDCNT",1)) 
   transit = obstrack %>% filter(ss %in% 2 | offline %in% 1) %>% dplyr::select(-ss)
   obstrack = obstrack %>% filter(ss %in% 1 & !offline %in% 1) %>% dplyr::select(-ss)
  
   # group by key to remove obvious transit info
   obstrack = obstrack %>% 
    group_by(key) %>% arrange(ID) %>% 
     mutate(offline = replace(offline, ID < ID[type %in% "BEGCNT" & !offline %in% 1][1], 1),
            offline = replace(offline, ID > ID[type %in% "ENDCNT" & !offline %in% 1][length(ID[type %in% "ENDCNT" & !offline %in% 1])], 1)) %>% 
            #transect = ifelse(!offline %in% 1,na.locf(transect),NA)) %>% 
     dplyr::select(-transect2)
   transit = bind_rows(transit,filter(obstrack, offline %in% 1)) %>% arrange(ID)
   undefinedTracks = obstrack %>% filter(is.na(transect)) 
   obstrack = obstrack %>% filter(!is.na(transect) & !offline %in% 1) 
   
  # load known transects
   trans <- readOGR(dsn = gis.path, layer = "amapps_transects_new2014")
  if (proj4string(trans) != "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") {
    trans <- spTransform(trans, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  }

  # CALCULATE DISTANCE FROM EACH POINT TO MASTER TRANSECT FILE
  # THIS PROCESS EMPLOYS PARALLEL COMPUTING TO DECREASE PROCESSING TIME
  # find closest point to line 
  obstrack = obstrack[,c("lat", "long", "transect", 
                         colnames(obstrack)[!colnames(obstrack) %in% c("lat", "long", "transect")])]
  strt<-Sys.time(); 
  cl <- makeCluster(as.numeric(detectCores()-1))
  clusterExport(cl, "trans", envir = environment())
  invisible(clusterEvalQ(cl, c(library(geosphere),
                               subFunc <- function(lat, lon, code) {
                                 a = which(trans$latidext %in% code)
                                 if(length(a)>0) {
                                   subTrans = trans[a,]
                                   ab = dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), 
                                                  line = subTrans, distfun = distVincentyEllipsoid)
                                   out = c(ab, a)
                                   } else out = c(NA,NA,NA,NA,NA)
                                  return(out)
                               })))
    
  d <- parRapply(cl, obstrack, function(x) subFunc(x[1],x[2],x[3]))
  stopCluster(cl)
  d <- matrix(unlist(d), ncol = 5, byrow = TRUE) # distance(m), long, lat, code
  print(Sys.time()-strt)
     
  # POINTS GREATER THAN 2km FROM DEFINED TRANSECT ON MASTER TRANSECT FILE ARE FLAGGED
  # THESE ARE MOST LIKELY TYPOS OR MISIDENTIFIED TRANSECTS
  obstrack$transLat <- trans$latid[d[,5]] 
  obstrack$transLong <- trans$label[d[,5]]
  obstrack$transTransect <- as.character(trans$latidext[d[,5]])
  obstrack$transDist <- d[,1]
  obstrack$flag1 <- ifelse(d[, 1] > 2000 | is.na(d[, 1]), 1, 0)
  
  # FOR THOSE FLAGGED TRANSECTS, FIND WHICH LINE THEY ARE CLOSET TO AND CHANGE THAT TRANSECT CODE
  strt<-Sys.time(); 
  cl <- makeCluster(as.numeric(detectCores()))
  clusterExport(cl, "trans", envir = environment())
  invisible(clusterEvalQ(cl, c(library(geosphere),
                               subFunc <- function(lat, lon) {
                                 ab = dist2Line(p = cbind(as.numeric(lon),as.numeric(lat)), 
                                                 line = trans, distfun = distVincentyEllipsoid)
                                 out = ab
                                 return(out)})))
  
  d <- parRapply(cl, obstrack[obstrack$flag1 %in% 1,], function(x) subFunc(x[1],x[2]))
  stopCluster(cl)
  d <- matrix(d, ncol = 4, byrow = TRUE) # distance(m), long, lat, code
  print(Sys.time()-strt)
  
  obstrack$transLat[obstrack$flag1 %in% 1] <- trans$latid[d[,4]] 
  obstrack$transLong[obstrack$flag1 %in% 1] <- trans$label[d[,4]]
  obstrack$transTransect[obstrack$flag1 %in% 1] <- as.character(trans$latidext[d[,4]])
  obstrack$transDist[obstrack$flag1 %in% 1] <- d[,1]
  obstrack$flag1b=NA
  obstrack$flag1b[obstrack$flag1 %in% 1] <- ifelse(d[, 1] > 2000, 1, 0) #check if it's still too far
  
  # FIND CLOSEST LINE FOR FLAGGED TRANSECT POINT AND 
  # RELABEL TRANSECTS ACCORDING TO MASTER TRANSECT FILE
  # RECORD CHANGE
  obstrack$dataChange = as.character(obstrack$dataChange)
  if(any(obstrack$transect[obstrack$flag1 %in% 1 & obstrack$flag1b %in% 0] != as.character(trans$latidext[d[,4]]))) {
    obstrack$dataChange[obstrack$flag1 %in% 1 & obstrack$flag1b %in% 0] <-  paste(obstrack$dataChange[obstrack$flag1 %in% 1 & obstrack$flag1b %in% 0],
                                                     "; Changed TRANSECT from ", 
                                                     obstrack$transect[obstrack$flag1==1], sep="")
    obstrack$transect[obstrack$flag1 %in% 1 & obstrack$flag1b %in% 0] <- obstrack$transTransect[obstrack$flag1 %in% 1 & obstrack$flag1b %in% 0]
  }
  rm(d,trans)
 
  # REPORT BACK WHAT WAS CHANGED 
  checkChange = select(obstrack,transect,dataChange,flag1) %>% 
    filter(flag1==1) %>% select(-flag1) %>% 
    filter(grepl("TRANSECT",dataChange)) %>%
    mutate(oldTransect = sapply(strsplit(dataChange, "Changed TRANSECT from "),tail,1)) %>% 
    select(-dataChange)  %>%
    filter(oldTransect != transect)
    
  ifelse(!is.na(checkChange[1,1]),
    list(checkChange),"No Transects were changed in this check")

  # MAKE SURE THERE ARE STILL 2 OBSERVERS ONCE THE TRANSECT HAS BEEN CORRECTED (AND IN GENERAL)
  numObs = select(obstrack,transect,obs) %>% 
    group_by(transect,obs) %>% filter(row_number()==1) %>% group_by(transect) %>%
    summarise(numberObs = length(transect)) %>% arrange(transect)
  if(any(numObs$numberObs==1)) {
      paste("Transect ", numObs$transect[numObs$numberObs==1], " only has one observer and needs to be checked")}
  rm(checkChange, numObs)
  # If there is only one observer and you solve how/why this occurred it is recommended to add edits to the 
  # postObstrackEdits.R and rerun from that step foward (if the error was not due to an earlier step)
  
  # check that there are still an even number of BEG/END
  obstrack %>% filter(type %in% c('BEGCNT','ENDCNT')) %>% group_by(key,transect) %>%
    summarize(n=n()) %>% filter(n %% 2 != 0)
  
  # This file is for obvious transect errors 
  if (file.exists(paste(dir.out,"postTransEdits.R",sep="/"))) {
    source(paste(dir.out,"postTransEdits.R",sep="/"))}
  
  # group by transect and remove transit and add transect to track points
  transit = bind_rows(transit,filter(obstrack,offline %in% 1))
  obstrack = bind_rows(obstrack, undefinedTracks) %>%
    arrange(key,sec, index,ID) %>%
    filter(!offline %in% 1) %>%
    mutate(transect = ifelse(is.na(transect),na.locf(transect),transect),
           transect.temp = transect) %>%
    group_by(key,transect.temp) %>% arrange(ID) %>%
    mutate(offline = replace(offline, ID < ID[type %in% "BEGCNT" & !offline %in% 1][1], 1),
           offline = replace(offline, ID > ID[type %in% "ENDCNT" & !offline %in% 1][length(ID[type %in% "ENDCNT" & !offline %in% 1])], 1),
           transect = ifelse(!offline %in% 1,na.locf(transect),transect),
           transect = ifelse(offline %in% 1,NA,transect)) %>% 
    dplyr::select(-transect.temp)
 
  # This file is for obvious transect errors 
  if (file.exists(paste(dir.out,"postComboEdits.R",sep="/"))) {
    source(paste(dir.out,"postComboEdits.R",sep="/"))}
  transit = bind_rows(transit,filter(obstrack, offline %in% 1)) %>% arrange(ID)
  obstrack = obstrack %>% filter(!offline %in% 1)
  rm(undefinedTracks)
  
  # group by segments and remove transit and add transect to track points
  break.at.each.stop = filter(obstrack, type %in% c("BEGCNT")) %>%
    group_by(key,transect) %>% 
    mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
    select(ID, key, start.stop.index)
  test = left_join(obstrack,break.at.each.stop,by = c("key","ID")) %>%
    arrange(key,sec) %>%
    muatate(transect.temp = paste(transect, break.at.each.stop,sep="_"),
            transect.temp = na.locf(transect.temp)) %>% 
    group_by(key,transect.temp) %>% arrange(ID) %>%
    mutate(offline = replace(offline, ID < ID[type %in% "BEGCNT" & !offline %in% 1][1], 1),
           offline = replace(offline, ID > ID[type %in% "ENDCNT" & !offline %in% 1][length(ID[type %in% "ENDCNT" & !offline %in% 1])], 1),
           transect = ifelse(!offline %in% 1,na.locf(transect),transect),
           transect = ifelse(offline %in% 1,NA,transect)) %>% 
    dplyr::select(-transect.temp)
  
    # remove if points were investigated and fixed
  obstrack = dplyr::select(obstrack,-transLat,-transLong,-transTransect,-transDist,-flag1) %>% 
    rename(flag1=flag1b)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 10: FLAG POINTS FOR FURTHER INVESTIGATION FOR OTHER ERRORS
  # ---------------------------------------------------------------------------- #
  obstrack <- arrange(obstrack,ID)
  obstrack$key <- paste(obstrack$crew, obstrack$seat, obstrack$year, obstrack$month, 
                        obstrack$day, obstrack$transect, sep = "_")
  allkeys <- unique(obstrack$key[!is.na(obstrack$transect)])
  obstrack$bearing <- NA
  obstrack$sbearing <- NA
  obstrack$flag2 <- 0
  #
  for (i in seq(along = allkeys)) {
    tmp <- obstrack$key %in% allkeys[i]
    obs.i <- obstrack[tmp, ]
    if (nrow(obs.i) > 1 & 
        min(obs.i$sec, na.rm = TRUE) < max(obs.i$sec, na.rm = TRUE)) {
      for (j in 1:(nrow(obs.i)-1)) {
        obs.i$bearing[j] <- bearing(c(obs.i$long[j], obs.i$lat[j]), 
                                    c(obs.i$long[j+1], obs.i$lat[j+1]))
        if (is.na(obs.i$bearing[j])) next
        if (j > 1) {
          if (!(is.na(obs.i$bearing[j-1])) & 
              abs(obs.i$bearing[j] - obs.i$bearing[j-1]) > 100) 
            obs.i$flag2[j] <- 1
        }
      }
      obs.i$sbearing[!is.na(obs.i$bearing)] <- smooth(obs.i$bearing[!is.na(obs.i$bearing)])
    }
    obstrack[tmp, ] <- obs.i
  } 
  rm(obs.i)
  #
  obstrack$flag3 <- ifelse(obstrack$sbearing < 70 | 
                             (obstrack$sbearing > 110 & obstrack$sbearing < 250) | 
                             obstrack$sbearing > 290, 1, 0)
  # ---------------------------------------------------------------------------- #
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 11: FLAG POINTS ON LAND FOR REMOVAL
  # ---------------------------------------------------------------------------- #
  geodat <- as.data.frame(obstrack)
  coordinates(geodat) <- ~ long + lat
  proj4string(geodat) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  
  # READ IN ATLANTIC COASTLINE SHAPEFILE
  land <- readOGR(dsn = paste(dir,"/amapps_gis",sep=""),
                  layer = "atlanticCoastline_buffer_halfNM")
  
  # FLAG POINTS THAT ARE ON LAND
  if (!identical(proj4string(geodat), proj4string(land))) {
    land <- spTransform(land, CRS(proj4string(temp)))
  }
  gc()
  y = 5000 # split geoprocessing into chunks
  x = seq(1, dim(geodat)[1], y)
  overLand = function(x, y) {
    z = ifelse(x + y < dim(geodat)[1], x + y, dim(geodat)[1] + 1)
    geodat = geodat[x:(z-1), ]
    if (class(land) == "SpatialPolygonsDataFrame") {
      onland <- over(geodat, land)[, 1]
      } else if (class(land) == "SpatialPolygons") {
        onland <- over(geodat, land)
      }
  }
  onland = unlist(mapply(overLand, x, y))
  # 
  obstrack$onLand <- ifelse(is.na(onland), 0, 1)
  rm(geodat, onland, x, y)
  # ---------------------------------------------------------------------------- #

  
  # ---------------------------------------------------------------------------- #
  # STEP 12: REMOVE POINTS THAT ARE OBVIOUS TRANSIT POINTS
  # ---------------------------------------------------------------------------- #
  # to.remove = obstrack[obstrack$flag1 %in% 1 & obstrack$onLand %in% 1,]
  # if(dim(to.remove)[1]>1) {
  #   to.remove #display errors
  #   transit = bind_rows(transit, to.remove)}
  # rm(to.remove)
  # obstrack = filter(obstrack, !obstrack$flag1 %in% 1 && !obstrack$onLand %in% 1)
  # ---------------------------------------------------------------------------- #  
  
  
  # ---------------------------------------------------------------------------- #
  # STEP 12: OUTPUT DATA 
  # ---------------------------------------------------------------------------- #
  obstrack$key <- paste(obstrack$crew, obstrack$seat, obstrack$year, 
                        obstrack$month, obstrack$day, sep = "_")
  obstrack$begend <- ifelse(obstrack$type %in% c("BEGCNT", "ENDCNT"), 1, 0)
  
  save.image(paste(dir.out,"obstrack_part1.Rdata",sep="/"))
  write.csv(obstrack, file=paste(dir.out,"obstrack_part1.csv",sep="/"), row.names = FALSE)
  write.csv(transit, file=paste(dir.out,"transit_or_offline_part1.csv",sep="/"), row.names = FALSE)
  # ---------------------------------------------------------------------------- #


  # ---------------------------------------------------------------------------- #
  # STEP 13: CREATE MAP DOCUMENT FOR INTERACTIVE EDITS IN ArcGIS
  # ---------------------------------------------------------------------------- #  
  # CREATE temp_Shapefiles DIRECTORY WITHIN dir.out DIRECTORY 
  if (!file.exists(file.path(dir.out, "temp_shapefiles"))) {
    dir.create(file.path(dir.out, "temp_shapefiles"), recursive = TRUE)
  }
  
  # SAVE DATA FOR ArcGIS PROCESSING
  geodat <- as.data.frame(obstrack)
  coordinates(geodat) <- ~ long + lat
  proj4string(geodat) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
  writeOGR(geodat, 
           dsn = file.path(dir.out, "temp_shapefiles"), 
           layer = "temp_obsTrack", 
           driver = "ESRI Shapefile", 
           morphToESRI = TRUE)
  
  # READ IN GENERIC GISeditObsTrack.py FILE, CHANGE NECESSARY DIRECTORIES, & SAVE 
  # NEW .py FILE
  py <- readLines(file.path(dir, "code/cleaning_raw_data/test.py"))
  py[grep("^projpath = ", py)] <- paste("projpath = '", dir.out, "/'", sep = "")
  writeLines(py, file.path(dir.out, "GISeditObsTrack.py"))
  
  # RUN GISeditObsTrack.py PROGRAM IN ArcGIS, DELETE PROGRAM WHEN FINISHED
  #system(paste(py.exe, file.path(dir.out, "GISeditObsTrack.py"))) # trouble with space in new 'MB Seaduck' name
  system(paste(py.exe, '"//ifw-hqfs1/MB SeaDuck/AMAPPS/clean_data/AMAPPS_2017_08/GISeditObsTrack.py"'))
  unlink(file.path(dir.out, "GISeditObsTrack.py"))
  # ---------------------------------------------------------------------------- #
  
  
  # CREATE DATA PROCESSING SUMMARY FILE
  sink(file.path(dir.out, "dataProcessingSummary.txt"))
  cat("Survey data folder:", dir.in, "\n\n")
  cat("Error fix R file used:", errfix.file, "\n\n")
  cat("\nObservation files read:\n")
  print(out.obsfiles)
  cat("\n\nNumber of observations read by crew and seat:\n")
  print(out.obstab1)
  cat("\n\nNumber of observations read by observer and seat:\n")
  print(out.obstab2)
  cat("\n\nTrack files read:\n")
  print(out.trackfiles)
  cat("\n\nNumber of track file records read by crew and seat:\n")
  print(out.tracktab)
  cat("\n\nSummary of select columns (excludes BEG/END points):\n\n")
  print(out.obssum)
  cat("\n", rep("-", 80), "\n\n", sep = "")
  print(sessionInfo())
  cat("\n", rep("-", 80), "\n\n", sep = "")
  cat("Data processing completed on", date(), "\n")
  cat("Total run time:", round((proc.time() - ptm)[3] / 3600, 2), "hours\n")
  cat("Number of CPU cores allocated for transect re-numbering:", as.numeric(detectCores()))
  sink()
  
  # ------------------------------------------------------------------------- #
  ### STEP 14: MANUALLY EDIT IN ARCMAP
  # ------------------------------------------------------------------------- #
  # create folder to store edited shapefiles
  if (!file.exists(file.path(dir.out, "edited_shapefiles"))) {
    dir.create(file.path(dir.out, "edited_shapefiles"), recursive = TRUE)
  }
  #   a. open GISeditObsTrack.mxd in ArcMap (open ArcGIS-> ArcMap ->)
  #   b. visually inspect points by crew/seat/day layer
  #   c. delete points that should be deleted
  #   d. save layer as shapefile (right click on layer-> data-> export data 
  #       -> click on the folder icon and switch 'save type as' to shapefile)
  # you will not be able to move on until this is completed (estimated time = 1 day)
  
  rm(dir,dir.in)

#}
