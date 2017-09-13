# -------------------------- #
# import a new dataset into the NWASC temp access db
# data should be quality controlled and formatted before this step 
#
# 1) load the data into your workspace
# 2) open the access db and look up the id number in the dataset list (add one if it is not listed)
# 3) if there is not a transect or track file leave these fields empty
#
# written by K. Coleman, June 2016
# updated Feb. 2017
# -------------------------- #

import_into_temp_NWASC <- function(id, data, data_track, data_transect, data_camera) {
  
  # ------------------------ #
  # load packages
  # ------------------------ #
  library(RODBC)
  library(dplyr)
  library(geosphere) # distance
  library(zoo)
  # ------------------------ #
  
  
  # ------------------------ #
  # load dataset descriptions
  # ------------------------ #
  db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlFetch(db, "transect")
  tracks.in.db = sqlFetch(db, "track")
  data.in.db = sqlFetch(db, "dataset")
  obs.in.db = sqlFetch(db, "observation")
  camera.in.db = sqlFetch(db, "camera_effort")
  # ------------------------ #
  
  
  # ------------------------ #
  # make sure there are no existing records in the database under that dataset id number
  # this could happen if a typo is made or if a failed import half succeeded
  # the existing records would have to be removed before continuing
  # ------------------------ #
  if(any(transects.in.db$dataset_id %in% id)){cat(" ERROR DO NOT CONTINUE!!!! ERROR IN THE TRANSECTS TABLE","\n",
                                                  "RECORDS ALREADY EXIST UNDER THIS DATASET ID NUMBER")}
  if(any(tracks.in.db$dataset_id %in% id)){cat(" ERROR DO NOT CONTINUE!!!! ERROR IN THE TRACK TABLE","\n",
                                               "RECORDS ALREADY EXIST UNDER THIS DATASET ID NUMBER")}
  if(any(obs.in.db$dataset_id %in% id)){cat(" ERROR DO NOT CONTINUE!!!! ERROR IN THE OBSERVATION TABLE","\n",
                                            "RECORDS ALREADY EXIST UNDER THIS DATASET ID NUMBER")}
  if(any(camera.in.db$dataset_id %in% id)){cat(" ERROR DO NOT CONTINUE!!!! ERROR IN THE CAMERA TABLE","\n",
                                               "RECORDS ALREADY EXIST UNDER THIS DATASET ID NUMBER")}
  if(any(transects.in.db$dataset_id %in% id) | 
     any(tracks.in.db$dataset_id %in% id) | 
     any(obs.in.db$dataset_id %in% id) | 
     any(camera.in.db$dataset_id %in% id)) {stop('Dataset id already in database')}
  
  # on the contrary, also throw an error if dataset id is not already in dataset table
  if(all(!data.in.db$dataset_id %in% id)) {stop('There is no information for this dataset id in the dataset table. Please fill it out manually or use the datalist function')}
  # ------------------------ # 
  
  
  # ------------------------ #
  # observations table
  # ------------------------ #
  dat = as.data.frame(matrix(ncol = dim(obs.in.db)[2], nrow = dim(data)[1], data=NA))
  colnames(dat) = colnames(obs.in.db)
  dat$dataset_id = id
  dat$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])
  
  # in case capitalized 
  colnames(data) = tolower(colnames(data))
  
  # move those variables over that have the same name
  same_nm = colnames(data[colnames(data) %in% colnames(dat)])
  dat[,same_nm] = data[,same_nm] 
  
  # assign observation id based on what is already in the temp db
  dat$observation_id = c((max(obs.in.db$observation_id)+1):(max(obs.in.db$observation_id)+dim(data)[1]))
  
  # reformat, create, and/or rename
  data=as.data.frame(data)
  if(any(colnames(data) %in% c("spp","type"))) {dat$spp_cd = data[,which(colnames(data) %in% c("spp","type"))]}
  if(any(colnames(data) %in% c("beaufort"))) {dat$seastate_beaufort_nb = data[,which(colnames(data) %in% c("beaufort"))]}  
  if(any(colnames(data) %in% c("windspeed","wind.speed"))) {dat$wind_speed_tx = data[,which(colnames(data) %in% c("windspeed","wind.speed"))]}  
  if(any(colnames(data) %in% c("wind.direction"))) {dat$wind_dir_tx = data[,which(colnames(data) %in% c("wind.direction"))]}  
  if(any(colnames(data) %in% c("index","id"))) {dat$source_obs_id = data[,which(colnames(data) %in% c("index","id"))]}
  if(all(is.na(dat$source_obs_id))) {dat$source_obs_id = 1:dim(data)[1]}
  if(any(colnames(data) %in% c("transect"))) {dat$source_transect_id = data$transect}
  if(length(dat$source_transect_id)==0 & any(colnames(data) %in% c("offline")) & any(!colnames(data) %in% c("transect"))) {dat$source_transect_id[data$offline==0] = 1}
  if(any(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))) {
    dat$obs_dt = format(as.Date(data[,which(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))]),'%m/%d/%Y')}
  #if(any(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))) {
  #  dat$obs_dt = ifelse(class(data[[1,which(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))]])!="Date",
  #                      format(as.Date(data[,which(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))]),'%m/%d/%Y'),
  #                      data[,which(colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt"))])} # month/ day/ year
  if(any(!colnames(data) %in% c("date","start_date","gps_date","obs_date","start_dt","gps_dt","obs_dt")) & all(colnames(data) %in% c("year","month","day"))) {
    dat$obs_dt = paste(data$month,data$day,data$year,sep="/")}
  if(any(colnames(data) %in% c("time","obs_time","obs_tm", "gps_time"))) {
    dat$obs_start_tm = data[,which(colnames(data) %in% c("time","obs_time","obs_tm", "gps_time"))]
    #dat$obs_start_tm[!is.na(data$time)] = format(data$time[!is.na(data$time)], "%I:%M:%S %p") # hours (1-12): min: sec space am/pm
  }
  if(any(colnames(data) %in% c("association","assocdesc"))) {dat$association_tx = data[,which(colnames(data) %in% c("association","assocdesc"))]}
  #if(any(colnames(data) %in% c("behavior","corrected_behavior"))) {dat$behavior_tx = data[,which(colnames(data) %in% c("behavior","corrected_behavior"))]}
  #if(any(colnames(data) %in% c("age","approximate_age"))) {dat$animal_age_tx= data[,which(colnames(data) %in% c("age","approximate_age"))]}
  if(any(colnames(data) %in% c("flight_hei","flight_height"))) {dat$flight_height_tx = data[,which(colnames(data) %in% c("flight_hei","flight_height"))]}
  if(any(colnames(data) %in% c("plumage"))) {dat$plumage_tx = data[,which(colnames(data) %in% c("plumage"))]}
  if(any(colnames(data) %in% c("angle"))) {dat$angle_from_observer_nb = data[,which(colnames(data) %in% c("angle"))]}
  if(any(colnames(data) %in% c("distance"))) {dat$distance_to_animal_tx = data[,which(colnames(data) %in% c("distance"))]}
  if(any(colnames(data) %in% c("heading"))) {dat$heading_tx = data[,which(colnames(data) %in% c("heading"))]}
  if(any(colnames(data) %in% c("sec","secs","seconds"))) {dat$seconds_from_midnight_nb = data[,which(colnames(data) %in% c("sec","secs","seconds"))]}
  if(any(colnames(data) %in% c("distance_to_animal"))) {dat$distance_to_animal_tx = data[,which(colnames(data) %in% c("distance_to_animal"))]}
  if(any(colnames(data) %in% c("travel_direction"))) {dat$travel_direction_tx = data[,which(colnames(data) %in% c("travel_direction"))]}
  if(any(colnames(data) %in% c("visibility"))) {dat$visibility_tx = data[,which(colnames(data) %in% c("visibility"))]}
  if(any(colnames(data) %in% c("flight_dir,flidir","fltdir"))) {dat$travel_direction_tx = data[,which(colnames(data) %in% c("flight_dir,flidir","fltdir"))]}
  if(any(colnames(data) %in% c("lon", "long", "longitude"))) {dat$temp_lon = data[,which(colnames(data) %in% c("lon", "long", "longitude"))]} 
  if(any(colnames(data) %in% c("lat", "latitude"))) {dat$temp_lat = data[,which(colnames(data) %in% c("lat", "latitude"))]}
  if(any(colnames(data) %in% c("observer_confidence", "confidence"))) {dat$observer_confidence_tx = data[,which(colnames(data) %in% c("observer_confidence", "confidence"))]}
  if(any(colnames(data) %in% c("observer", "observers"))) {dat$observer_tx = data[,which(colnames(data) %in% c("observer", "observers"))]}
  if(any(colnames(data) %in% c("comments","comment"))) {dat$comments_tx = data[,which(colnames(data) %in% c("comments","comment"))]}
  if(any(colnames(data) %in% c("count","obs_count_general_nb","number"))) {
    dat$obs_count_general_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb","number"))]
    dat$obs_count_intrans_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb","number"))]
  }
  # if there is a definition of where they were off effort, make the intransect counts for off effort NA
  if(any(colnames(data) %in% c("offline"))) {dat$obs_count_intrans_nb[data$offline == 1] = NA}
  
  # classes
  dat = dat %>% mutate(observation_id = as.numeric(observation_id),
                       transect_id = as.numeric(transect_id),
                       dataset_id = as.numeric(dataset_id),
                       local_obs_id = as.numeric(local_obs_id),
                       local_transect_id = as.numeric(local_transect_id),
                       source_obs_id = as.numeric(source_obs_id),
                       source_transect_id = as.character(source_transect_id),
                       source_dataset_id = as.character(source_dataset_id),
                       obs_dt = as.character(obs_dt),
                       obs_start_tm = as.character(obs_start_tm),
                       original_species_tx = as.character(original_species_tx),
                       spp_cd = as.character(spp_cd),
                       obs_count_intrans_nb = as.numeric(obs_count_intrans_nb),
                       obs_count_general_nb = as.numeric(obs_count_general_nb),
                       animal_age_tx = as.character(animal_age_tx),
                       plumage_tx = as.character(plumage_tx),
                       behavior_tx = as.character(behavior_tx),
                       travel_direction_tx = as.character(travel_direction_tx),
                       flight_height_tx = as.character(flight_height_tx),
                       distance_to_animal_tx = as.character(distance_to_animal_tx),
                       angle_from_observer_nb = as.numeric(angle_from_observer_nb),
                       visibility_tx = as.character(visibility_tx),
                       weather_tx = as.character(weather_tx),
                       seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                       wind_speed_tx = as.character(wind_speed_tx),
                       wind_dir_tx = as.character(wind_dir_tx),
                       seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                       comments_tx = as.character(comments_tx),
                       animal_sex_tx = as.character(animal_sex_tx),
                       obs_end_tm = as.character(obs_end_tm),
                       cloud_cover_tx = as.character(cloud_cover_tx),
                       association_tx = as.character(association_tx),
                       who_created_tx = as.character(who_created_tx),
                       who_created = as.numeric(who_created),
                       date_created = as.character(date_created),
                       temp_lat = as.numeric(temp_lat),
                       temp_lon = as.numeric(temp_lon),
                       date_imported = as.character(date_imported),
                       who_imported = as.numeric(who_imported),
                       salinity_ppt_nb = as.numeric(salinity_ppt_nb),
                       admin_notes = as.character(admin_notes),
                       platform_tx = as.character(platform_tx),
                       station_tx = as.character(station_tx),
                       survey_type = as.character(survey_type),
                       heading_tx = as.character(heading_tx),
                       wave_height_tx = as.character(wave_height_tx),
                       obs_position = as.character(obs_position),
                       glare_tx = as.character(glare_tx),
                       whitecaps_tx = as.character(whitecaps_tx),
                       visit = as.character(visit),
                       reel = as.character(reel),
                       datafile = as.character(datafile),
                       seconds_from_midnight_nb = as.numeric(seconds_from_midnight_nb),
                       observer_confidence_tx = as.character(observer_confidence_tx),
                       observer_tx = as.character(observer_tx),
                       behavior_id = as.numeric(behavior_id),
                       age_id = as.numeric(age_id),
                       sex_id = as.numeric(sex_id))
    # ------------------------ #
    
  
  # ------------------------ #
  # track
  # ------------------------ #
  # the track data should not be in start/stop lat/lon format. There should be a point type with each location
  # only transect information for be in the start/stop format
  
  if(!missing(data_track)) {
    dat_track = as.data.frame(matrix(ncol=dim(tracks.in.db)[2], nrow=dim(data_track)[1], data=NA))
    colnames(dat_track) = colnames(tracks.in.db)
  
    # in case capitalized 
    colnames(data_track) = tolower(colnames(data_track))
    
    # move those variables over that have the same name
    same_nm = colnames(data_track[colnames(data_track) %in% colnames(dat_track)])
    dat_track[,same_nm] = data_track[,same_nm]
    
    dat_track$dataset_id = id
    dat_track$track_id = c((max(tracks.in.db$track_id)+1):(max(tracks.in.db$track_id)+dim(data_track)[1]))
    
    # fill in unmatched variables
    data_track=as.data.frame(data_track)
    if(any(colnames(data_track) %in% c("lon", "longitude", "long"))) {dat_track$track_lon = data_track[,which(colnames(data_track) %in% c("lon", "longitude", "long"))]}
    if(any(colnames(data_track) %in% c("lat", "latitude"))) {dat_track$track_lat = data_track[,which(colnames(data_track) %in% c("lat", "latitude"))]}
    if(any(colnames(data_track) %in% c("type"))) {dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type"))]}
    if(any(colnames(data_track) %in% c("beaufort"))) {dat_track$seastate = data_track[,which(colnames(data_track) %in% c("beaufort"))]}
    if(any(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))) {dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))]),format='%m/%d/%Y')}
    if(any(colnames(data_track) %in% c("time"))) {dat_track$track_tm = data_track[,which(colnames(data_track) %in% c("time"))]}
    if(any(colnames(data_track) %in% c("transect","transect_id"))) {dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id"))]}
    if(any(colnames(data_track) %in% c("index"))) {dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]} 
    if(any(colnames(data_track) %in% c("sec","secs","seconds"))) {dat_track$seconds_from_midnight_nb = data_track[,which(colnames(data_track) %in% c("sec","secs","seconds"))]}
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
  }
  # ------------------------ #
  
  
  # ------------------------ #
  # transect
  # ------------------------ #
  # reformat, create, and/or rename
  if(!missing(data_transect)) {
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    
    # in case capitalized
    colnames(data_transect) = tolower(colnames(data_transect))
    
    # move those variables over that have the same name
    same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = data_transect[,same_nm]
    
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
    
    if(any(colnames(data_transect) %in% c("transect","transect_id"))) {
      dat_transect$source_transect_id = data_transect[,which(colnames(data_transect) %in% c("transect","transect_id"))]}
    if(any(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude", "start_long", "begin_long"))])) {
        dat_transect$temp_start_lon = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]))
      } else {dat_transect$temp_start_lon = data_transect[,which(colnames(data_transect) %in% c("startlongdd","start_lon", "begin_lon","start_longitude", "begin_longitude","start_long", "begin_long"))]}
    }
    if(any(colnames(data_transect) %in% c("startlatdd","start_lat", "begin_lat","start_latitude",  "begin_latitude"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("startlatdd","start_lat","begin_lat",  "start_latitude", "begin_latitude"))])) {
        dat_transect$temp_start_lat = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("startlatdd","start_lat","begin_lat","start_latitude", "begin_latitude"))]))
      } else dat_transect$temp_start_lat = data_transect[,which(colnames(data_transect) %in% c("startlatdd","start_lat","begin_lat","start_latitude", "begin_latitude"))]}
    if(any(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude", "end_long", "stop_long"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))])) { 
        dat_transect$temp_stop_lon = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))])) 
      } else dat_transect$temp_stop_lon = data_transect[,which(colnames(data_transect) %in% c("endlongdd","end_lon", "stop_lon","end_longitude", "stop_longitude","end_long", "stop_long"))]
    }
    if(any(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))])) {
        dat_transect$temp_stop_lat = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))]))
        } else dat_transect$temp_stop_lat = data_transect[,which(colnames(data_transect) %in% c("endlatdd","end_lat", "stop_lat","end_latitude", "stop_latitude"))]
    }
    if(any(colnames(data_transect) %in% c("date","start_dt","start_date"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))])) {
        if(is.Date(unlist(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]))) {
          dat_transect$start_dt = format(as.data.frame(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))][[1]]),'%m/%d/%Y')
        }
        if(is.character(unlist(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]))) {
          dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))][[1]]),'%m/%d/%Y')
        }
      } else dat_transect$start_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","start_dt","start_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("date","end_dt","end_date"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))])) {
        if(is.Date(unlist(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]))) {
          dat_transect$end_dt = format(as.data.frame(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))][[1]]),'%m/%d/%Y')
          }
        if(is.character(unlist(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]))) {
          dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))][[1]]),'%m/%d/%Y')
        }
      } else dat_transect$end_dt = format(as.Date(data_transect[,which(colnames(data_transect) %in% c("date","end_dt","end_date"))]),'%m/%d/%Y')
    }
    if(any(colnames(data_transect) %in% c("time","start_time","start_tm"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))])) {
        dat_transect$start_tm = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))]))
      } else dat_transect$start_tm = data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))]
    }
    if(any(colnames(data_transect) %in% c("time","end_time","end_tm"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))])) {
        dat_transect$end_tm = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))]))
      } else dat_transect$end_tm = data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))]
    }
    if(any(colnames(data_transect) %in% c("observer","observers","observer_tx"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))])){ 
        dat_transect$observers_tx = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))]))
      } else dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))]
    }
    if(any(colnames(data_transect) %in% c("observer_position"))) {
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("observer_position"))])){ 
        dat_transect$obs_position = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("observer_position"))]))
      } else dat_transect$obs_position = data_transect[,which(colnames(data_transect) %in% c("observer_position"))]
    }
    if(any(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))){
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))])){ 
        dat_transect$transect_distance_nb = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))]))
      } else dat_transect$transect_distance_nb = data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))]
    }
    if(any(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))){
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))])){ 
        dat_transect$traversal_speed_nb = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]))
      } else dat_transect$traversal_speed_nb = data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]
    }
    if(any(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))){
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))])){ 
        dat_transect$traversal_speed_nb = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]))
      } else dat_transect$traversal_speed_nb = data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]
    }
    if(any(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))){
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))])){ 
        dat_transect$heading_tx = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))]))
      } else dat_transect$heading_tx = data_transect[,which(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))]
    }
    if(any(colnames(data_transect) %in% c("altitude","mean_alt_m"))){
      if(is.list(data_transect[,which(colnames(data_transect) %in% c("altitude","mean_alt_m"))])){ 
        dat_transect$altitude_nb_m = as.vector(unlist(data_transect[,which(colnames(data_transect) %in% c("altitude","mean_alt_m"))]))
      } else dat_transect$altitude_nb_m = data_transect[,which(colnames(data_transect) %in% c("altitude","mean_alt_m"))]
    }
    
    # calculations
    if(all(is.na(dat_transect$transect_time_min_nb))) {
      dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 units = "mins")
    }
    
  }
  
  # if the transect information needs to be pulled from the track files
  # might need to copy this bit and alter it to fit the variables the data has
  if(missing(data_transect) & !missing(data_track)) {
    
    #---------------------------#
    # fromat transects from track
    #---------------------------#
    # distance flown per transect is in nautical miles, distance between points in meters 
    break.at.each.stop = filter(dat_track, point_type %in% c("BEGCNT")) %>%
      group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
      select(source_transect_id, source_track_id, start.stop.index, track_dt)
    ssi = left_join(dat_track, break.at.each.stop, by="source_track_id") %>% 
      select(-source_transect_id.y) %>% rename(source_transect_id = source_transect_id.x) %>% 
      mutate(start.stop.index = as.numeric(start.stop.index))  %>% 
      select(source_track_id,source_transect_id,start.stop.index) %>% group_by(source_transect_id) %>% 
      mutate_all(funs(na.locf(., na.rm=FALSE))) %>% 
      ungroup %>%
      mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% 
      mutate(newkey = ifelse(newkey=="NA_NA", NA, newkey)) %>%
      select(-start.stop.index)
    new.key = left_join(dat_track, select(ssi,source_track_id,newkey), by="source_track_id") %>% 
      filter(!is.na(newkey))
     
    # grouped by new key to avoid counting time and distance traveled between breaks
    new.df = new.key %>% group_by(newkey)  %>% 
      mutate(lagged.lon = lead(track_lon, default = last(track_lon), order_by = track_tm),
             lagged.lat = lead(track_lat, default = last(track_lat), order_by = track_tm)) %>%
      rowwise() %>% 
      mutate(distance = distVincentySphere(c(track_lon, track_lat), c(lagged.lon, lagged.lat))) %>%
      select(-lagged.lon, -lagged.lat) %>%  
      group_by(newkey) %>%  
      summarise(observer = first(observer),
                source_transect_id = first(source_transect_id),
                transect_distance_nb = sum(distance, na.rm=TRUE),
                temp_start_lon = first(track_lon),
                temp_stop_lon = last(track_lon),
                temp_start_lat = first(track_lat),
                temp_stop_lat = last(track_lat),
                start_dt = as.character(first(track_dt)),
                end_dt = as.character(last(track_dt)),
                start_tm = first(track_tm), 
                end_tm = last(track_tm)) %>%
      as.data.frame() %>% rowwise() %>% 
      mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
                                             as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
     # mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
     #                                        as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                             units = "mins"))   %>%
      as.data.frame %>% arrange(start_dt, source_transect_id)
    #
    data_transect = new.df %>% 
      group_by(source_transect_id,start_dt)  %>% 
      arrange(start_dt,start_tm) %>% 
      summarise(observer = first(observer),
                temp_start_lon = first(temp_start_lon),
                temp_stop_lon = last(temp_stop_lon),
                temp_start_lat = first(temp_start_lat),
                temp_stop_lat = last(temp_stop_lat),
                #start_dt = as.character(first(start_dt)),
                end_dt = as.character(last(end_dt)),
                start_tm = first(start_tm), 
                end_tm  = last(end_tm),
                transect_time_min_nb = sum(transect_time_min_nb),
                transect_distance_nb = sum(transect_distance_nb))  %>%
      ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
      mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) 
    rm(new.df, new.key, ssi, break.at.each.stop)
    #---------------------------#
    
    # if speed isn't listed
    #transects = mutate(transects, traversal_speed_nb =  (distance/(as.numeric(transect_time_min_nb)*60))*1.94384449244)
    
    # fill in the db transects table
    dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
    colnames(dat_transect) = colnames(transects.in.db)
    same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
    dat_transect[,same_nm] = data_transect[,same_nm]
    dat_transect$dataset_id = id
    dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
    dat_transect$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
  }
  
  
  # ------------------------ #
  # Camera
  # ------------------------ #
  if(!missing(data_camera)) {
    dat_camera = as.data.frame(matrix(ncol=dim(camera.in.db)[2], nrow=dim(data_camera)[1], data=NA))
    colnames(dat_camera) = colnames(camera.in.db)
    
    # move those variables over that have the same name
    same_nm = colnames(data_camera[colnames(data_camera) %in% colnames(dat_camera)])
    dat_camera[,same_nm] = data_camera[,same_nm]
    
    dat_camera$dataset_id = id
    dat_camera$camera_id = c((max(camera.in.db$camera_id)+1):(max(camera.in.db$camera_id)+dim(dat_camera)[1]))
    dat_camera$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id==id])   
    
    if(any(colnames(data_camera) %in% c("transect","hideftransect"))) {dat_camera$source_transect_id = data_camera[,which(colnames(data_camera) %in% c("transect","hideftransect"))]}
    if(any(colnames(data_camera) %in% c("camera_dt","date","start_dt","start_date"))) {dat_camera$camera_dt = format(as.Date(data_camera[,which(colnames(data_camera) %in% c("camera_dt","date","start_dt","start_date"))]),'%m/%d/%Y')}
    if(any(colnames(data_camera) %in% c("startlongdd","begin_lon","start_long","begin_long","start_longitude"))) {dat_camera$start_lon = data_camera[,which(colnames(data_camera) %in% c("startlongdd","begin_lon","start_long","begin_long","start_longitude"))]}         
    if(any(colnames(data_camera) %in% c("startlatdd","begin_lat","start_latitude"))) {dat_camera$start_lat = data_camera[,which(colnames(data_camera) %in% c("startlatdd","begin_lat","start_latitude"))]}          
    if(any(colnames(data_camera) %in% c("endlongdd","stop_lon","end_longitude","stop_longitude"))) {dat_camera$end_lon = data_camera[,which(colnames(data_camera) %in% c("endlongdd","stop_lon","end_longitude","stop_longitude"))]}            
    if(any(colnames(data_camera) %in% c("endlatdd","stop_lat","end_latitude","stop_latitude"))) {dat_camera$end_lat = data_camera[,which(colnames(data_camera) %in% c("endlatdd","stop_lat","end_latitude","stop_latitude"))]}            
    if(any(colnames(data_camera) %in% c("altitude","mean_alt_m"))) {dat_camera$altitude_m = data_camera[,which(colnames(data_camera) %in% c("altitude","mean_alt_m"))]}         
    if(any(colnames(data_camera) %in% c("speed","mean_speed_knots"))) {dat_camera$speed_knots = data_camera[,which(colnames(data_camera) %in% c("speed","mean_speed_knots"))]}        
    if(any(colnames(data_camera) %in% c("direction","mean_heading_deg"))) {dat_camera$heading = data_camera[,which(colnames(data_camera) %in% c("direction","mean_heading_deg"))]}           
    if(any(colnames(data_camera) %in% c("start_time", "begin_time"))) {dat_camera$start_tm = data_camera[,which(colnames(data_camera) %in% c("start_time", "begin_time"))]}           
    if(any(colnames(data_camera) %in% c("end_time", "stop_time"))) {dat_camera$end_tm = data_camera[,which(colnames(data_camera) %in% c("end_time", "stop_time"))]} 
    
    #classes
    dat_camera = dat_camera %>% mutate(camera_id = as.numeric(camera_id),
                                       transect_id = as.numeric(transect_id),
                                       dataset_id = as.numeric(dataset_id),
                                       source_transect_id = as.character(source_transect_id),
                                       camera_dt = as.character(camera_dt),
                                       start_lon = as.numeric(start_lon),
                                       start_lat = as.numeric(start_lat),
                                       end_lon = as.numeric(end_lon),  
                                       end_lat = as.numeric(end_lat),
                                       altitude_m = as.character(altitude_m),
                                       speed_knots = as.character(speed_knots),
                                       heading = as.character(heading), 
                                       area_sqkm = as.character(area_sqkm),
                                       start_tm = as.character(start_tm),
                                       end_tm = as.character(end_tm),
                                       source_dataset_id = as.character(source_dataset_id),
                                       shape_length = as.numeric(shape_length),
                                       shape_area = as.numeric(shape_area),
                                       reel = as.character(reel))  
  }
  
  # ------------------------ #
  # add transects to other data
  # ------------------------ #
  if(exists("dat_transect")) {
    # format class names
    dat_transect = dat_transect %>% mutate(transect_id = as.numeric(transect_id),
                                         dataset_id = as.numeric(dataset_id),
                                         source_transect_id = as.character(source_transect_id),
                                         source_dataset_id = as.character(source_dataset_id),
                                         start_dt = as.character(start_dt),
                                         start_tm = as.character(start_tm),
                                         end_dt = as.character(end_dt),
                                         end_tm = as.character(end_tm),
                                         transect_time_min_nb = as.numeric(transect_time_min_nb),
                                         transect_distance_nb = as.numeric(transect_distance_nb),
                                         traversal_speed_nb = as.numeric(traversal_speed_nb),
                                         transect_width_nb = as.numeric(transect_width_nb),
                                         observers_tx = as.character(observers_tx),
                                         visability_tx = as.character(visability_tx),
                                         weather_tx = as.character(weather_tx),
                                         seastate_beaufort_nb = as.numeric(seastate_beaufort_nb),
                                         wind_speed_tx = as.character(wind_speed_tx),
                                         wind_dir_tx = as.character(wind_dir_tx),
                                         seasurface_tempc_nb = as.numeric(seasurface_tempc_nb),
                                         comments_tx = as.character(comments_tx),
                                         track_gs = as.character(track_gs),
                                         conveyance_name_tx = as.character(conveyance_name_tx),
                                         heading_tx = as.character(heading_tx),
                                         wave_height_tx = as.character(wave_height_tx),
                                         spatial_type_tx = as.character(spatial_type_tx),
                                         who_created = as.character(who_created),
                                         date_created = as.character(date_created),
                                         utm_zone = as.character(utm_zone),
                                         whole_transect = as.character(whole_transect),
                                         local_transect_id = as.character(local_transect_id),
                                         who_imported = as.character(who_imported),
                                         temp_start_lat = as.numeric(temp_start_lat),
                                         temp_start_lon = as.numeric(temp_start_lon),
                                         temp_stop_lat = as.numeric(temp_stop_lat),
                                         temp_stop_lon = as.numeric(temp_stop_lon),
                                         obs_position = as.character(obs_position),
                                         visit = as.character(visit),
                                         time_from_midnight_start = as.character(time_from_midnight_start),
                                         time_from_midnight_stop = as.character(time_from_midnight_stop),
                                         date_imported = as.character(date_imported),
                                         local_survey_id = as.character(local_survey_id),
                                         local_transect_id2 = as.character(local_transect_id2),
                                         survey_type = as.character(survey_type),
                                         datafile = as.character(datafile),
                                         altitude_nb_m = as.numeric(altitude_nb_m))
    
    # ------------------------ #
    # join transect numbers to both track and observations tables based on date
    # this will only work if the same transect is not repeated on the same day or broken -> had to add datafile
    # ------------------------ #
    dat_track = left_join(dat_track, select(dat_transect, source_transect_id, transect_id, start_dt), 
                          by=c("source_transect_id", "track_dt" = "start_dt")) %>%
      rename(transect_id = transect_id.y) %>% select(-transect_id.x)
    
    dat =  left_join(dat, select(dat_transect, source_transect_id, transect_id, start_dt), 
                     by=c("source_transect_id", "obs_dt" = "start_dt")) %>%
      rename(transect_id = transect_id.y) %>% select(-transect_id.x)

    if(exists("dat_camera")){
      dat_camera = dat_camera %>% rename(start_dt = camera_dt) 
      dat_camera = left_join(dat_camera, select(dat_transect, source_transect_id, transect_id, start_dt), by=c("source_transect_id","start_dt")) %>%
        mutate(transect_id.x = transect_id.y) %>% rename(transect_id = transect_id.x, camera_dt = start_dt) %>% select(-transect_id.y)
    }
  }
  # ------------------------ #
  
  
  # ------------------------ #
  # add to NWASC temporary db
  # ------------------------ #
  dat = dat[,colnames(obs.in.db)]
  sqlSave(db, dat, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  if(exists("dat_track")){sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  if(exists("dat_transect")){sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  if(exists("dat_camera")){sqlSave(db, dat_camera, tablename = "camera_effort", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  odbcClose(db) 
  # ------------------------ #
  
  
  # ------------------------ #
  # export as csv in case we need to rebuild the database
  # ------------------------ #
  dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/"
  write.csv(dat, file=paste(dir.out,"observations_", id, ".csv", sep=""), row.names = FALSE)
  if(exists("dat_track")){write.csv(dat_track, file=paste(dir.out,"track_", id, ".csv", sep=""), row.names = FALSE)}
  if(exists("dat_transect")){write.csv(dat_transect, file=paste(dir.out,"transect_", id, ".csv", sep=""), row.names = FALSE)}
  if(exists("dat_camera")){write.csv(dat_camera, file=paste(dir.out,"camera_effort_", id, ".csv", sep=""), row.names = FALSE)}
  # ------------------------ #
}
