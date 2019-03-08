format_transects<-function(data_transect){
  
  # ------------------------ #
  # transect
  # ------------------------ #
  # reformat, create, and/or rename
  #if(!missing(data_transect)) {
  data_transect = as.data.frame(data_transect)
  dat_transect = as.data.frame(matrix(ncol=dim(transects.in.db)[2], nrow=dim(data_transect)[1], data=NA))
  colnames(dat_transect) = colnames(transects.in.db)
  
  # in case capitalized
  colnames(data_transect) = tolower(colnames(data_transect))
  
  # move those variables over that have the same name
  same_nm = colnames(data_transect[colnames(data_transect) %in% colnames(dat_transect)])
  dat_transect[,same_nm] = data_transect[,same_nm]
  
  dat_transect$dataset_id = id
  dat_transect$transect_id = c((max(transects.in.db$transect_id)+1):(max(transects.in.db$transect_id)+dim(dat_transect)[1]))
  dat_transect$source_dataset_id = as.character(data.in.db$dataset_name[data.in.db$dataset_id==id])   
  
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
  if(any(colnames(data_transect) %in% c("time","start_time","start_tm"))) {
    dat_transect$start_tm = data_transect[,which(colnames(data_transect) %in% c("time","start_time","start_tm"))]
  }
  if(any(colnames(data_transect) %in% c("time","end_time","end_tm"))) {
    dat_transect$end_tm = data_transect[,which(colnames(data_transect) %in% c("time","end_time","end_tm"))]
  }
  if(any(colnames(data_transect) %in% c("observer","observers","observer_tx"))) {
    dat_transect$observers_tx = data_transect[,which(colnames(data_transect) %in% c("observer","observers","observer_tx"))]
  }
  if(any(colnames(data_transect) %in% c("observer_position"))) {
    dat_transect$obs_position = data_transect[,which(colnames(data_transect) %in% c("observer_position"))]
  }
  if(any(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))){
    dat_transect$transect_distance_nb = data_transect[,which(colnames(data_transect) %in% c("Tranesct_Length", "transect_length", "Tranesct_distance", "distance"))]
  }
  if(any(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))){
    dat_transect$traversal_speed_nb = data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]
  }
  if(any(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))){
    dat_transect$traversal_speed_nb = data_transect[,which(colnames(data_transect) %in% c("speed","mean_speed","mean_speed_knots"))]
  }
  if(any(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))){
    dat_transect$heading_tx = data_transect[,which(colnames(data_transect) %in% c("heading","heading_deg","mean_heading_deg"))]
  }
  if(any(colnames(data_transect) %in% c("altitude","mean_alt_m"))){
    dat_transect$altitude_nb_m = data_transect[,which(colnames(data_transect) %in% c("altitude","mean_alt_m"))]
  }
  if(any(colnames(data_transect) %in% c("seconds_from_midnight"))){
    dat_transect$time_from_midnight_start = data_transect[,which(colnames(data_transect) %in% c("seconds_from_midnight"))]
    dat_transect$time_from_midnight_stop = data_transect[,which(colnames(data_transect) %in% c("seconds_from_midnight"))]
  }
  
  # calculations
  if(all(is.na(dat_transect$transect_time_min_nb))) {
    dat_transect$transect_time_min_nb = difftime(as.POSIXct(paste(dat_transect$end_dt, dat_transect$end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 as.POSIXct(paste(dat_transect$start_dt, dat_transect$start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                                 units = "mins")
  }
  dat_transect = dat_transect %>% arrange(start_tm)
  
  # }
  
    # ------------------------ #
  # add transects to other data
  # ------------------------ #
  #  if(exists("dat_transect")) {
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
  dat_transect = dat_transect %>% arrange(start_dt, start_tm)
  
  return(dat_transect)
}
