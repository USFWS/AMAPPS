import_reports <- function(obs.in.db,transects.in.db,tracks.in.db,camera.in.db) {
  if(length(obs.in.db$source_dataset_id[obs.in.db$dataset_id %in% id])!=length(dat$source_transect_id)){
    cat("There was an error in the upload of the observations table")
  }else print("Successfully uploaded observations: same # of records")
  if(any(!obs.in.db$transect_id[obs.in.db$dataset_id %in% id] %in% dat$transect_id)){
    cat("There was an error in the upload of the observations table")
  }else print("Successfully uploaded observations: same observation ids")
  #----#
  
  #----#
  if(exists("dat_transect")){
    if(length(transects.in.db$source_dataset_id[transects.in.db$dataset_id %in% id])!=length(dat_transect$source_transect_id)){
      print("There was an error in the upload of the transect table")
    }else print("Successfully uploaded transects: same # of records")
  }
  if(exists("dat_transect")){
    if(any(!transects.in.db$transect_id[transects.in.db$dataset_id %in% id] %in% dat_transect$transect_id)){
      print("There was an error in the upload of the transect table")
    }else print("Successfully uploaded transects: same transect ids")
  }
  #----#
  
  #----#
  if(exists("dat_track")){
    if(length(tracks.in.db$dataset_id[tracks.in.db$dataset_id %in% id])!=length(dat_track$source_transect_id)){
      print("There was an error in the upload of the track table")
    }else print("Successfully uploaded tracks: same # of records")
  }
  if(exists("dat_track")){
    if(any(!tracks.in.db$transect_id[tracks.in.db$dataset_id %in% id] %in% dat_track$transect_id)){
      print("There was an error in the upload of the track table")
    }else print("Successfully uploaded tracks: same track ids")
  }
  #----#
  
  #----#
  if(exists("dat_camera")){
    if(length(camera.in.db$source_dataset_id[camera.in.db$dataset_id %in% id])!=length(dat_camera$source_transect_id)){
      print("There was an error in the upload of the camera table")
    }else print("Successfully uploaded camera data: same # of records")
  }
}

#import_reports(obs.in.db) 
#import_reports(obs.in.db,transects.in.db) 
#import_reports(obs.in.db,transects.in.db,tracks.in.db) 
#import_reports(obs.in.db,transects.in.db,tracks.in.db,camera.in.db) 
# ------------------------ #

