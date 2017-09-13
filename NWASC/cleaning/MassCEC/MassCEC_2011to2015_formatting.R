#---------------------------#
# format MassCEC data for NWASC
#---------------------------#


#---------------------------#
# packages
#---------------------------#
require(dplyr)
require(zoo)
require(geosphere)
#---------------------------#


#---------------------------#
# directories
#---------------------------#
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/MassCEC/year1_2011to2012"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"year1_2011to2012_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"year1_2011to2012_track.csv",sep="/"))
id = 135
#---------------------------#


#---------------------------#
# format track and obs
#---------------------------#
data_track = bind_rows(data_track, filter(data, type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN"))) %>%
  mutate(type = replace(type, type %in% "BEGTRAN", "BEGCNT"),
         type = replace(type, type %in% "ENDTRAN", "ENDCNT"),
         date = as.Date(paste(year, month, day, sep="/"))) %>% 
  arrange(date, sec)
data = data %>% filter(., !type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN")) %>% 
  mutate(date = as.Date(paste(year, month, day, sep="/")),
         source_transect_id = paste(date, observer, sep="_")) %>% 
  arrange(date, sec)

# remove points
data_track = filter(data_track, !index %in% c(2990.0))
data_track$key = as.character(data_track$key)
data_track$key[data_track$index==11850.9 & data_track$key=="survey13_lr_2012_10_26"] = "removethis"
data_track=data_track[data_track$key!="removethis",]

# fix errors
data_track$observer[data_track$index %in% c(5837.9, 8273.1, 24614.1, 28728.9, 25320.9, 28167.1,
                                            38512.9, 40895.1, 41429.9, 43905.1, 44784.9, 47426.1,
                                            8742.9, 11216.1, 35048.9, 37941.1, 11850.9, 14414.1,
                                            18152.9, 20753.1, 14935.9, 32147.9, 34606.1) & data_track$seat=="rr"] = "NJM"
data_track$observer[data_track$index %in% c(24614.1,25320.9,28167.1,37941.1,43905.1,11216.1,
                                            20753.1) & data_track$seat=="lr"] = "TPW"
data_track = data_track %>% mutate(observer = replace(observer, type=="WAYPNT" & seat=="rr", "NJM"),
                                   observer = replace(observer, type=="WAYPNT" & seat=="lr", "TPW"),
                                   source_transect_id = paste(date, observer, sep="_"))
data_track = data_track[!duplicated(data_track[c("source_transect_id","index")]),]
                    
data_track$type[data_track$index %in% c(11855.0)] = "BEGCNT"

# to add
to.add = data_track %>% filter(source_transect_id=="2012-05-06_TPW" & index==37323.0) %>% 
  select(lat,lon,sec,date,type,index) %>% 
  mutate(seat="rr",observer="NJM", source_transect_id=paste(date,observer,sep="_"))
to.add2 = data_track %>% filter(source_transect_id=="2012-05-06_TPW" & index==37741.0) %>% 
  select(lat,lon,sec,date,type,index) %>% 
  mutate(seat="rr",observer="NJM", source_transect_id=paste(date,observer,sep="_"))
data_track = bind_rows(data_track, to.add, to.add2) %>% arrange(date,source_transect_id,sec)
rm(to.add,to.add2)

# only include on transect track 
hold = data_track %>% filter(type %in% c("BEGCNT","ENDCNT"))
data_track = data_track[(data_track$source_transect_id=="2011-01-11_NJM" & data_track$sec>41254.67 & data_track$sec<52942.63) |
                          (data_track$source_transect_id=="2011-11-22_TPW" & data_track$sec>40640.33 & data_track$sec<55389.18) |
                          (data_track$source_transect_id=="2011-12-09_TPW" & data_track$sec>38876.16 & data_track$sec<50486.56) |
                          (data_track$source_transect_id=="2011-12-09_NJM" & data_track$sec>38875.37 & data_track$sec<50481.68) |
                          (data_track$source_transect_id=="2012-02-16_TPW" & data_track$sec>39584.34 & data_track$sec<51521.04) |
                          (data_track$source_transect_id=="2012-02-16_NJM" & data_track$sec>39585.23 & data_track$sec<51521.04) |
                          (data_track$source_transect_id=="2012-03-12_TPW" & data_track$sec>40359.23 & data_track$sec<52704.73) |
                          (data_track$source_transect_id=="2012-03-12_NJM" & data_track$sec>40334.74 & data_track$sec<52824.46) |
                          (data_track$source_transect_id=="2012-03-17_TPW" & data_track$sec>38325.89 & data_track$sec<50552.88) |
                          (data_track$source_transect_id=="2012-03-17_NJM" & data_track$sec>38314.48 & data_track$sec<50667.39) |
                          (data_track$source_transect_id=="2012-05-06_TPW" & data_track$sec>39594.03 & data_track$sec<50499.67) |
                          (data_track$source_transect_id=="2012-05-06_TPW" & data_track$sec>54517.11 & data_track$sec<55196.38) |
                          (data_track$source_transect_id=="2012-05-06_TPW" & data_track$sec>55322.27 & data_track$sec<55329.07) |
                          (data_track$source_transect_id=="2012-05-06_NJM" & data_track$sec>39568.03 & data_track$sec<50499.67) |
                          (data_track$source_transect_id=="2012-05-06_NJM" & data_track$sec>54517.11 & data_track$sec<55329.07) |
                          (data_track$source_transect_id=="2012-05-12_TPW" & data_track$sec>37751.25 & data_track$sec<49072.69) |
                          (data_track$source_transect_id=="2012-05-12_NJM" & data_track$sec>37724.60 & data_track$sec<49114.46) |
                          (data_track$source_transect_id=="2012-06-28_TPW" & data_track$sec>36947.20 & data_track$sec<48475.59) |
                          (data_track$source_transect_id=="2012-06-28_NJM" & data_track$sec>36927.54 & data_track$sec<48551.60) |
                          (data_track$source_transect_id=="2012-07-31_TPW" & data_track$sec>35277.78 & data_track$sec<47331.34) |
                          (data_track$source_transect_id=="2012-07-31_NJM" & data_track$sec>35267.79 & data_track$sec<47331.34) |
                          (data_track$source_transect_id=="2012-08-22_TPW" & data_track$sec>40490.92 & data_track$sec<51813.45) |
                          (data_track$source_transect_id=="2012-08-22_TPW" & data_track$sec>52265.20 & data_track$sec<52647.91) |
                          (data_track$source_transect_id=="2012-08-22_NJM" & data_track$sec>40455.65 & data_track$sec<52766.17) |
                          (data_track$source_transect_id=="2012-10-02_TPW" & data_track$sec>34958.09 & data_track$sec<47032.73) |
                          (data_track$source_transect_id=="2012-10-02_NJM" & data_track$sec>34942.29 & data_track$sec<47032.73) |
                          (data_track$source_transect_id=="2012-10-26_TPW" & data_track$sec>36702.44 & data_track$sec<48719.53) |
                          (data_track$source_transect_id=="2012-10-26_NJM" & data_track$sec>36684.29 & data_track$sec<48844.35) |
                          (data_track$source_transect_id=="2012-11-05_TPW" & data_track$sec>37822.48 & data_track$sec<49915.90) |
                          (data_track$source_transect_id=="2012-11-05_NJM" & data_track$sec>37794.06 & data_track$sec<49915.90) |
                          (data_track$source_transect_id=="2012-11-12_TPW" & data_track$sec>39133.52 & data_track$sec<51316.36) |
                          (data_track$source_transect_id=="2012-11-12_NJM" & data_track$sec>39116.79 & data_track$sec<51423.97),]
data_track=bind_rows(data_track,hold) %>% arrange(date, sec)
rm(hold)
#---------------------------#


#---------------------------#
# fromat transects from track
#---------------------------#
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(data_track, type %in% c("BEGCNT")) %>%
  group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(source_transect_id, index, start.stop.index)
new.key = left_join(data_track, break.at.each.stop, by=c("index","source_transect_id")) %>% 
  group_by(source_transect_id) %>% 
  mutate(start.stop.index = na.locf(start.stop.index)) %>% ungroup %>%
  mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% select(-start.stop.index)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(lon, default = last(lon), order_by = sec),
         lagged.lat = lead(lat, default = last(lat), order_by = sec)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(lon, lat), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>% 
  group_by(newkey) %>%  
  summarise(observer = first(observer),
            source_transect_id = first(source_transect_id),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(lon),
            temp_stop_lon = last(lon),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_sec = first(sec), 
            end_sec = last(sec),
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id)
#
data_transect = df %>% 
  group_by(source_transect_id)  %>% 
  arrange(start_sec) %>% 
  summarise(observer = first(observer),
            temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            start_dt = as.character(first(start_dt)),
            end_dt = as.character(last(end_dt)),
            time_from_midnight_start = first(start_sec), 
            time_from_midnight_stop  = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb),
            transect_distance_nb = sum(transect_distance_nb))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
  mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) 
rm(df, new.key, break.at.each.stop)
#---------------------------#

#---------------------------#
# formatting so things dont get rewritten
#---------------------------#
data = data %>% rename(weather_tx=condition) %>%
  mutate(comments = paste(comment, comments, sep = "; "),
         comments = replace(comments,comments=="NA; NA",NA)) %>% select(-transect,-year,-month,-day,-comment) 
data_track = data_track %>% rename(weather_tx=condition) %>%
  mutate(comments = paste(comment, comments, sep = "; "),
         comments = replace(comments,comments=="NA; NA",NA)) %>% select(-transect,-year,-month,-day)
#---------------------------#



#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#



#---------------------------#
# packages
#---------------------------#
require(dplyr)
require(zoo)
require(geosphere)
#---------------------------#


#---------------------------#
# directories
#---------------------------#
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/MassCEC/year2_2013"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"year2_2013_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"year2_2013_track.csv",sep="/"))
id = 161
#---------------------------#


