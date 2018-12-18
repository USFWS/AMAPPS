# --------------- #
# Load and quality control the BRI HiDef aerial camera data
# prepare it for import into the NWASC
#
# created by Kaycee Coleman
# Sept. 2016
# --------------- #


# --------------- #
# LOAD PACKAGES
# --------------- #
require(rgdal)
require(dplyr)
# --------------- #


# --------------- #
# SET INPUT/OUTPUT DIRECTORY PATHS
# --------------- #
dir <- "Z://seabird_database/datasets_received"
setwd(dir)
surveyFolder = "BRI_DOE_HiDef"
yearLabel = "BRI_DOE_HiDef_2012_to_2014"

#dbpath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/DataBase"
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", paste("data_import/in_progress", surveyFolder, yearLabel, sep="/"), dir), sep = "/") 
#speciesPath <- "//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/DataProcessing/"

# SOURCE R FUNCTIONS
#source(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions/sourceDir.R"))
#sourceDir(file.path("//IFW9mbm-fs1/SeaDuck/NewCodeFromJeff_20150720/Jeff_Working_Folder/_Rfunctions"))
# --------------- #


# --------------- #
# load data
# --------------- #
## The input file geodatabase
fgdb = file.path(dir.in, "BRI_DOE_Hidef_aerialSurveys_final.gdb")

## List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list = ogrListLayers(fgdb)
#print(fc_list)

## Read the feature class
obs = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_obs_final")
stripey = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_stripey_final") # camera field of view   
transect = readOGR(dsn = fgdb,layer = "BRI_DOE_hidef_transects_final") # on effort transect

## Determine the FC extent, projection, and attribute information
# summary(obs)
# summary(stripey)
# summary(trans)

## View the feature class
# plot(obs)
# plot(stripey)
# plot(trans)
# --------------- #

# --------------- #
# editing
# --------------- #
obs =  obs %>% as.data.frame() %>% mutate(original_species_tx = ID_Category) %>% 
  rename(type = ID_Code, source_transect_id = HiDefTransect, source_obs_id = ObsID, 
         comments_tx = Comments, observer = Identifier, offline = Outside_Zone) %>% 
  select(-coords.x1, -coords.x2)
camera = as.data.frame(stripey) %>% mutate(source_transect_id = HiDefTransect)
transect = as.data.frame(transect) %>% mutate(source_transect_id = HiDefTransect)

# check species codes
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spp.in.db = sqlFetch(db, "lu_species")$spp_cd
odbcClose(db)
tmp <- !obs$type %in% spp.in.db
message("Found ", sum(tmp), " entries with non-matching AOU codes")
spp.to.fix = sort(unique(obs$type[tmp]))
rm(spp.in.db, tmp)

# fix species codes, some of these aren't exact but close
obs$type = as.character(obs$type)
obs$type[obs$type == "AKSH"] = "UNSH" #* Shearwater or 
obs$type[obs$type %in% c("CESS","SBCE","SEDO")] = "UMMM" #* Unidentified marine mammal or shark, Small beaked Cetacean, seal or dolphin          
obs$type[obs$type == "COWR"] = "CNRA"          
obs = obs[!obs$type %in% c("DUPL","NA","Nothing"),] #remove duplicates and NAs          
obs$type[obs$type == "FISS"] = "BAIT" #* Fish school larger than bait ball          
obs$type[obs$type %in% c("UNMG","FUMG")] = "UNGU" #* Unid. medium gull, Fulmar or Medium Gull         
obs$type[obs$type == "GMRA"] = "GOMR"         
obs$type[obs$type == "GRBC"] = "UNPR" #*Great Shearwater or Black-capped Petrel
obs$type[obs$type == "GSGO"]  = "SNGO"          
obs$type[obs$type == "ID Impossible"] = "UNKN" 
obs$type[obs$type == "LASH"] = "ULSB" # Large Shorebird sp.                      
obs$type[obs$type == "RSST"] = "UNSR" # Roughtail or Southern Stingray          
obs$type[obs$type == "SMSH"] = "USSB"          
obs$type[obs$type == "THSH"] = "UNTS"          
obs$type[obs$type == "TSMG"] = "UNSG" # Tern/Small or Medium Gull         
obs$type[obs$type == "UNMW"] = "UNWH"          
obs$type[obs$type == "UNRS"] = "UNRA" 
#obs = obs[!is.na(obs$type),]
  
# add count
obs$count = 1

# fix time
obs = obs %>% mutate(obs_dt = sapply(strsplit(as.character(Corrected_Date), " "), head, n=1),
                     obs_tm = sapply(strsplit(as.character(GMT), " "), tail, n=1)) %>%
  select(-Corrected_Date,-GMT)

# make names lowercase for import
names(obs) = tolower(names(obs))

# change offline Yes to 1
obs$offline = as.character(obs$offline)
obs$offline[obs$offline=="Yes"]=1
# --------------- #


