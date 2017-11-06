#-------------- #
# clean BRI ME 2016 data
# prepare it for NWASC
#
# dataset id  = 172
# ------------- #


# ------------- #
# packages
# ------------- #
require(RODBC)
require(dplyr)
require(stringr)
# ------------- #


# ------------- #
# data
# ------------- #
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/Maine_gov/AvianDataDatabase_120616.accdb")
data = sqlFetch(db,"Northwest Atlantic Seabird Catalog Data_MCMI 2016")
odbcClose(db)
# ------------- #


# ------------- #
# data corrections
# ------------- #
names(data) = str_replace_all(string=names(data), pattern=" ", repl="")
data = mutate(data, original_species_tx = SpeciesCode,
              Position = ifelse(Position %in% "Starboard","r","l"),
              Observer = as.character(Observer),
              Observer = ifelse(Observer %in% "Barkalow, Ethan","EB",
                                ifelse(Observer %in% "Doughty, Kate","KD",
                                       ifelse(Observer %in% "Enterline, Claire","CE",
                                              ifelse(Observer %in% "Garvey, Samantha","SG",
                                                     ifelse(Observer %in% "Hill, Jenna","JH","IO"))))))# "Ozmon, Ivy" )
# fix distance
colnames(data)[17]="distance_m"
data$distance_m[data$distance_m %in% 100090]=1000

# fix other names with ()
colnames(data)[33]="GPSSpeed_mps"#GPSSpeed(mps)"
colnames(data)[34]="GPSHeading_degrees"#GPSHeading(degrees)"
colnames(data)[35]="GPSAltitudeAccuracy_m"#GPSAltitudeAccuracy(m)"
colnames(data)[36]="GPSAccuracy_m" #"GPSAccuracy(m)"
colnames(data)[37]="GPSAltitude_m" #"GPSAltitude(m)"
# ------------- #


# ------------- #
# summarize estimated transect info
# ------------- #
t1 = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,TransectComments,TransectName,
                                   GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==1) %>% 
  arrange(ObservationTimestamp) %>% rename(startLon=GPSLongitude,
                                      startLat=GPSLatitude,
                                      firstObservation = ObservationTimestamp)
tn = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,TransectComments,TransectName,
                            GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==n()) %>% 
  arrange(ObservationTimestamp) %>% rename(endLon=GPSLongitude,
                                      endLat=GPSLatitude,
                                      lastObservation = ObservationTimestamp)
# estimated transect start and end locations
est.transects = full_join(t1,dplyr::select(tn,TransectID,endLat,endLon,lastObservation),by="TransectID")
rm(t1,tn)

# only looking at known transect start and stop times
transects = dplyr::select(est.transects,TransectID,TransectStarted,TransectEnded,TransectComments) %>% 
  rename(source_transect_id = TransectID,
         comments_tx=TransectComments) %>% 
  mutate(start_tm = sapply(strsplit(as.character(TransectStarted)," "),tail,1),
         end_tm = sapply(strsplit(as.character(TransectEnded)," "),tail,1), 
         start_dt = sapply(strsplit(as.character(TransectStarted)," "),head,1), 
         end_dt = sapply(strsplit(as.character(TransectEnded)," "),head,1)) %>% 
  dplyr::select(-TransectStarted,-TransectEnded)

# mean variables
speeds = mutate(data, 
                GPSSpeed_mps = replace(GPSSpeed_mps,GPSSpeed_mps<0,NA),
                GPSSpeed_mps = as.numeric(GPSSpeed_mps)) %>% 
  group_by(TransectID) %>% 
  summarise(speed = mean(GPSSpeed_mps, na.rm=TRUE)*1.94384, #mps to knots
            seastate_beaufort_nb = round(mean(BeaufortID, na.rm=TRUE)),
            altitude_nb_m = mean(GPSAltitude_m, na.rm=TRUE),
            observer_tx = first(Observer)) %>%
  mutate(speed = replace(speed,speed %in% "NaN",NA))
