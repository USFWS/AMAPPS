# --------------------- #
# Quality control StellwagenBank data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(dplyr)
require(measurements)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "Stellwagen"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//IFW9mbm-fs1/SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
# -------------------------------- #


#---------------------#
# load data 
#---------------------#
# observations
db <- odbcConnectAccess2007(file.path(dir.in, "Seabird_Mike_v.45_2017_04_21st.accdb"))
obs <- sqlFetch(db, "Bird_Sightings")
lu_age <- sqlFetch(db, "LUT_Age")
lu_assoc <- sqlFetch(db, "LUT_Association")
lu_behavior <- sqlFetch(db, "LUT_Behaviors")
lu_plumage <- sqlFetch(db, "LUT_Plumage")
lu_weather <- sqlFetch(db, "LUT_Weather")
lu_precip <- sqlFetch(db, "LUT_Precipitation")
lu_glare <- sqlFetch(db, "LUT_Glare")
lu_spp <- sqlFetch(db, "LUT_Seabird_Species")
odbcClose(db)

# gps
db = odbcConnectExcel2007(paste(dir.in,"auk_gps_standardized_2012_thru_Aug_05_2015 (2).xlsx",sep="/")) # open a connection to the Excel file
a = sqlFetch(db, "Mike_Auk_GPS")
odbcClose(db)

a = a %>% mutate(time = sapply(strsplit(as.character(Time_LCL_BOSTON)," "),tail,1)) %>%
  dplyr::select(-Source,-Time_LCL_BOSTON) %>% 
  rename(date = Date_LCL_BOSTON,date_time = Timestamp_LCL_BOSTON) 

