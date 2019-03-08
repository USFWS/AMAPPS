format_observations <- function(data, data_track, data_transect, data_camera) {
  # ------------------------ #
  dat = as.data.frame(matrix(ncol = dim(obs.in.db)[2], nrow = dim(data)[1], data=NA))
  colnames(dat) = colnames(obs.in.db)
  dat$dataset_id = id
  #dat$source_dataset_id = as.character(data.in.db$source_dataset_id[data.in.db$dataset_id %in% id])
  dat$source_dataset_id = as.character(data.in.db$dataset_name[data.in.db$dataset_id %in% id])
  
  # in case capitalized 
  colnames(data) = tolower(colnames(data))
  
  # move those variables over that have the same name
  same_nm = colnames(data[colnames(data) %in% colnames(dat)])
  dat[,same_nm] = data[,same_nm] 
  
  # assign observation id based on what is already in the temp db
  dat$observation_id = c((max(obs.in.db$observation_id)+1):(max(obs.in.db$observation_id)+dim(data)[1]))
  
  # reformat, create, and/or rename
  data=as.data.frame(data)
  if(any(colnames(data) %in% c("spp","type","speciesid"))) {dat$spp_cd = data[,which(colnames(data) %in% c("spp","type","speciesid"))]}
  if(any(colnames(data) %in% c("original.spp.codes"))) {dat$original_species_tx = data[,which(colnames(data) %in% c("original.spp.codes"))]}
  if(any(colnames(data) %in% c("beaufort"))) {dat$seastate_beaufort_nb = data[,which(colnames(data) %in% c("beaufort"))]}  
  if(any(colnames(data) %in% c("weather"))) {dat$weather_tx = data[,which(colnames(data) %in% c("weather"))]}  
  if(any(colnames(data) %in% c("windspeed","wind.speed","wind_knots"))) {dat$wind_speed_tx = data[,which(colnames(data) %in% c("windspeed","wind.speed","wind_knots"))]}  
  if(any(colnames(data) %in% c("wind.direction","wind_dir"))) {dat$wind_dir_tx = data[,which(colnames(data) %in% c("wind.direction","wind_dir"))]}  
  
  if(any(colnames(data) %in% c("index","id"))) {
    if(length(which(colnames(data) %in% c("index","id")))==1){
      dat$source_obs_id = data[,which(colnames(data) %in% c("index","id"))]
    }else print("STOP: There are two options for source ID, one needs to be chosen")
  }
  if(all(is.na(dat$source_obs_id))) {dat$source_obs_id = 1:dim(data)[1]}
  
  if(any(colnames(data) %in% c("transect","source_transect"))) {dat$source_transect_id = data[,which(colnames(data) %in% c("transect","source_transect"))]}
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
  if(any(colnames(data) %in% c("association"))) {dat$association_tx = data[,which(colnames(data) %in% c("association"))]}
  if(any(colnames(data) %in% c("behavior","corrected_behavior","behaviordesc","original_behavior_tx"))) {
    dat$behavior_tx = data[,which(colnames(data) %in% c("behavior","corrected_behavior","behaviordesc","original_behavior_tx"))]}
  if(any(colnames(data) %in% c("age","approximate_age"))) {dat$animal_age_tx= data[,which(colnames(data) %in% c("age","approximate_age"))]}
  if(any(colnames(data) %in% c("flight_hei","flight_height","heightrange"))) {dat$flight_height_tx = data[,which(colnames(data) %in% c("flight_hei","flight_height","heightrange"))]}
  if(any(colnames(data) %in% c("plumage"))) {dat$plumage_tx = data[,which(colnames(data) %in% c("plumage"))]}
  if(any(colnames(data) %in% c("angle"))) {dat$angle_from_observer_nb = data[,which(colnames(data) %in% c("angle"))]}
  if(any(colnames(data) %in% c("distance","distdesc"))) {dat$distance_to_animal_tx = data[,which(colnames(data) %in% c("distance","distdesc"))]}
  if(any(colnames(data) %in% c("heading"))) {dat$heading_tx = data[,which(colnames(data) %in% c("heading"))]}
  if(any(colnames(data) %in% c("sec","secs","seconds","time_secs","seconds_from_midnight"))) {
    dat$seconds_from_midnight_nb = data[,which(colnames(data) %in% c("sec","secs","seconds","time_secs","seconds_from_midnight"))]}
  if(any(colnames(data) %in% c("distance_to_animal"))) {dat$distance_to_animal_tx = data[,which(colnames(data) %in% c("distance_to_animal"))]}
  if(any(colnames(data) %in% c("travel_direction"))) {dat$travel_direction_tx = data[,which(colnames(data) %in% c("travel_direction"))]}
  if(any(colnames(data) %in% c("visibility"))) {dat$visibility_tx = data[,which(colnames(data) %in% c("visibility"))]}
  if(any(colnames(data) %in% c("flight_dir,flidir","fltdir"))) {dat$travel_direction_tx = data[,which(colnames(data) %in% c("flight_dir,flidir","fltdir"))]}
  if(any(colnames(data) %in% c("lon", "long", "longitude","longitude_dd"))) {dat$temp_lon = data[,which(colnames(data) %in% c("lon", "long", "longitude","longitude_dd"))]} 
  if(any(colnames(data) %in% c("lat", "latitude","latitude_dd"))) {dat$temp_lat = data[,which(colnames(data) %in% c("lat", "latitude","latitude_dd"))]}
  if(any(colnames(data) %in% c("observer_confidence", "confidence"))) {dat$observer_confidence_tx = data[,which(colnames(data) %in% c("observer_confidence", "confidence"))]}
  if(any(colnames(data) %in% c("observer", "observers","obs"))) {dat$observer_tx = data[,which(colnames(data) %in% c("observer", "observers","obs"))]}
  if(any(colnames(data) %in% c("comments","comment"))) {dat$comments_tx = data[,which(colnames(data) %in% c("comments","comment"))]}
  if(any(colnames(data) %in% c("count","obs_count_general_nb","number","groupsize"))) {
    dat$obs_count_intrans_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb","number","groupsize"))]
  }
  # if there is a definition of where they were off effort, make the intransect counts for off effort NA
  if(any(colnames(data) %in% c("offline"))) {
    dat = as.data.frame(dat)
    dat$obs_count_intrans_nb[data$offline == 1] = NA
    dat$obs_count_general_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb","number","groupsize"))]
    dat$obs_count_general_nb[data$offline %in% 0] = NA  
  }
  if(any(is.na(dat$transect))) {
    dat = as.data.frame(dat)
    dat$obs_count_intrans_nb[is.na(dat$source_transect_id)] = NA
    dat$obs_count_general_nb = data[,which(colnames(data) %in% c("count","obs_count_general_nb","number","groupsize"))]
    dat$obs_count_general_nb[!is.na(dat$source_transect_id)] = NA  
  }
  
  # if behavior ids/ age ids/ sex ids are not done
  if(all(is.na(dat$behavior_id))){
    dat = dat %>% mutate(behavior_id = replace(behavior_id, behavior_tx %in% c("breaching","Surfacing-breaching","Submerged-breaching"),5),                        
                         behavior_id = replace(behavior_id, behavior_tx %in% "Flying",13),   
                         behavior_id = replace(behavior_id, behavior_tx %in% c("near surface","significantly submerged","Submerged",
                                                                               "Submerged-near surface","Submerged-significantly submerged"),23),
                         behavior_id = replace(behavior_id, behavior_tx %in% c("Surfacing-near surface","Surfacing",        
                                                                               "Surfacing-significantly submerged"),40),    
                         behavior_id = replace(behavior_id, behavior_tx %in% "Sitting",35),
                         behavior_id = replace(behavior_id, is.na(behavior_tx),44))
    if(!all(is.na(dat$behavior_tx[dat$behavior_id %in% 44]))){cat(sort(unique(dat$behavior_tx[dat$behavior_id %in% 44])))}
  }
  
  if(all(is.na(dat$age_id))){
    dat = dat %>% mutate(age_id = replace(age_id, animal_age_tx %in% "adult",1),
                         age_id = replace(age_id, animal_age_tx %in% "juvenile",2),
                         age_id = replace(age_id, animal_age_tx %in% "mixed",3),
                         age_id = replace(age_id, animal_age_tx %in% "other",4),
                         age_id = replace(age_id, animal_age_tx %in% "unknown",5),
                         age_id = replace(age_id, animal_age_tx %in% "immature",6),
                         age_id = replace(age_id, animal_age_tx %in% "subadult",7),
                         age_id = replace(age_id, is.na(animal_age_tx),5))     
  }
  
  if(all(is.na(dat$sex_id))){
    dat = dat %>% mutate(sex_id = replace(sex_id, animal_sex_tx %in% "female",1),
                         sex_id = replace(sex_id, animal_sex_tx %in% "male",2),
                         sex_id = replace(sex_id, animal_sex_tx %in% "mixed",3),
                         sex_id = replace(sex_id, animal_sex_tx %in% "other",4),
                         sex_id = replace(sex_id, animal_sex_tx %in% "unknown",5),
                         sex_id = replace(sex_id, is.na(animal_sex_tx),5))     
  }
  
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
  #rm(obs.in.db)
  # ------------------------ #
  return(dat)
}
