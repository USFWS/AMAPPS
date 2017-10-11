#-------------- #
# clean ME data
# prepare it for NWASC
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
t1 = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,
                                   GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==1) %>% 
  arrange(ObservationTimestamp) %>% rename(startLon=GPSLongitude,
                                      startLat=GPSLatitude,
                                      firstObservation = ObservationTimestamp)
tn = data %>% dplyr::select(TransectID,TransectStarted,TransectEnded,
                            GPSLongitude,GPSLatitude,ObservationTimestamp) %>% 
  group_by(TransectID) %>% filter(row_number()==n()) %>% 
  arrange(ObservationTimestamp) %>% rename(endLon=GPSLongitude,
                                      endLat=GPSLatitude,
                                      lastObservation = ObservationTimestamp)
transects = full_join(t1,dplyr::select(tn,TransectID,endLat,endLon,lastObservation),by="TransectID")
rm(t1,tn)

# missing end times for these transects
# c(2,6,9,14,19,23,29,33,45,46,48,52,56,59,61,64,65,68,69,71,73,75,77,79,80,82,84,91)
# ------------- #

# ------------- #
# export
# ------------- #
# ------------- #
