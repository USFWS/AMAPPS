# ------------------------ #
# combine old and new seabird catalog data
# ------------------------ #


# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
library(dplyr)
library(sp)  # vector data
library(raster)  # raster data
library(rgdal)  # input/output, projections
library(rgeos)  # geometry ops
# ------------------------ #


# ------------------------ #
# load dataset descriptions
# ------------------------ #
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects.in.db = sqlFetch(db, "transect")
tracks.in.db = sqlFetch(db, "track")
data.in.db = sqlFetch(db, "dataset")
obs.in.db = sqlFetch(db, "observation")
odbcClose(db)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_sent/DavidBigger_Mar2017"
dir.archive = "//IFW9mbm-fs1/SeaDuck/seabird_database/database_export/archive/seabird_database_obs_trans_tbls_April2016"
dir.from.segmentation = "//IFW9mbm-fs1/SeaDuck/Kyle_Working_Folder/Segmentation/Data/transect_shp_files"
# ------------------------ #


# ------------------------ #
# load archive observations
# and transects
# ------------------------ #
# read in old obs data
old_obs = read.csv(file = paste(dir.archive, "vw_obs.csv", sep="/"), header=TRUE, quote="", row.names=NULL, stringsAsFactors = FALSE)
# assuming this is an export error?
old_obs$observation_id = as.numeric(as.character(old_obs$observation_id))
old_obs = old_obs[!is.na(old_obs$observation_id),]
old_obs$transect_id = as.numeric(as.character(old_obs$transect_id))
old_obs$source_obs_id = as.numeric(as.character(old_obs$source_obs_id))
old_obs$obs_count_intrans_nb = as.numeric(as.character(old_obs$obs_count_intrans_nb))
old_obs$obs_count_general_nb = as.numeric(as.character(old_obs$obs_count_general_nb))
old_obs$angle_from_observer_nb = as.numeric(as.character(old_obs$angle_from_observer_nb))
old_obs$seastate_beaufort_nb = as.numeric(as.character(old_obs$seastate_beaufort_nb))
old_obs$seasurface_tempc_nb = as.numeric(as.character(old_obs$seasurface_tempc_nb))
old_obs$who_created = as.numeric(as.character(old_obs$who_created))
old_obs$temp_lat = as.numeric(as.character(old_obs$temp_lat))
old_obs$temp_lon = as.numeric(as.character(old_obs$temp_lon))
old_obs$who_imported = as.numeric(as.character(old_obs$who_imported))
old_obs$salinity_ppt_nb = as.numeric(as.character(old_obs$salinity_ppt_nb))
old_obs$local_obs_id = as.numeric(as.character(old_obs$local_obs_id))
old_obs$heading_tx = as.character(old_obs$heading_tx)
old_obs = old_obs[!is.na(old_obs$dataset_id),]

# read in old transect data
old_transects = read.csv(file = paste(dir.archive, "vw_trans.csv", sep="/"), header=TRUE)
# assuming this is an export error?
old_transects$transect_id = as.numeric(as.character(old_transects$transect_id))
old_transects = old_transects[!is.na(old_transects$transect_id),]
old_transects$dataset_id = as.numeric(as.character(old_transects$dataset_id))
old_transects = old_transects[!is.na(old_transects$dataset_id),]
old_transects$seastate_beaufort_nb = as.numeric(as.character(old_transects$seastate_beaufort_nb))
old_transects$seasurface_tempc_nb = as.numeric(as.character(old_transects$seasurface_tempc_nb))
old_transects$heading_tx = as.numeric(as.character(old_transects$heading_tx))

# read in old track data
lines = readOGR(dir.from.segmentation,"line")
points = readOGR(dir.from.segmentation,"point")

# transform projection
lines = spTransform(lines, CRS("+proj=longlat +datum=WGS84"))
points = spTransform(points, CRS("+proj=longlat +datum=WGS84"))

# turn into a dataframe
old_transect_lines = as(as(lines, "SpatialPointsDataFrame"),"data.frame")
old_transect_points = as(points, "data.frame")

# formatting
old_transect_lines = old_transect_lines %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1) %>% 
  dplyr::select(-Lines.NR, -Lines.ID, -Line.NR)
old_transect_points = old_transect_points %>%
  rename(transect_id = transect_i,
         track_lat = coords.x2,
         track_lon = coords.x1)
