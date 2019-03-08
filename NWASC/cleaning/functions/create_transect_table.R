create_transect_table<-function(){
  # if the transect information needs to be pulled from the track files
  # might need to copy this bit and alter it to fit the variables the data has
  #if(missing(data_transect) & !missing(data_track)) {
    
    #---------------------------#
    # fromat transects from track
    #---------------------------#
    # distance flown per transect is in nautical miles, distance between points in meters 
    break.at.each.stop = filter(dat_track, point_type %in% c("BEGCNT"), !offline %in% 1) %>%
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
      #mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
      #                                       as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%Y-%m-%d %H:%M:%S"), 
      mutate(transect_time_min_nb = difftime(as.POSIXct(paste(end_dt, end_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
                                             as.POSIXct(paste(start_dt, start_tm, sep = " "), format = "%m/%d/%Y %H:%M:%S"), 
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
    dat_transect$source_dataset_id = as.character(data.in.db$dataset_name[data.in.db$dataset_id==id])   
    
    return(dat_transect)
  }
  
  