d = read.table(paste(dir.in,"2015_10_27th_Auk_Standardized_Garmin_Unit2.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
e = read.table(paste(dir.in,"2015_09_28th_Auk_GarminUnit2.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
f = read.table(paste(dir.in,"2015_12_26th_Auk_Unit1.txt",sep="/"), sep = "\t", header=FALSE, skip=19)
b = bind_rows(d,e,f)

names(b)= c("point_type","Position","Time","Altitude","Depth",
            "Temperature","Leg_length","Leg_time","Speed","Course")
b = b %>% mutate(Position = as.character(Position),
                 lat = sapply(strsplit(Position, "W"),head,1),
                 lat = sapply(strsplit(lat, "N"),tail,1),
                 long = sapply(strsplit(Position, "W"),tail,1),
                 Latitude = as.numeric(measurements::conv_unit(lat, from = 'deg_dec_min', to = 'dec_deg')),
                 Longitude = measurements::conv_unit(long, from = 'deg_dec_min', to = 'dec_deg'),
                 Longitude = as.numeric(Longitude)*-1,
                 date_time = as.POSIXct(Time,format="%m/%d/%Y %H:%M:%S %p "),
                 date = as.POSIXct(sapply(strsplit(as.character(date_time)," "),head,1)),
                 time = sapply(strsplit(as.character(date_time)," "),tail,1),
                 heading = sapply(strsplit(Course,"°"),head,1)) %>% 
  dplyr::select(-lat,-long,-Position,-Time,-Course)

track = bind_rows(a,b) %>% arrange(date_time)
rm(a,b,d,e,f)
#---------------------# 

#---------------------# 
# fix codes
#---------------------# 
# replace codes
obs = left_join(obs, lu_age, by=c("Age"="ID")) %>% 
  left_join(., select(lu_behavior, Behavior, Behavior_Code), by=c("Behavior"="Behavior_Code")) %>% 
  left_join(., select(lu_plumage, ID, Plumage), by=c("Plumage"="ID")) %>% 
  left_join(., mutate(lu_assoc,Ass_Code=as.factor(Ass_Code)), by=c("Association"="Ass_Code")) %>% 
  left_join(., select(lu_weather, -Order) %>% mutate(WX_Code=as.factor(WX_Code)), by=c("Weather"="WX_Code")) %>% 
  left_join(., lu_precip, by=c("Precipitation"="Precip_Code")) %>%  
  left_join(., lu_glare, by=c("Glare"="Glare_Code")) %>% 
  rename(animal_age_tx=Age.y, behavior_tx = Behavior.y, plumage_tx=Plumage.y,
         Association_tx=Association.y, glare_tx=Glare.y, weather_tx=Weather.y) %>%
  mutate(cloud_cover_tx = weather_tx,
         weather_tx = paste(weather_tx, Precipitation.y, sep = "; ")) %>%
  dplyr::select(-Behavior, -Precipitation, -Precipitation.y, -Glare, -Age) 

rm(lu_age, lu_behavior, lu_plumage, lu_assoc, lu_weather, lu_precip, lu_glare)

# fix time
obs = rename(obs, gps_time = Sighting_Time) %>% 
  mutate(gps_time = sapply(strsplit(as.character(gps_time), " "), tail, 1))

# merge comments
#obs = obs %>% mutate(comments = paste(Comments, WXNotes, Association, sep = "; ")) %>% 
#  select(-Comments, -WXNotes) %>% 
#  mutate(comments = ifelse(comments %in% c("NA;NA;NA"),NA,comments))

# add row for when an associations

#---------------------#  


#---------------------#
# fix species
#---------------------#
db <- odbcConnectAccess2007("//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist$common_name = tolower(spplist$common_name)

# check if species codes are different
lu_spp$Common_Name = tolower(lu_spp$Common_Name)
lu_spp$Common_Name = as.character(lu_spp$Common_Name)
lu_spp$Species = as.character(lu_spp$Species)
test = left_join(lu_spp, select(spplist,spp_cd,common_name), by=c("Code"="spp_cd")) 
test = test[test$Common_Name != test$common_name,]
rm(test, lu_spp) #after inspected 

# fix codes
obs$original_species_tx = obs$Species

tmp <- !obs$Species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$Species[tmp]))
rm(spplist)

obs = obs %>% rename(spp = Species) %>% mutate(spp = as.character(spp))
obs$spp[obs$spp %in% "GRSP"] = "UNGR"  #unid grebe
obs$spp[obs$spp %in% "POSP"] = "UNPO" #unid porp
obs$spp[obs$spp %in% "SWSP"] = "SWAL" #unid swallow
obs$spp[obs$spp %in% "UNSH"] = "SHAR" #unid shark
obs$spp[obs$spp %in% "ABFT"] = "BFTU" # atlantic blue fin tuna 
obs$spp[obs$spp %in% "AGWT"] = "GWTE" # american green-winged teal 
obs$spp[obs$spp %in% "ALSP"] = "UNAL" # unidentified alcid
obs$spp[obs$spp %in% "BUSP"] = "UBUT" # butterfly species  
obs$spp[obs$spp %in% "COSP"] = "UNCO" # unidentified cormorant species  
obs$spp[obs$spp %in% "DUSP"] = "UNDU" # unidentified sea duck
obs$spp[obs$spp %in% "GUSP"] = "UNGU" # unidentified gull  
obs$spp[obs$spp %in% "JASP"] = "UNJA" # unidentified jaeger  
obs$spp[obs$spp %in% "LAND"] = "UNBI" # any unidentified terrestrial bird  
obs$spp[obs$spp %in% "LOSP"] = "UNLO" # loon species  
obs$spp[obs$spp %in% "NAWH"] = "RIWH" # north atlantic right whale  
obs$spp[obs$spp %in% "OTHER"] = "UNKN"  
obs$spp[obs$spp %in% "PHSP"] = "UNPH" #unidentified phalarope  
obs$spp[obs$spp %in% "SCSP"] = "UNSC" #unidentified scoter  
obs$spp[obs$spp %in% "SHSP"] = "UNSH" #unidentified shearwater  
obs$spp[obs$spp %in% "SONG"] = "UNPA" #unidentified songbird species  
obs$spp[obs$spp %in% "TESP"] = "UNTE" #unidentified tern 
obs$spp[obs$spp %in% "TUSP"] = "TURT" #unidentified turtle  
obs$spp[obs$spp %in% "VESS"] = "BOAT" #vessel
obs$spp[obs$spp %in% "WASP"] = "UNWA" #unidentified warbler  
obs$spp[obs$spp %in% "WHSP"] = "UNWH" #unidentified whale 

# marine debris (NEED TO PULL OUT BALLOONS FROM COMMENTS)
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("mylar ballon","Mylar ballon","Mylar ballon (blue)",
                                                  "Mylar ballon around 0.5 km","Mylar ballons 50 yds apart",
                                                  "mylar balloon","Mylar balloon","Mylar Balloon",
                                                  "Mylar balloon debris","Mylar balloon picked up",
                                                  "Mylar balloon, port side","Mylar trash huge",
                                                  "Balloon-mylar","purple mylar balloon",
                                                  "Balloon mylar Happy B-day")] = "MYBA"
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("off, balloon","orange balloon- green balloon picked up off track",
                                                  "green ballon","green balloon","Green balloon","deflated balloon",
                                                  "blue balloon","Ballon +picked up","balloon","Balloon",
                                                  "balloon (caught it)","balloon (diff. than above)",
                                                  "balloon 2nd picked up off effort","balloon mylar",
                                                  "Balloon mylar","Balloon mylar Happy B-day ",
                                                  "Balloon or jug","Balloon under water",
                                                  "balloon w/ plastic bag?","Balloons",
                                                  "Balloons 3x w/ bait ball","balloons, several",
                                                  "3 balloons, picked up","purple balloon",
                                                  "yellow balloon and ribbon floating on the water",
                                                  "picked up balloon","Pink balloon","nylon balloon",
                                                  "Popped balloon","white balloon")]="BALN"
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("Latex ballon","latex balloon, did not recover",
                                                  "red latex balloon","White latex balloon, ribbon attached")]="LABA" 
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("plastic","Plastic","plastic bag","Plastic bag","Plastic Bag",
                                                  "plastic bottle","Plastic bottle","plastic bottle, dead herring gull",
                                                  "Plastic bottle, port side","Plastic bottles","plastic cup",
                                                  "plastic fruit cup","plastic h2o bottle","Plastic jug",
                                                  "Plastic jug; slowing for whales","plastic lion","Plastic soda bottle",
                                                  "plastic trash bag","Plastic tub","plastic water bottle",
                                                  "poland spring water bottle","Water bottle",
                                                  "Unidentified plastic","Shiny plastic bottle",
                                                  "water bottle, plastic cont.","small plastic package",
                                                  "Bleach bottle","? Small white square, maybe plastic",
                                                  "white plastic bag","white hard plastic",
                                                  "White antifreeze jug","Milk jug","Jug floating",
                                                  "Gallon Jug","flat white plastic (3' x 5')",
                                                  "Large plastic juice bottle","marine debris- bleach bottle",
                                                  "white plastic")]="PLAS"     
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("seaweed")]="MACR"
obs$spp[obs$spp %in% "MADE" & obs$Comments %in% c("Boat pickup- Loose Buoy","broken buoy")]="BUOY"
obs$spp[obs$spp %in% "MADE"]="FLJE"
obs$spp[obs$spp %in% "FLJE" & obs$Comments %in% c("Rahul- recorder, John- observer")]="COMMENT"