# ------------------------ #


# ------------------------ #
# fix archived observation species codes
# ------------------------ #
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

tmp <- !old_obs$spp_cd %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(old_obs$spp_cd[tmp]))
rm(spplist)

old_obs$spp_cd[old_obs$spp_cd %in% c(" ATLANTIC")] = "ATPU"              
old_obs$spp_cd[old_obs$spp_cd %in% c(" Balaenidae")] = "UNLW"
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("SCOTER")] = "BLSC" 
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLACK") & old_obs$original_species_tx %in% c("GUILLEMOT")] = "BLGU"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" blackfish")] = "SFWH"              
old_obs$spp_cd[old_obs$spp_cd %in% c(" BLK-LEGGD")] = "BLKI"             
old_obs$spp_cd[old_obs$spp_cd %in% c(" BROWN")] = "BRPE"                  
old_obs$spp_cd[old_obs$spp_cd %in% c(" COMMON") & old_obs$original_species_tx %in% c("LOON")] = "COLO"
old_obs$spp_cd[old_obs$spp_cd %in% c(" COMMON") & old_obs$original_species_tx %in% c("EIDER")] = "COEI" 
old_obs$spp_cd[old_obs$spp_cd %in% c(" CORY'S")] = "COSH"                 
old_obs$spp_cd[old_obs$spp_cd %in% c(" DBL CREST")] = "DCCO"              
old_obs$spp_cd[old_obs$spp_cd %in% c(" FBSP)")] = "UNFR"                 
old_obs$spp_cd[old_obs$spp_cd %in% c(" goose-beaked whale")] = "CBWH"     
old_obs$spp_cd[old_obs$spp_cd %in% c(" gray grampus")] = "RIDO"           
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREAT")] = "GRCO"                  
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREAT BLK-BACK")] = "GBBG"         
old_obs$spp_cd[old_obs$spp_cd %in% c(" GREATER")] = "GRSH"               
old_obs$spp_cd[old_obs$spp_cd %in% c(" GUGE")] = "UNGU"                   
old_obs$spp_cd[old_obs$spp_cd %in% c(" HERRING")] = "HERG"                
old_obs$spp_cd[old_obs$spp_cd %in% c(" HORNED")] = "HOGR"                
old_obs$spp_cd[old_obs$spp_cd %in% c(" Lagenorhynchus")] = "UNDO"         
old_obs$spp_cd[old_obs$spp_cd %in% c(" LESS BLK-BACK")] = "LBBG"         
old_obs$spp_cd[old_obs$spp_cd %in% c(" LOC3)")] = "UNKN"                  
old_obs$spp_cd[old_obs$spp_cd %in% c(" MANX")] = "MASH"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("LOON")] = "UNLO"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("BIRD")] = "UNBI"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("CORMORANT")] = "UNCO"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("GREBE")] = "UNGR"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("GULL")] = "UNGU"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("MERGANSER")] = "UNME"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("MURRE")] = "UNMU"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("SHEARWATER")] = "UNSH"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("TERN")] = "UNTE"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NK") & old_obs$original_species_tx %in% c("STORM PETREL")] = "UNSP"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" NORTHERN") & old_obs$original_species_tx %in% c("GANNET")] = "NOGA"      
old_obs$spp_cd[old_obs$spp_cd %in% c(" NORTHERN") & old_obs$original_species_tx %in% c("FULMAR")] = "NOFU"  
old_obs$spp_cd[old_obs$spp_cd %in% c(" Orca or Globicephala)")] = "UNWH" 
old_obs$spp_cd[old_obs$spp_cd %in% c(" RED-THROATED")] = "RTLO"           
old_obs$spp_cd[old_obs$spp_cd %in% c(" SOOTY")] = "SOSH"                  
old_obs$spp_cd[old_obs$spp_cd %in% c(" spotter porpoise")] = "ASDO"       
old_obs$spp_cd[old_obs$spp_cd %in% c(" streaker porpoise")] = "STDO"   
old_obs$spp_cd[old_obs$spp_cd %in% c(" PEBL)")] = "UNSP"
old_obs$spp_cd[old_obs$spp_cd %in% c(" TERN)")] = "UNTE"                  
old_obs$spp_cd[old_obs$spp_cd %in% c(" THICK-BILLED")] = "TBMU"           
old_obs$spp_cd[old_obs$spp_cd %in% c(" THIN-BILLED")] = "COMU"            
old_obs$spp_cd[old_obs$spp_cd %in% c(" WHITE-WINGED")] = "WWSC"           
old_obs$spp_cd[old_obs$spp_cd %in% c(" WILSON")] = "WISP"                
old_obs$spp_cd[old_obs$spp_cd %in% c("CRTE")] = "UCRT"                    
old_obs$spp_cd[old_obs$spp_cd %in% c("TEAL")] = "UNTL"                    
old_obs$spp_cd[old_obs$spp_cd %in% c("UNPI")] = "UNSE"   
old_obs$spp_cd[old_obs$spp_cd %in% c("GLSP")] = "PIWH"  

