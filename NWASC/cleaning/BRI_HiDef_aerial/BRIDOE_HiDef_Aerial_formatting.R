#---------------------------#
# format DOE BRI Aerial camera data
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
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/BRI_DOE_HiDef/BRI_DOE_HiDef_2012_to_2014"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2012_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2012_track.csv",sep="/"))
data_transect = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2012_transect.csv",sep="/"))
data_camera = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2012_camera.csv",sep="/"))
id = 115
#---------------------------#


#---------------------------#
# format track
#---------------------------#
data_track = data_track %>%
  mutate(type = as.character(type),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT")) %>%
  arrange(track_dt, source_transect_id)
#---------------------------#


#---------------------------#
# format transect
#---------------------------#
data_transect = data_transect %>%
  select(-start_track_time_gmt, -end_track_time_gmt, -track_date, -survey_month, 
         -hideftransect, -survey_year, -britransectid) 
#---------------------------#


#---------------------------#
# format transect
#---------------------------#
data_camera = rename(data_camera, reel=seq) 
#---------------------------#

#---------------------------#
# fix errors
#---------------------------#
# duplicates
data_transect[duplicated(data_transect[c("source_transect_id","start_dt")]),]
data_transect$source_transect_id[data_transect$fid==449] = 16.1 
data_transect$source_transect_id[data_transect$fid==235] = 45.1  
data_transect$source_transect_id[data_transect$fid==236] = 46.1 
data_transect$source_transect_id[data_transect$fid==48] = 52.1 
data_transect$source_transect_id[data_transect$fid==246] = 55.1 
data_transect$source_transect_id[data_transect$fid==259] = 64.1 
data_transect$source_transect_id[data_transect$fid==258] = 65.1
data_transect$source_transect_id[data_transect$fid==257] = 66.1  
data_transect$source_transect_id[data_transect$fid==412] = 95.1
data_transect$source_transect_id[data_transect$fid==303] = 99.1 
data_transect$source_transect_id[data_transect$fid==304] = 100.1 
data_transect$source_transect_id[data_transect$fid==297] = 103.1  
data_transect$source_transect_id[data_transect$fid==316] = ""  

# fix source id in track
data_track$source_transect_id[data_track$index %in% c(715,716)] = 16.1
data_track$source_transect_id[data_track$index %in% c(489,490)] = 45.1
data_track$source_transect_id[data_track$index %in% c(493,494)] = 46.1
data_track$source_transect_id[data_track$index %in% c(45,46)] = 52.1
data_track$source_transect_id[data_track$index %in% c(515,516)] = 55.1 
data_track$source_transect_id[data_track$index %in% c(537,538)] = 64.1
data_track$source_transect_id[data_track$index %in% c(541,542)] = 65.1
data_track$source_transect_id[data_track$index %in% c(545,546)] = 66.1
data_track$source_transect_id[data_track$index %in% c(891,892)] = 95.1
data_track$source_transect_id[data_track$index %in% c(677,678)] = 99.1
data_track$source_transect_id[data_track$index %in% c(587,588)] = 100.1
data_track$source_transect_id[data_track$index %in% c(595,596)] = 103.1
data_track$source_transect_id[data_track$index %in% c(681,682)] = ""

# create date time
data_track = data_track %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(track_dt), track_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data = data %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(obs_dt), obs_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data_camera = data_camera %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(camera_dt), start_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))

# fix duplicates in obs
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(715)] & 
                          data$date_time <= data_track$date_time[data_track$index %in% c(716)])  & 
                          data$source_transect_id %in% 16] = 16.1
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(891)] & 
                          data$date_time <= data_track$date_time[data_track$index %in% c(892)] & 
                          data$source_transect_id %in% 95)] = 95.1
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(677)] & 
                           data$date_time <= data_track$date_time[data_track$index %in% c(678)] & 
                           data$source_transect_id %in% 99)] = 99.1
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(587)] & 
                           data$date_time <= data_track$date_time[data_track$index %in% c(588)] & 
                           data$source_transect_id %in% 100)] = 100.1

# camera
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(715)] & 
                           data_camera$date_time <= data_track$date_time[data_track$index %in% c(716)])  & 
                          data_camera$source_transect_id %in% 16] = 16.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(489)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(490)])  & 
                                 data_camera$source_transect_id %in% 45] = 45.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(493)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(494)])  & 
                                 data_camera$source_transect_id %in% 46] = 46.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(45)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(46)])  & 
                                 data_camera$source_transect_id %in% 52] = 52.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(515)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(516)])  & 
                                 data_camera$source_transect_id %in% 55] = 55.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(537)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(538)])  & 
                                 data_camera$source_transect_id %in% 64] = 64.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(541)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(542)])  & 
                                 data_camera$source_transect_id %in% 65] = 65.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(545)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(546)])  & 
                                 data_camera$source_transect_id %in% 66] = 66.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(891)] & 
                           data_camera$date_time <= data_track$date_time[data_track$index %in% c(892)] & 
                           data_camera$source_transect_id %in% 95)] = 95.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(677)] & 
                           data_camera$date_time <= data_track$date_time[data_track$index %in% c(678)] & 
                           data_camera$source_transect_id %in% 99)] = 99.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(587)] & 
                           data_camera$date_time <= data_track$date_time[data_track$index %in% c(588)] & 
                           data_camera$source_transect_id %in% 100)] = 100.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(595)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(596)])  & 
                                 data_camera$source_transect_id %in% 103] = 103.1
#---------------------------#


#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#

#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2013_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2013_track.csv",sep="/"))
data_transect = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2013_transect.csv",sep="/"))
data_camera = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2013_camera.csv",sep="/"))
id = 148
#---------------------------#


