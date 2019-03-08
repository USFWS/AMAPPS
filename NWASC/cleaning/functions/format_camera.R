format_camera<-function(data_camera){
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
  return(camera)
}
