# Tim White
# needs all obs and effort
# obs and dataset tables taken from AKN repo export just done this month

### had to export effort as shapefiles
### commands code below
# ogr2ogr -f "ESRI Shapefile" "C:/Users/kecoleman/old_nwasc" 
# "MSSQL:server=ifw9mbmsvr008; database = SeabirdCatalog; trusted_connection=yes; driver = SQL server;"
# -sql "select * from transect where Geometry.STGeometryType() = 'LINESTRING'" 
# -overwrite -nln old_nwasc_lines -nlt LINESTRING -lco "SHPT=ARC" -a_srs "EPSG:4269"

# ogr2ogr -f "ESRI Shapefile" "C:/Users/kecoleman/old_nwasc" 
# "MSSQL:server=ifw9mbmsvr008; database = SeabirdCatalog; trusted_connection=yes; driver = SQL server;"
# -sql "select * from transect where Geometry.STGeometryType() = 'POINT'" 
# -overwrite -nln old_nwasc_lines -nlt POINT -a_srs "EPSG:4269"

# -------------- #
# packages
# -------------- #
library(readxl)
require(RODBC)
require(odbc)
require(dplyr)
require(rgdal)
require(ggplot2)
# -------------- #


# -------------- #
# data
# -------------- #
# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.tracks <- sqlQuery(db, "select * from track")
new.transects <- sqlQuery(db, "select * from transect")
odbcClose(db)

# old data
# read in shapefile rather than directly from db to get lat/lons for lines
sldf = readOGR("C:/Users/kecoleman/old_nwasc/old_nwasc_lines.shp") # made using ogr2ogr
spdf = as(sldf, "SpatialPointsDataFrame")
old.effort.lines = as.data.frame(spdf)
rm(sldf, spdf)

sldf = readOGR("C:/Users/kecoleman/old_nwasc/old_nwasc_points.shp") # made using ogr2ogr
spdf = as(sldf, "SpatialPointsDataFrame")
old.effort.points = as.data.frame(spdf)
rm(sldf, spdf)

# db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
# old.effort = dbGetQuery(db,"select [Geometry].STY as latitude, 
#                             [Geometry].STX as longitude,
#                             * from transect")
#                         #where geography is not NULL")
#                         #where spatial_type_tx = 'point'")
# dbDisconnect(db)

# fix formating and rename names that were clipped when creating shapefile

#old.effort.lines = old.effort.lines %>%
old.effort.points = old.effort.points %>%
  rename(transect_id = transect_i,
         source_transect_id = source_tra,
         source_datatset_id = source_dat,
         transect_time_min_nb = transect_t,
         transect_distance_nb = transect_d,
         traversal_speed_nb = traversal_,
         transect_width_nb = transect_w,
         observers_tx = observers_,
         seastate_beaufort_nb = seastate_b,
         wind_speed_tx = wind_speed,
         wind_dir_tx = wind_dir_t,
         comments_tx = comments_t,
         conveyance_name_tx = conveyance,
         wave_height_tx = wave_heigh,
         whole_transect = whole_tran,
         local_transect_id = local_tran,
         temp_start_lat = temp_start,
         temp_start_lon = temp_sta_1,
         temp_stop_lat = temp_stop_,
         temp_stop_lon = temp_sto_1,
         observer_positiion = obs_positi,
         local_survey_id = local_surv,
         local_transect_id2 = local_tr_1,
         longitude = coords.x1,
         latitude = coords.x2) %>%
 # mutate(track_id = seq(1:length(track_id))) %>%
  dplyr::select(-who_create,-date_creat,-utm_zone,-who_import,
                -time_from_,-time_fro_1,-date_impor,-seasurface,
                -survey_typ,-spatial_ty)

old.effort = bind_rows(old.effort.lines,old.effort.points) %>%
  mutate(start_dt = as.Date(start_dt, format = "%Y/%m/%d"),
         end_dt = as.Date(end_dt, format = "%Y/%m/%d"),
         track_id = seq(1:length(start_dt))) %>% 
  dplyr::select(-Lines.NR, -Lines.ID,-Line.NR)

old.transects = old.effort %>% group_by(transect_id) %>%
  summarize(start_dt = first(start_dt),
            start_tm = first(start_tm),
            end_dt = first(end_dt),
            end_tm = first(end_tm),
            source_transect_id = first(source_transect_id),
            dataset_id, 
            source_dataset_id, 
            transect_time_nb, 
            transect_distance_nb, 
            traversal_speed_nb, 
            observers_tx, 
            weather_tx, 
            seastate_beaufort_nb, 
            wind_speed_tx, 
            wind_dir_tx, 
            comments_tx, 
            conveyance_name_tx,
            heading_tx, 
            wave_height_tx, 
            whole_transect )
  
new.tracks = mutate(new.tracks, track_id = track_id + max(old.effort$track_id),
                    transect_id = as.character(transect_id),
                    dataset_id = as.character(dataset_id)) %>%
  rename(latitude = track_lat, 
         longitude = track_lon, 
         start_tm  = track_tm,
         start_dt = track_dt,
         comments_tx = comment,
         seastate_beaufort_nb = seastate) %>% 
  mutate(start_dt = as.Date(start_dt, format = "%m/%d/%Y"),
         seastate_beaufort_nb = as.character(seastate_beaufort_nb)) %>% 
  dplyr::select(-track_gs, -piece,-datafile)
  
old.effort = rename(old.effort , observer_position = observer_positiion)

all.effort = bind_rows(old.effort, new.tracks)

#export
write.csv(all.effort, "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/TWhite_archive_Oct2018/effort.csv")