#fix observers
obs$Observer = as.character(obs$Observer)
obs$Observer[is.na(obs$Observer)] = as.character(obs$Recorder[is.na(obs$Observer)])
obs$Observer[obs$Observer %in% "No Record"] = as.character(obs$Recorder[obs$Observer %in% "No Record"])

obs$Observer[obs$Observer %in% "Amy O'Neil"] = "AON"                      
obs$Observer[obs$Observer %in% "Anne-Marie Runfola"]="AMR"              
obs$Observer[obs$Observer %in% "Anne Sterling"]="AS" 
obs$Observer[obs$Observer %in% "Beth Slikas"]="BS"
obs$Observer[obs$Observer %in% "Ben Lagasse"]="BL"                     
obs$Observer[obs$Observer %in% "Blaine"]="Bl"                          
obs$Observer[obs$Observer %in% "Blair Nikula"]="BN"                   
obs$Observer[obs$Observer %in% "Blair Nikula, David Clapp"]="BN/DC"       
obs$Observer[obs$Observer %in% "Bob"]="Bo"                             
obs$Observer[obs$Observer %in% "CBC- Various"]="CBC"        
obs$Observer[obs$Observer %in% c("Caitlin Jensen","Caitlyn Jensen")]="CJ"
obs$Observer[obs$Observer %in% "Charlie Cooper"]="CC"                  
obs$Observer[obs$Observer %in% "Derek Garvey"]="DG"                    
obs$Observer[obs$Observer %in% "Derek Garvey / Stefanie Paventy"]="DG/SP"
obs$Observer[obs$Observer %in% "Ellen Keane"]="EK"                     
obs$Observer[obs$Observer %in% "Ellison Orcutt"]="EO"                  
obs$Observer[obs$Observer %in% "Glenn d'Entremont"]="GdE" 
obs$Observer[obs$Observer %in% "George Graham"]="GG"
obs$Observer[obs$Observer %in% "Jane Sender"]="JS"   
obs$Observer[obs$Observer %in% "Jenny"]="Je"
obs$Observer[obs$Observer %in% "Jess Bethoney"]="JeB"                   
obs$Observer[obs$Observer %in% "Jessica Rempel"]="JR"                 
obs$Observer[obs$Observer %in% "Jim McCoy"]="JM"                       
obs$Observer[obs$Observer %in% "Jim Sweeney"]="JSw"                     
obs$Observer[obs$Observer %in% "Jim Sweeny, Naeem"]="JSw/NY"              
obs$Observer[obs$Observer %in% "John Galluzzo"]="JG"                   
obs$Observer[obs$Observer %in% "Justin Baldwin"]="JBa"                  
obs$Observer[obs$Observer %in% c("Justin Leclaire","Justin LeClaire","Justin LeClere")]="JLC"                 
obs$Observer[obs$Observer %in% "Kathy Wall"]="KW"                     
obs$Observer[obs$Observer %in% "Kevin Powers"]="KP"                    
obs$Observer[obs$Observer %in% "Liam Waters"]="LW"                     
obs$Observer[obs$Observer %in% "Liz Dancer"]="LD"                     
obs$Observer[obs$Observer %in% "Marie Martin"]="MMar"                    
obs$Observer[obs$Observer %in% "Mark Faherty"]="MFa"                    
obs$Observer[obs$Observer %in% "Matt Malin"]="MMal"                     
obs$Observer[obs$Observer %in% "Matt Malin, Jessica Rempel"]="MMal/JR"      
obs$Observer[obs$Observer %in% "Melinda Forist"]="MFo"                  
obs$Observer[obs$Observer %in% "Naeem Yusuff"]="NY"                   
obs$Observer[obs$Observer %in% "Peter"]="P"                           
obs$Observer[obs$Observer %in% "Peter Briggs"]="PB"                   
obs$Observer[obs$Observer %in% "Peter Briggs / Derek Garvey"]="PB/DG"     
obs$Observer[obs$Observer %in% "Peter Briggs / Stefanie Paventy"]="PB/SP"
obs$Observer[obs$Observer %in% "Peter Briggs, Trudy Tynan"]="PB/TT"      
obs$Observer[obs$Observer %in% "Peter Crosson"]="PC"                   
obs$Observer[obs$Observer %in% "Peter Flood"]="PF"                     
obs$Observer[obs$Observer %in% "Peter Flood, Brian Harris"]="PF/BH"      
obs$Observer[obs$Observer %in% "Ralph Bowman, Wayne"]="RB/WP"             
obs$Observer[obs$Observer %in% "Sarah Guitart"]="SG"                   
obs$Observer[obs$Observer %in% c("Shan Morrisey","Shan Morrissey")]="SM"                 
obs$Observer[obs$Observer %in% "Stefanie Paventy"]="SP"                
obs$Observer[obs$Observer %in% "Stefanie Paventy/Jane Sender"]="SP/JSe"    
obs$Observer[obs$Observer %in% "Tim Factor"]="TF"                     
obs$Observer[obs$Observer %in% "Tim Factor/Jane Sender"]="TF/JSe"          
obs$Observer[obs$Observer %in% c("Tom Robben","Tom Robbens")]="TR"                    
obs$Observer[obs$Observer %in% "Trudy Tynan"]="TT"                    
obs$Observer[obs$Observer %in% "Wayne Peterson"]="WP"                  
obs$Observer[obs$Observer %in% "Whit Manter"]="WM"           

