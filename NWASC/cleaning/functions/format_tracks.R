format_tracks <-function(data_track){

  # ------------------------ #
  # track
  # ------------------------ #
  # the track data should not be in start/stop lat/lon format. There should be a point type with each location
  # only transect information for be in the start/stop format
  
  # if(!missing(data_track)) {
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
  if(any(colnames(data_track) %in% c("type","spp","spp_cd"))) {dat_track$point_type = data_track[,which(colnames(data_track) %in% c("type","spp","spp_cd"))]}
  if(any(colnames(data_track) %in% c("beaufort"))) {dat_track$seastate = data_track[,which(colnames(data_track) %in% c("beaufort"))]}
  if(any(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))) {dat_track$track_dt = format(as.Date(data_track[,which(colnames(data_track) %in% c("date","start_dt","start_date","gps_date","track_dt"))]),format='%m/%d/%Y')}
  if(any(colnames(data_track) %in% c("time"))) {dat_track$track_tm = data_track[,which(colnames(data_track) %in% c("time"))]}
  if(any(colnames(data_track) %in% c("transect","transect_id","source_transect"))) {
    dat_track$source_transect_id = data_track[,which(colnames(data_track) %in% c("transect","transect_id","source_transect"))]}
  if(any(colnames(data_track) %in% c("index"))) {dat_track$source_track_id = data_track[,which(colnames(data_track) %in% c("index"))]} 
  if(any(colnames(data_track) %in% c("sec","secs","seconds","seconds_from_midnight"))) {# & !any(colnames(data_track) %in% c("time"))
    dat_track$seconds_from_midnight_nb = data_track[,which(colnames(data_track) %in% c("sec","secs","seconds","seconds_from_midnight"))]}
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
  # }
  # rm(tracks.in.db)
  # ------------------------ #
  return(dat_track)
}