#---------------------------#
# format track
#---------------------------#
data_track = data_track %>%
  mutate(type = as.character(type),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT")) %>%
  arrange(track_dt, source_transect_id)
#---------------------------#


#---------------------------#
# format transect
#---------------------------#
data_transect = data_transect %>%
  select(-start_track_time_gmt, -end_track_time_gmt, -track_date, -survey_month, 
         -hideftransect, -survey_year, -britransectid) 
#---------------------------#


#---------------------------#
# fix errors
#---------------------------#
# duplicates
data_transect[duplicated(data_transect[c("source_transect_id","start_dt")]),]
data_transect$source_transect_id[data_transect$fid==778] = 56.1
data_transect$source_transect_id[data_transect$fid==780] = 56.2
data_transect$source_transect_id[data_transect$fid==917] = 89.1
data_transect$source_transect_id[data_transect$fid==1128] = 82.1

# fix source id in track
data_track$source_transect_id[data_track$index %in% c(1577,1578)] = 56.1
data_track$source_transect_id[data_track$index %in% c(1579,1580)] = 56.2
data_track$source_transect_id[data_track$index %in% c(1833,1834)] = 89.1
data_track$source_transect_id[data_track$index %in% c(2261,2262)] = 82.1

# create date time
data_track = data_track %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(track_dt), track_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data = data %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(obs_dt), obs_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data_camera = data_camera %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(camera_dt), start_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))

# fix duplicates in obs
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(1579)] & 
                          data$date_time <= data_track$date_time[data_track$index %in% c(1580)] & 
                           data$source_transect_id==56)] = 56.2 

# not on transect 56, since not counting offline assign to 56.2 which is closet in time
data$source_transect_id[(data$date_time >= data_track$date_time[data_track$index %in% c(1578)] & 
                           data$date_time <= data_track$date_time[data_track$index %in% c(1579)] & 
                           data$source_transect_id==56)] = 56.2
data$comments_tx = as.character(data$comments_tx)
data$comments_tx[(data$date_time >= data_track$date_time[data_track$index %in% c(1578)] &
                    data$date_time <= data_track$date_time[data_track$index %in% c(1579)] & 
                    data$source_transect_id==56.2)] = paste(data$comments_tx[(data$date_time >= data_track$date_time[data_track$index %in% c(1578)] &
                                                                                data$date_time <= data_track$date_time[data_track$index %in% c(1579)] & 
                                                                                data$source_transect_id==56.2)], 
                                                            "; Changed source_transect_id from 56 to 56.2 since observation was outside of time range for transect 56 and the survey design does not count offline birds",
                                                            sep="")

# camera
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(1577)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(1578)] & 
                                  data_camera$source_transect_id==56)] = 56.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(1579)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(1580)] & 
                                  data_camera$source_transect_id==56)] = 56.2
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(2261)] & 
                                  data_camera$date_time <= data_track$date_time[data_track$index %in% c(2262)] &
                                  data_camera$source_transect_id==82)] = 82.1
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(1833)] & 
                           data_camera$date_time <= data_track$date_time[data_track$index %in% c(1844)] & 
                           data_camera$source_transect_id==89)] = 89.1
#---------------------------#


#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#
#------------------------------------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2014_obs.csv",sep="/"))
data_track = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2014_track.csv",sep="/"))
data_transect = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2014_transect.csv",sep="/"))
data_camera = read.csv(paste(dir,"BRIDOE_HiDef_Aerial_2014_camera.csv",sep="/"))
id = 168
#---------------------------#


#---------------------------#
# format track
#---------------------------#
data_track = data_track %>%
  mutate(type = as.character(type),
         type = replace(type, type=="BEGTRAN","BEGCNT"),
         type = replace(type, type=="ENDTRAN","ENDCNT")) %>%
  arrange(track_dt, source_transect_id)
#---------------------------#


#---------------------------#
# format transect
#---------------------------#
data_transect = data_transect %>%
  select(-start_track_time_gmt, -end_track_time_gmt, -track_date, -survey_month, 
         -hideftransect, -survey_year, -britransectid) 


#---------------------------#
# fix errors
#---------------------------#
# duplicates
data_transect[duplicated(data_transect[c("source_transect_id","start_dt")]),]
data_transect$source_transect_id[data_transect$fid==1692]=149.1
data_transect$source_transect_id[data_transect$fid==1696]=149.2

# fix source id in track
data_track$source_transect_id[data_track$index %in% c(3453:3456)] = 149.1
data_track$source_transect_id[data_track$index %in% c(3457,3458)] = 149.2

# fix duplicate 149s in obs
data_track = data_track %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(track_dt), track_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data = data %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(obs_dt), obs_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))
data_camera = data_camera %>% 
  mutate(date_time = as.POSIXct(paste(as.Date(camera_dt), start_tm, sep=" "), format="%Y-%m-%d %H:%M:%S"))

# not observations for 149.1
data$source_transect_id[(data$date_time > data_track$date_time[data_track$index %in% c(3457)] & 
                           data$date_time < data_track$date_time[data_track$index %in% c(3458)])] = 149.2
# camera
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(3457)]) & 
                           (data_camera$date_time <= data_track$date_time[data_track$index %in% c(3458)])] = 149.2
data_camera$source_transect_id[(data_camera$date_time >= data_track$date_time[data_track$index %in% c(3453)]) & 
                                  (data_camera$date_time <= data_track$date_time[data_track$index %in% c(3454)]) | 
                                 (data_camera$date_time >= data_track$date_time[data_track$index %in% c(3455)]) & 
                                 (data_camera$date_time <= data_track$date_time[data_track$index %in% c(3456)])] = 149.1
#---------------------------#