# add boats
obs$Association_tx[obs$Comments %in% c("fish vessel", "Fish vessel",'Fisherman "Nantucket Wild"', 
                                       'fishing "Wicked Pissah"',"fishing and recreational", "fishing boat",
                                       "Fishing boat","Fishing Boat","Fishing Boat - Name Unknown", 
                                       'Fishing boat "Alosa"','fishing boat, "Bad Influence"',
                                       "fishing boat, wp/kp", "Fishing Boat; small; Datikiman", 
                                       "Fishing boat; small; Odysea", "fishing boat?", 
                                       "Fishing on Woodend, 1) Minerva, 2) Fools Gold, 3) Cee Jay",
                                       "fishing or lobster", 'Fishing trawler off Race Point "Sea Hunter"',
                                       "Fishing vess", "fishing vess sitting 1228906", "fishing vessel", 
                                       "Fishing vessel","Fishing Vessel","fishing vessel- Bounty Hunter Gloucester",
                                       "fishing vessel- lobster boat",'fishing vessel "Michael+Kristen"', 
                                       "Fishing vessel NOTE: GPS track is recording the remainder of this survey",
                                       "Fishing Vessel Poseidon", 'Fishing vessel? Frame on stern "Perfect Cs"') &
                     is.na(obs$Association_tx)]= "Fishing vessel"