old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("LOON")] = "UNLO"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("BIRD")] = "UNBI"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("CORMORANT")] = "UNCO"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("GREBE")] = "UNGR"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("GULL")] = "UNGU"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("MERGANSER")] = "UNME"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("MURRE")] = "UNMU"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("SHEARWATER")] = "UNSH"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("TERN")] = "UNTE"  
old_obs$spp_cd[old_obs$spp_cd %in% c("") & old_obs$original_species_tx %in% c("STORM PETREL")] = "UNSP" 
# ------------------------ #


# ------------------------ #
# combine datasets
# ------------------------ #
obs.in.db$heading_tx = as.character(obs.in.db$heading_tx)

# fix numbers based on data already present
obs.in.db$observation_id = obs.in.db$observation_id + 804175
min(obs.in.db$observation_id)
max(old_obs$observation_id)

# combine
obs_data = bind_rows(obs.in.db, old_obs)
track_data = bind_rows(tracks.in.db, old_transect_lines, old_transect_points) %>% 
  mutate(point_type = replace(point_type,point_type=="BEGTRAN","BEGCNT"),
         point_type = replace(point_type,point_type=="ENDTRAN","ENDCNT"))

min(transects.in.db$transect_id)
max(old_transects$transect_id)
transect_data = bind_rows(transects.in.db, old_transects) %>% arrange(transect_id)

# fix codes that were deleted when database was updated
obs_data$spp_cd[obs_data$spp_cd %in% "UNPI"]="UNSE" # unidentified pinniped to unidentified seal (no sea lions on east coast)
obs_data$spp_cd[obs_data$spp_cd %in% "CRTE"]="UCRT" # two codes for unidentified common or roseate tern, cut one
# ------------------------ #


# ------------------------ #
# export csv
# ------------------------ #
write.csv(obs_data, paste(dir.out, "observations.csv", sep="/"), row.names=FALSE)
write.csv(track_data, paste(dir.out, "tracks.csv", sep="/"), row.names=FALSE)
write.csv(transect_data, paste(dir.out, "transects.csv", sep="/"), row.names=FALSE)
write.csv(data.in.db, paste(dir.out, "datasets.csv", sep="/"), row.names=FALSE)

rm(old_transects, transects.in.db, transect_data, old_transect_lines, old_transect_points, data.in.db)

# remove NA's
obs_data = obs_data[!is.na(obs_data$temp_lat),]
obs_data = obs_data[!is.na(obs_data$temp_lon),]

track_data = track_data[!is.na(track_data$track_lat),]
# ------------------------ #


# ------------------------ #
# make shapefiles
# ------------------------ #
# Coerce into SpatialPointsDataframe
coordinates(obs_data) = ~temp_lon + temp_lat
coordinates(tracks.in.db) = ~track_lon + track_lat
coordinates(track_data) = ~track_lon + track_lat

# Assign projection
proj4string(obs_data)=CRS("+proj=longlat +datum=WGS84") 
proj4string(tracks.in.db)=CRS("+proj=longlat +datum=WGS84") 
proj4string(track_data)=CRS("+proj=longlat +datum=WGS84") 

# write shapefile
writeOGR(obj=obs_data, dsn=dir.out, layer="all_obs_data", driver="ESRI Shapefile") 
writeOGR(obj=tracks.in.db, dsn=dir.out, layer="new_track_data", driver="ESRI Shapefile") 
writeOGR(obj=track_data, dsn=dir.out, layer="all_track_data_as_points", driver="ESRI Shapefile") 
# old line and point track files will also be in the folder 
# since they might be easier to work with 
# ------------------------ #