#---------------------------#
# format track and obs
#---------------------------#
data_track = bind_rows(data_track, filter(data, type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN"))) %>%
  mutate(type = replace(type, type %in% "BEGTRAN", "BEGCNT"),
         type = replace(type, type %in% "ENDTRAN", "ENDCNT"),
         date = as.Date(paste(year, month, day, sep="/"))) %>% 
  arrange(date, sec)
data = data %>% filter(., !type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN")) %>% 
  mutate(date = as.Date(paste(year, month, day, sep="/")),
         source_transect_id = paste(date, observer, sep="_")) %>% 
  arrange(date, sec)

# fix errors
data_track$observer[data_track$seat=="rr"] = "BCH"
data_track$observer[data_track$seat=="lr"] = "TPW"
data_track$observer[data_track$seat=="lrrr"] = "TPWBCH"
data_track = mutate(data_track, source_transect_id = paste(date, observer, sep="_"))

# remove
data_track$key = as.character(data_track$key)
data_track$key[data_track$index==1130.0 & data_track$seat=="rr" & data_track$type=="ENDCNT"]="to.remove"
data_track$key[data_track$index==35689.0 & data_track$seat=="lr"][1]="to.remove"
data_track = data_track[!data_track$key %in% "to.remove",]

# only include on transect track 
hold = data_track %>% filter(type %in% c("BEGCNT","ENDCNT"))
data_track = data_track[(data_track$source_transect_id=="2013-01-21_TPW" & data_track$sec>41046.68 & data_track$sec<51922.77) |
                          (data_track$source_transect_id=="2013-01-21_BCH" & data_track$sec>41046.68 & data_track$sec<51938.71) |
                          (data_track$source_transect_id=="2013-03-30_TPW" & data_track$sec>39365.50 & data_track$sec<50495.98) |
                          (data_track$source_transect_id=="2013-03-30_BCH" & data_track$sec>39350.53 & data_track$sec<50550.51) |
                          (data_track$source_transect_id=="2013-04-15_TPW" & data_track$sec>39852.94 & data_track$sec<51312.34) |
                          (data_track$source_transect_id=="2013-04-15_BCH" & data_track$sec>39831.65 & data_track$sec<51369.79) |
                          (data_track$source_transect_id=="2013-05-15_TPW" & data_track$sec>39131.81 & data_track$sec<50867.45) |
                          (data_track$source_transect_id=="2013-05-15_BCH" & data_track$sec>39108.84 & data_track$sec<50958.98) |
                          (data_track$source_transect_id=="2013-06-22_TPW" & data_track$sec>39697.22 & data_track$sec<51691.61) |
                          (data_track$source_transect_id=="2013-06-22_BCH" & data_track$sec>39670.51 & data_track$sec<51822.56) |
                          (data_track$source_transect_id=="2013-07-31_TPW" & data_track$sec>41936.44 & data_track$sec<53359.33) |
                          (data_track$source_transect_id=="2013-07-31_BCH" & data_track$sec>41874.37 & data_track$sec<53440.37) |
                          (data_track$source_transect_id=="2013-08-19_TPW" & data_track$sec>38235.73 & data_track$sec<49374.50) |
                          (data_track$source_transect_id=="2013-08-19_BCH" & data_track$sec>38218.87 & data_track$sec<49460.51) |
                          (data_track$source_transect_id=="2013-09-11_TPW" & data_track$sec>42686.58 & data_track$sec<54709.70) |
                          (data_track$source_transect_id=="2013-09-11_TPW" & data_track$sec>54709.70 & data_track$sec<54846.51) |
                          (data_track$source_transect_id=="2013-09-11_BCH" & data_track$sec>42642.73 & data_track$sec<54846.51) |
                          (data_track$source_transect_id=="2013-10-15_TPWBCH" & data_track$sec>49906.50 & data_track$sec<57755.61) |
                          (data_track$source_transect_id=="2013-10-29_TPWBCH" & data_track$sec>40044.15 & data_track$sec<51809.59) |
                          (data_track$source_transect_id=="2013-11-06_TPW" & data_track$sec>37704.70 & data_track$sec<49027.69) |
                          (data_track$source_transect_id=="2013-11-06_BCH" & data_track$sec>37688.63 & data_track$sec<49118.79) |
                          (data_track$source_transect_id=="2013-11-26_TPW" & data_track$sec>43679.56 & data_track$sec<52967.42) |
                          (data_track$source_transect_id=="2013-11-30_TPW" & data_track$sec>38425.17 & data_track$sec<49538.08) |
                          (data_track$source_transect_id=="2013-11-30_BCH" & data_track$sec>38394.67 & data_track$sec<49634.96) |
                          (data_track$source_transect_id=="2013-12-04_TPW" & data_track$sec>38166.27 & data_track$sec<49834.47) |
                          (data_track$source_transect_id=="2013-12-04_BCH" & data_track$sec>38135.81 & data_track$sec<49949.93),]
data_track=bind_rows(data_track,hold) %>% arrange(date, sec)
rm(hold)
#---------------------------#                          
       
                   
#---------------------------#
# fromat transects from track
#---------------------------#
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(data_track, type %in% c("BEGCNT")) %>%
  group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(source_transect_id, index, start.stop.index)
new.key = left_join(data_track, break.at.each.stop, by=c("index","source_transect_id")) %>% 
  group_by(source_transect_id) %>% 
  mutate(start.stop.index = na.locf(start.stop.index)) %>% ungroup %>%
  mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% select(-start.stop.index)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(lon, default = last(lon), order_by = sec),
         lagged.lat = lead(lat, default = last(lat), order_by = sec)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(lon, lat), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>% 
  group_by(newkey) %>%  
  summarise(observer = first(observer),
            source_transect_id = first(source_transect_id),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(lon),
            temp_stop_lon = last(lon),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_sec = first(sec), 
            end_sec = last(sec),
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id)
#
data_transect = df %>% 
  group_by(source_transect_id)  %>% 
  arrange(start_sec) %>% 
  summarise(observer = first(observer),
            temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            start_dt = as.character(first(start_dt)),
            end_dt = as.character(last(end_dt)),
            time_from_midnight_start = first(start_sec), 
            time_from_midnight_stop  = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb),
            transect_distance_nb = sum(transect_distance_nb))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
  mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) 
rm(df, new.key, break.at.each.stop)
#---------------------------#


#---------------------------#
# formatting so things dont get rewritten
#---------------------------#
data = data %>% rename(weather_tx=condition) %>% select(-transect,-year,-month,-day,-comment) 
data_track = data_track %>% rename(weather_tx=condition) %>% select(-transect,-year,-month,-day)
#---------------------------#



#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#



#---------------------------#
# packages
#---------------------------#
require(dplyr)
require(zoo)
require(geosphere)
#---------------------------#


#---------------------------#
# directories
#---------------------------#
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/MassCEC/year3_2014to2015"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"year3_2014to2015_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"year3_2014to2015_track.csv",sep="/"))
id = 162
#---------------------------#