to.add = obs %>% filter(Comments %in% c("fish vessel", "Fish vessel",'Fisherman "Nantucket Wild"',  
                                        'fishing "Wicked Pissah"',"fishing and recreational", "fishing boat", 
                                        "Fishing boat","Fishing Boat","Fishing Boat - Name Unknown", 
                                        'Fishing boat "Alosa"','fishing boat, "Bad Influence"',
                                        "fishing boat, wp/kp", "Fishing Boat; small; Datikiman", 
                                        "Fishing boat; small; Odysea", "fishing boat?", 
                                        "Fishing on Woodend, 1) Minerva, 2) Fools Gold, 3) Cee Jay",
                                        "fishing or lobster", 'Fishing trawler off Race Point "Sea Hunter"',
                                        "Fishing vess", "fishing vess sitting 1228906", "fishing vessel", 
                                        "Fishing vessel","Fishing Vessel","fishing vessel- Bounty Hunter Gloucester",
                                        "fishing vessel- lobster boat",'fishing vessel "Michael+Kristen"', 
                                        "Fishing vessel NOTE: GPS track is recording the remainder of this survey",
                                        "Fishing Vessel Poseidon", 'Fishing vessel? Frame on stern "Perfect Cs"'),
                        !obs$spp %in% c("BOAT","BOFI")) %>% 
  mutate(spp = "BOFI", N_Individuals = 1, ID=ID+0.1)
obs = rbind(obs, to.add) %>% arrange(ID)
rm(to.add)
                        
#---------------------#