speeds$observer_tx[speeds$TransectID %in% c(9,12,14,39,45,
                                            48,50,51,52,53,
                                            54,57,58,63,64,
                                            65,71,72,77,78,
                                            81,82,83)] = "KD/SG"
speeds$observer_tx[speeds$TransectID %in% c(24,41,42)] = "EB/SG"
speeds$observer_tx[speeds$TransectID %in% 29] = "EB/KD"
speeds$observer_tx[speeds$TransectID %in% 35] = "IO/JH"
speeds$observer_tx[speeds$TransectID %in% c(73,74)] = "CE/KD"

transects = left_join(transects,speeds,by=c("source_transect_id" = "TransectID"))
rm(speeds)

## missing end times for these transects
# c(2,6,9,14,19,23,29,33,45,46,48,52,56,59,61,64,65,68,69,71,73,75,77,79,80,82,84,91)

## two observers for these transects
# c(9,12,14,39,45,  
#   48,50,51,52,53,  
#   54,57,58,63,64,  
#   65,71,72,77,78,  
#   81,82,83,24,41, 
#   42,29,35,73,74)
# effort doesnt appear to be duplicated, they appear to be switching off

## also on transects c(18,28,93) observers switch sides of the vessel
# ------------- #


# ------------- #
# define species codes off itis 
# check that common names are the same
# ------------- #
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

data$SpeciesCode = as.character(data$SpeciesCode)
data = left_join(data, dplyr::select(spplist,spp_cd,ITIS_id), by=c("SpeciesITISNumber"="ITIS_id")) 

#sort(unique(data$SpeciesCode[is.na(data$SpeciesITISNumber)]))
#"CRTE" #Common/Roseate Tern -> UCRT
#"GBHG" #Great Black-backed/Herring Gull
#"SHOR" #Unidentified shorebird
#"UNDU" #Unidentified Duck
#"UNGU" #Unidentified Gull
#"UNLG" #Unidentified Large Gull
#"UNSG" #Unidentified small gull
#"UNSP" #Unidentified Storm-petrel
# fix those where there are NAs in the ITIS 
data$spp_cd[data$SpeciesCode %in% c("GBHG", "SHOR", "UNDU", "UNGU", "UNLG", "UNSG", "UNSP")] = data$SpeciesCode[data$SpeciesCode %in% c("GBHG", "SHOR", "UNDU", "UNGU", "UNLG", "UNSG", "UNSP")]
data$spp_cd[data$SpeciesCode %in% "CRTE"]="UCRT"

# check the common names of those that changed to make sure 
x = as.data.frame(cbind(as.vector(data$SpeciesCode[data$SpeciesCode != data$spp_cd]),
                        as.vector(data$SpeciesCommonName[data$SpeciesCode != data$spp_cd]),
                        as.vector(data$spp_cd[data$SpeciesCode != data$spp_cd])))
#fix those with unidentified classifications where ITIS fills in more than one record
data$spp_cd[data$SpeciesCode %in% "UNTE"] = "UNTE"
data$spp_cd[data$SpeciesCode %in% "UNST"] = "UNST"
data$spp_cd[data$SpeciesCode %in% "UNJA"] = "UNJA"
data$spp_cd[data$SpeciesCode %in% "UNPE"] = "UNPE"
data$spp_cd[data$SpeciesCode %in% "UNSH"] = "UNSH"
rm(x,spplist)
# ------------- #