#---------------------------#
# format track and obs
#---------------------------#
data_track = bind_rows(data_track, filter(data, type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN"))) %>%
  mutate(type = replace(type, type %in% "BEGTRAN", "BEGCNT"),
         type = replace(type, type %in% "ENDTRAN", "ENDCNT"),
         date = as.Date(paste(year, month, day, sep="/"))) %>% 
  arrange(date, sec)
data = data %>% filter(., !type %in% c("BEGCNT","ENDCNT","BEGTRAN","ENDTRAN")) %>% 
  mutate(date = as.Date(paste(year, month, day, sep="/")),
         source_transect_id = paste(date, observer, sep="_")) %>% 
  arrange(date, sec)

# fix errors


# remove

# only include on transect track 
hold = data_track %>% filter(type %in% c("BEGCNT","ENDCNT"))
data_track = data_track[(data_track$source_transect_id=="" & data_track$sec> & data_track$sec<) |
                         ,]
data_track=bind_rows(data_track,hold) %>% arrange(date, sec)
rm(hold)
#---------------------------#                          


#---------------------------#
# fromat transects from track
#---------------------------#
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(data_track, type %in% c("BEGCNT")) %>%
  group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(source_transect_id, index, start.stop.index)
new.key = left_join(data_track, break.at.each.stop, by=c("index","source_transect_id")) %>% 
  group_by(source_transect_id) %>% 
  mutate(start.stop.index = na.locf(start.stop.index)) %>% ungroup %>%
  mutate(newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% select(-start.stop.index)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(lon, default = last(lon), order_by = sec),
         lagged.lat = lead(lat, default = last(lat), order_by = sec)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(lon, lat), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>% 
  group_by(newkey) %>%  
  summarise(observer = first(observer),
            source_transect_id = first(source_transect_id),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(lon),
            temp_stop_lon = last(lon),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_sec = first(sec), 
            end_sec = last(sec),
            transect_time_min_nb = (end_sec-start_sec)/60)  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id)
#
data_transect = df %>% 
  group_by(source_transect_id)  %>% 
  arrange(start_sec) %>% 
  summarise(observer = first(observer),
            temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            start_dt = as.character(first(start_dt)),
            end_dt = as.character(last(end_dt)),
            time_from_midnight_start = first(start_sec), 
            time_from_midnight_stop  = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb),
            transect_distance_nb = sum(transect_distance_nb))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
  mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) 
rm(df, new.key, break.at.each.stop)
#---------------------------#


#---------------------------#
# formatting so things dont get rewritten
#---------------------------#
data = data %>% rename(weather_tx=condition) %>% select(-transect,-year,-month,-day,-comment) 
data_track = data_track %>% rename(weather_tx=condition) %>% select(-transect,-year,-month,-day)
#---------------------------#