# --------------- #
# reformating
# --------------- #
# reformat transect to become track file
track.start = transect %>% select(track_date, start_track_time_gmt, StartLatDD, StartLongDD, HiDefTransect) %>%
  mutate(type = "BEGTRAN") %>% rename(track_dt = track_date, track_tm = start_track_time_gmt, 
                                      lat = StartLatDD, lon = StartLongDD, source_transect_id = HiDefTransect)
track.end = transect %>% select(track_date, end_Track_time_gmt, EndLatDD, EndLongDD, HiDefTransect) %>%
  mutate(type = "ENDTRAN") %>% rename(track_dt = track_date, track_tm = end_Track_time_gmt, 
                                      lat = EndLatDD, lon = EndLongDD, source_transect_id = HiDefTransect)
track = bind_rows(track.start, track.end) %>% arrange(track_dt, source_transect_id, track_tm, type) %>%
  mutate(track_dt = sapply(strsplit(as.character(track_dt), " "), head, n=1), 
         track_tm = sapply(strsplit(track_tm, " "), tail, n=1), index = row_number())
rm(track.start, track.end)

# reformat time and date
transect = transect %>% mutate(start_dt = sapply(strsplit(as.character(track_date)," "),head,n=1),
                               end_dt = sapply(strsplit(as.character(track_date)," "),head,n=1),
                               start_tm = sapply(strsplit(as.character(start_track_time_gmt)," "),tail,n=1),
                               end_tm = sapply(strsplit(as.character(end_Track_time_gmt)," "),tail,n=1))
camera = camera %>% mutate(camera_dt = sapply(strsplit(as.character(track_date)," "),head,n=1),
                             start_tm = sapply(strsplit(as.character(start_track_time_gmt)," "),tail,n=1),
                             end_tm = sapply(strsplit(as.character(end_Track_time_gmt)," "),tail,n=1)) %>%
  select(-start_track_time_gmt,-end_Track_time_gmt,-track_date)

# names
names(transect) = tolower(names(transect))
names(camera) = tolower(names(camera))
# --------------- #


# --------------- #
# break apart by years
# --------------- #
obs = obs %>% mutate(year = sapply(strsplit(obs_dt,"/"), head, n=1))
track = track %>% mutate(year = sapply(strsplit(track_dt,"/"),head, n=1))
transect = transect %>% mutate(year = sapply(strsplit(as.character(start_dt),"/"), head, n=1))
camera = camera %>% mutate(year = sapply(strsplit(as.character(camera_dt),"/") ,head, n=1))

obs_2012 = obs %>% filter(year == 2012) %>% mutate(dataset_id = 115)
track_2012 = track %>% filter(year == 2012) %>% mutate(dataset_id = 115)
transect_2012 = transect %>% filter(year == 2012) %>% mutate(dataset_id = 115)
camera_2012 = camera %>% filter(year == 2012) %>% mutate(dataset_id = 115)

obs_2013 = obs %>% filter(year == 2013) %>% mutate(dataset_id = 148)
track_2013 = track %>% filter(year == 2013) %>% mutate(dataset_id = 148)
transect_2013 = transect %>% filter(year == 2013) %>% mutate(dataset_id = 148)
camera_2013 =  camera %>% filter(year == 2013) %>% mutate(dataset_id = 148)
  
obs_2014 = obs %>% filter(year == 2014) %>% mutate(dataset_id = 168)
track_2014 = track %>% filter(year == 2014) %>% mutate(dataset_id = 168)
transect_2014 = transect %>% filter(year == 2014) %>% mutate(dataset_id = 168)
camera_2014 = camera %>% filter(year == 2014) %>% mutate(dataset_id = 168)
# --------------- #
  
  
# --------------- #
# export into dir.out as csv
# --------------- #
write.csv(obs_2012, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_obs.csv", sep = "/"), row.names = F)
write.csv(track_2012, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_track.csv", sep = "/"), row.names = F)
write.csv(transect_2012, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_transect.csv", sep = "/"), row.names = F)
write.csv(camera_2012, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_camera.csv", sep = "/"), row.names = F)

write.csv(obs_2013, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2013_obs.csv", sep = "/"), row.names = F)
write.csv(track_2013, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2013_track.csv", sep = "/"), row.names = F)
write.csv(transect_2013, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2013_transect.csv", sep = "/"), row.names = F)
write.csv(camera_2013, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2013_camera.csv", sep = "/"), row.names = F)

write.csv(obs_2014, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2014_obs.csv", sep = "/"), row.names = F)
write.csv(track_2014, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2014_track.csv", sep = "/"), row.names = F)
write.csv(transect_2014, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2014_transect.csv", sep = "/"), row.names = F)
write.csv(camera_2014, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2014_camera.csv", sep = "/"), row.names = F)

write.csv(obs, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_to_2014_obs.csv", sep = "/"), row.names = F)
write.csv(track, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_to_2014_track.csv", sep = "/"), row.names = F)
write.csv(transect, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_to_2014_transect.csv", sep = "/"), row.names = F)
write.csv(camera, file = paste(dir.out, "BRIDOE_HiDef_Aerial_2012_to_2014_camera.csv", sep = "/"), row.names = F)
# --------------- #