# ------------- #
# define behavior,age ids
# ------------- #
#Behavior
data = mutate(data, behavior_id = as.character(Behavior),
              behavior_id = replace(behavior_id, behavior_id %in% "Carrying fish", 16),
              behavior_id = replace(behavior_id, behavior_id %in% "Dead", 6),
              behavior_id = replace(behavior_id, behavior_id %in% "Diving", 7),
              behavior_id = replace(behavior_id, behavior_id %in% "Feeding", 9),
              behavior_id = replace(behavior_id, behavior_id %in% "Flying", 13),
              behavior_id = replace(behavior_id, behavior_id %in% "Following", 14),
              behavior_id = replace(behavior_id, behavior_id %in% "Kleptoparasitizing", 24),
              behavior_id = replace(behavior_id, behavior_id %in% "Milling", 21),
              behavior_id = replace(behavior_id, behavior_id %in% c("Taking Off","Pattering"), 42),
              behavior_id = replace(behavior_id, behavior_id %in% "Plunge Diving", 8),
              behavior_id = replace(behavior_id, behavior_id %in% "Sitting", 35),
              behavior_id = replace(behavior_id, is.na(behavior_id),44))            

#Age
data = mutate(data, age_id = as.character(Age),
              age_id = replace(age_id, age_id %in% "Adult",1),
              age_id = replace(age_id, age_id %in% "Immature",6),
              age_id = replace(age_id, age_id %in% "Juvenile",2),
              age_id = replace(age_id, age_id %in% "subadult",7),
              age_id = replace(age_id, age_id %in% c("Third year","Fifth year","First cycle","First year","Fourth year"),4),
              age_id = replace(age_id, is.na(age_id),5))  

#Sex
data = mutate(data, sex_id = as.character(Sex),
              sex_id = replace(sex_id, sex_id %in% "Female",1), 
              sex_id = replace(sex_id, sex_id %in% "Male",2),
              sex_id = replace(sex_id, sex_id %in% "Unknown",5),
              sex_id = replace(sex_id, is.na(sex_id),5)) 
# ------------- #


# ------------- #
# rename
# ------------- #
data = data %>% 
  mutate(obs_dt=sapply(strsplit(as.character(ObservationTimestamp)," "),head,1),
         obs_tm=sapply(strsplit(as.character(ObservationTimestamp)," "),tail,1),
         original_species_tx = paste(SpeciesCode,SpeciesCommonName,SpeciesITISNumber,sep=" ; "),
         distance_to_animal_tx = paste(distance_m,"meter(s)",sep=" "),
         observer_comments = paste(ObservationComment,BehaviorDescription,sep=" ; "),
         flight_height_tx = paste(GPSAltitude_m,"meter(s)",sep=" ")) %>% 
  rename(source_obs_id=ObservationID,
         source_transect_id=TransectID,
         obs_lat = GPSLatitude,
         obs_lon = GPSLongitude,
         obs_count_intrans_nb = Count,
         observer_tx = Observer,
         observer_position = Position,
         plumage_tx = Plumage,
         heading_tx = GPSHeading_degrees,
         angle_from_observer_nb = Degree,
         associations_tx = LinkedwithObservationID,
         visibility_tx = Visibility,
         seastate_beaufort_nb = BeaufortID,
         cloud_cover_tx = Weather,
         original_age_tx = Age,
         original_behavior_tx = Behavior,
         original_sex_tx = Sex,
         glare_tx = Glare,
         travel_direction_tx = Direction) %>%
  dplyr::select(-TransectStarted,-TransectEnded,-TransectComments,
                -ObservationType,-SpeciesCommonName,
                -SpeciesITISNumber,-BehaviorDescription,
                -distance_m,-ObservationComment,-GPSTimestamp,
                -TransectName,-SpeciesCode,
                -ID,-TransectName,-ObservationTimestamp,
                -GPSSpeed_mps,-GPSAltitudeAccuracy_m,
                -GPSAccuracy_m,-GPSAltitude_m)

# errors from transect notes
data$obs_dt[data$source_transect_id %in% 38]="2016-07-07"
transects$start_dt[transects$source_transect_id %in% 38]="2016-07-07"
transects$end_dt[transects$source_transect_id %in% 38]="2016-07-07"
# ------------- #


# ------------- #
# export
# ------------- #
write.csv(data,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Maine_gov/data172.csv",row.names=FALSE,na="NA")
write.csv(transects,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/Maine_gov/transects172.csv",row.names=FALSE,na="NA")
# ------------- #
