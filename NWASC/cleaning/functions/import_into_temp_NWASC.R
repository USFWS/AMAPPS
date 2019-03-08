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

#import_into_temp_NWASC <- function(id, data, data_track, data_transect, data_camera) {
  
  # ------------------------ #
  # load packages / functions
  # ------------------------ #
  library(odbc)
  library(RODBC)
  library(dplyr)
  library(geosphere) # distance
  library(zoo)
  library(lubridate)
  
  library(R.utils)
  sourceDirectory("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/code")
  # ------------------------ #
  
  
  # ------------------------ #
  # load dataset descriptions
  # ------------------------ #
  #db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  #transects.in.db = sqlQuery(db, paste("select top 1 * from transect order by transect_id desc"))
  #tracks.in.db = sqlQuery(db, paste("select top 1 * from track order by track_id desc"))
  #obs.in.db = sqlQuery(db, paste("select top 1 * from observation order by observation_id desc"))
  #camera.in.db = sqlQuery(db, paste("select top 1 * from camera order by camera_id desc"))
  #odbcCloseAll()
  
  # when adding multiple datasets in a row that are in numeric order
  db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlQuery(db, paste("select * from transect where dataset_id in (", id-1, ",", id, ")",sep=""))
  tracks.in.db = sqlQuery(db, paste("select * from track where dataset_id in (", id-1, ",", id, ")",sep=""))
  obs.in.db = sqlQuery(db, paste("select * from observation where dataset_id in (", id-1, ",", id, ")",sep=""))
  camera.in.db = sqlQuery(db, paste("select * from camera_effort where dataset_id in (", id-1, ",", id, ")",sep=""))
  
  
  db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
  data.in.db = dbGetQuery(db,"select * from dataset")
  dbDisconnect(db)
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
  # format tables
  # ------------------------ #
  dat = format_observations(data)
  if(exists("data_track")){
    dat_track = format_tracks(data_track)
    dat_transect = if(exists("data_transect")){format_transects(data_transect)}else create_transect_table(dat_track)
  }
  #dat_camera = format_camera(data_camera)
  # ------------------------ #
  
  
  # ------------------------ #
  # join transect numbers to both track and observations tables based on date
  # this will only work if the same transect is not repeated on the same day or broken -> had to add datafile
  # ------------------------ #
  if(exists("dat_track")){
    dat_track = left_join(dat_track, select(dat_transect, source_transect_id, transect_id, start_dt), 
                          by=c("source_transect_id", "track_dt" = "start_dt")) %>%
      rename(transect_id = transect_id.y) %>% select(-transect_id.x)
  }
  
  dat =  left_join(dat, select(dat_transect, source_transect_id, transect_id, start_dt), 
                   by=c("source_transect_id", "obs_dt" = "start_dt")) %>%
    rename(transect_id = transect_id.y) %>% select(-transect_id.x)
  
  if(exists("dat_camera")){
    dat_camera = dat_camera %>% rename(start_dt = camera_dt) 
    dat_camera = left_join(dat_camera, select(dat_transect, source_transect_id, transect_id, start_dt), by=c("source_transect_id","start_dt")) %>%
      mutate(transect_id.x = transect_id.y) %>% rename(transect_id = transect_id.x, camera_dt = start_dt) %>% select(-transect_id.y)
  }
  #}
  # ------------------------ #
  
  # visually inspect data
  # ------------------------ #
  
  # ------------------------ #
  # add to NWASC temporary db
  # ------------------------ #
  dat = dat[,colnames(obs.in.db)] #reorder
  
  db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  sqlSave(db, dat, tablename = "observation", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)
  if(exists("dat_track")){sqlSave(db, dat_track, tablename = "track", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  if(exists("dat_transect")){sqlSave(db, dat_transect, tablename = "transect", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  if(exists("dat_camera")){sqlSave(db, dat_camera, tablename = "camera_effort", append=TRUE, rownames=FALSE, colnames=FALSE, verbose=FALSE)}
  odbcClose(db) 
  
  # # if errors delete from table if half uploaded or uploaded twice etc. 
  # db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  # sqlQuery(db, paste("delete from observation where dataset_id = ", id, sep=""))
  # sqlQuery(db, paste("delete from transect where dataset_id = ", id, sep=""))
  # sqlQuery(db, paste("delete from track where dataset_id = ", id, sep=""))
  # # then redo
  # ------------------------ #
  
  
  # ------------------------ #
  # check that all was uploaded
  # ------------------------ #
  db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  transects.in.db = sqlQuery(db, paste("select * from transect where dataset_id = ", id, sep=""))
  tracks.in.db = sqlQuery(db, paste("select * from track where dataset_id = ", id, sep=""))
  obs.in.db = sqlQuery(db, paste("select * from observation where dataset_id = ", id, sep=""))
  camera.in.db = sqlQuery(db, paste("select * from camera_effort where dataset_id = ", id, sep=""))
  odbcCloseAll()
  
  #import_reports(obs.in.db) 
  #import_reports(obs.in.db,transects.in.db) 
  import_reports(obs.in.db,transects.in.db,tracks.in.db) 
  #import_reports(obs.in.db,transects.in.db,tracks.in.db,camera.in.db) 
  # ------------------------ #
        
  
  # ------------------------ #
  # export as csv in case we need to rebuild the database
  # ------------------------ #
  dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/completed/NWASC_dataset_copies/"
  write.csv(dat, file=paste(dir.out,"observations_", id, ".csv", sep=""), row.names = FALSE)
  if(exists("dat_track")){write.csv(dat_track, file=paste(dir.out,"track_", id, ".csv", sep=""), row.names = FALSE)}
  if(exists("dat_transect")){write.csv(dat_transect, file=paste(dir.out,"transect_", id, ".csv", sep=""), row.names = FALSE)}
  if(exists("dat_camera")){write.csv(dat_camera, file=paste(dir.out,"camera_effort_", id, ".csv", sep=""), row.names = FALSE)}
  # ------------------------ #
  
  
  rm(list=ls())
  
#}
