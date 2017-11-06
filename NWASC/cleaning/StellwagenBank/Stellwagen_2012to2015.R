# --------------------- #
# Quality control StellwagenBank data
# prepare it forimport into the NWASC
# --------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(dplyr)
require(geosphere)
require(measurements)
# -------------------------------- #


# -------------------------------- #
# functions
# -------------------------------- #
su <- function(x) {sort(unique(x))} # time saver when exploring the data
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "Stellwagen"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
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
library(RODBC) 
db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)
spplist$common_name = tolower(spplist$common_name)

# check if species codes are different
lu_spp$Common_Name = tolower(lu_spp$Common_Name)
lu_spp$Common_Name = as.character(lu_spp$Common_Name)
lu_spp$Species = as.character(lu_spp$Species)
test = left_join(lu_spp, dplyr::select(spplist,spp_cd,common_name), by=c("Code"="spp_cd")) 
test = test[test$Common_Name != test$common_name,]
rm(test, lu_spp) #after inspected 

# species codes that didn't agree but were the same code
#GRSP             unidentified grebe != grasshopper sparrow
#UNSW           unidentified swallow != unidentified small whale
#POSP          unidentified porpoise != polynesian storm-petrel
#SWSP   unidenfified swallow species != swamp sparrow
#UNSH             unidentified shark != unidentified shearwater

# fix codes
obs$original_species_tx = obs$Species

tmp <- !obs$Species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
su(obs$Species[tmp])
rm(spplist)

obs = obs %>% rename(spp = Species) %>% mutate(spp = as.character(spp))

obs$spp[obs$spp %in% "GRSP"] = "UNGR"  #unid grebe
obs$spp[obs$spp %in% "POSP"] = "UNPO" #unid porp
obs$spp[obs$spp %in% "UNSH"] = "SHAR" #unid shark

obs$spp[obs$spp %in% "SWSP"] = "SWAL" #unid swallow
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
#obs$spp[obs$spp %in% "FLJE" & obs$Comments %in% c("Rahul- recorder, John- observer")]="COMMENT"

# is.na spp is a comment
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Trash, mylar balloon","Mylar Ballons",                                                                                                                                     
                                             "mylar balloon",                                                                                                                                     
                                             "Mylar Balloon",                                                                                                                                     
                                             "Mylar balloon pick up")]="BALN" 
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Trash - blue balloon")]="MYBA"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("trash, plastic bag gbge","large plastic ball, huge ball")]="PLAS"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Trawler","Trawler Michel Jean II",
                                             "Draggers in area (2)")]="BOTD"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Two masted schooner; Havey Gamer; Port Ilseboro, Maine")]="BOSA"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Species:  large, pale butterfly or moth")]="UBUT"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("School of bait fish")]="BAIT"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("PORPOISE SPECIES")]="UNPO"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Lobster boat")]="BOLO"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("JELLYFISH ABOUT 18\" ACROSS")]="UNJE"
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Fishing Boat; small; Datikiman",
                                             "Fishing boat; small; Odysea",
                                             "fishing vessel")]="BOFI"

# off effort = ENDCNT, 
# on effort = BEGCNT
obs$spp[is.na(obs$spp) & obs$Comments %in% c("On effort","back on effort",
                                             "on effort","on Effort Starboard",
                                             "0n Effort Portside","ON","Begin effort",
                                             "on Effort Starboad","On Effort",
                                             "on Effort Portside"," ON EFFORT",
                                             "ON EFFORT- heading back to plymouth",
                                             "ON EFFORT- returning to Plymouth",
                                             "Auk 2011 Pilot, on effort",
                                             "Auk 2011 Pilot, on transect",
                                             "balloon pickup, on effort",
                                             "BUMP Cruise on effort",
                                             "BUMP Cruise, on effort",
                                             "Departure conditions; on effort",
                                             "Departure conditions; On Effort",
                                             "Edited number category, ON EFFORT",
                                             "on effort; wind picks up",
                                             "ON Effort; Starbord",
                                             "ON EFFORT; STARBOARD SIDE",
                                             "On Effort; Portside",
                                             "on effort; portside",
                                             "On Effort. Departure conditions: cloudy",
                                             "on effort, observer:Jane Sender, recorder:Peter Briggs",
                                             "on effort, observer Wayne Peterson, recorder Peter Briggs",
                                             "on effort, observer-Stefani Paventy, recorder-Peter Briggs",
                                             "on effort, Jane",
                                             "on effort time, SP recording, Stefanie Paventy",
                                             "On effort time",
                                             "On Effort Starbordside",
                                             "ON EFFORT 19-21 KNOTS",
                                             "ON EFFORT",
                                             "ON Effort","On",
                                             "ON; STILL ON PORT SIDE",
                                             "on effort; wind picks up ", 
                                             "on Effort Starbord", 
                                             "on Effort","non-standardized, on effort",
                                             "Initial On Effort. Last navigation buoy off Gurnet Point.",
                                             "Departure conditions; On Effort time; Very bright! But not as much glare this angle")]="BEGCNT"
        
obs$spp[is.na(obs$spp) & obs$Comments %in% c("Off effort","off effort","DONE","0ff effort",
                                             "off effort, below 6 knots","stopped again",
                                             "Off Effort","end","End Transect","OFF",
                                             "OFF EFFORT","off effort Slowed for whale",
                                             "Off Effort; Ob:Amy O'Neill; Rec:Liam Waters",
                                             "OFF EFFORT STARBOARD",
                                             "OFF EFFORT- slow to observe humpback whale",
                                             "OFF EFFORT- slow for minke whale",
                                             "OFF EFFORT- slow to observe Humpback whales",
                                             "OFF EFFORT- slow to observe Humpback whales",
                                             "OFF EFFORT- removing balloon from the water",
                                             "OFF EFFORT- back in harbor","End of Trip, Return to Dock",
                                             "LEAVE DOCK OFF EFFORT, very hot bright sun",
                                             "OFF EFFORT AND END OBSERVATIONS",
                                             "END OF TRANSECT, OFF EFFORT","Off",
                                             "End of transects, heading home at 16 knots",
                                             "Auk 2011 Pilot, END EFFORT",
                                             "Auk 2011 Pilot, End Transect",
                                             "balloon pick up, off effort",
                                             "BUMP Cruise (still off effort - they had an incorrect waypoint)" ,
                                             "BUMP Cruise off effort",
                                             "BUMP Cruise off effort - lunch break",
                                             "BUMP Cruise, Done",
                                             "BUMP Cruise, off effort",
                                             "BUMP Cruise, off effort ",
                                             "BUMP Cruise, stopped for plankton net tow",
                                             "DOCKED","done","Done",
                                             "Done. (AMR note: Had to stop count in the midst of the last track near P-Town due to rough conditions)",
                                             "Edited number category, OFF EFFORT",
                                             "end effort","End Effort","End of effort",
                                             "End of recording","End of recording.",
                                             "End of transect","END OF TRANSECT, OFF EFFORT",
                                             "End of transects, heading home at 16 knots",
                                             "STOPPED RECORDING (crossed bank 20-21 knots, whales on back side of Cape)",
                                             "STOP","stopped",
                                             "off, Jane record, Matt obs.",
                                             "off transect",
                                             "OFF EFFORT; weather update",
                                             "Off Effort; Starbord",
                                             "Off Effort; Rec: Heather Jenkins",
                                             "off effort; observer Flood, recorder Briggs",
                                             'Off Effort, within 1 minute of going \"Off Effort\", 3 Bank Swallows off Gurnet Point',
                                             "off effort, weather: 8, 0 precip, 100% cloud cover, wind:1" ,
                                             "off effort, no speed",
                                             "off effort, going to look at birds around fishing vessel" ,
                                             "off effort, Done","off effort, done",
                                             "off effort, deer island",
                                             "Off Effort, balloon pick-up (2)",                                                                                                                   
                                             "off effort, balloon retrieval",
                                             "off effort, balloon",
                                             "off effort, 2 balloon",
                                             "OFF EFFORT û Multiple breaching and basking humpback whales (recorder comment).  Naturalist on boat indicated 11 different humpbacks were spotted.",
                                             "Off effort to 10:27",
                                             "OFF EFFORT TIME",
                                             "Off Effort Time",
                                             "off effort time","Off effort time",
                                             "off effort Starbord","off effort for balloon",
                                             "OFF EFFORT End of Trip",
                                             "off effort  Done","Off Effort - Fog",
                                             "off effort - Done. Return trip, into wind, couldn't continue to observe- too windy",
                                             "off effort - done","Off effort ","Off Effort-Fog",
                                             "OFF EFFORT- slow to observe Humpback whales ",
                                             "OFF EFFORT- slow to look @ minke & mother + calf humpback (same individuals observed earlier)",
                                             "OFF EFFORT- SLOW FOR WHALES",
                                             "OFF EFFORT- slow for whales","Off Effort- Fog",
                                             "OFF EFFORT- BACK TO HARBOR","off Effort","OFF ",
                                             "In bathroom, ceased recording",
                                             "heading back to port; off transect",
                                             "HEADING TO DOCK AT 19-20 KNOTS",
                                             "get balloon, off effort")]="ENDCNT"

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
obs$Observer[obs$Observer %in% "Jess Bethoney"]="JBe"                   
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
                                       "Fishing Vessel Poseidon", 'Fishing vessel? Frame on stern "Perfect Cs"')]= "Fishing vessel"

to.add = obs %>% filter(Association_tx %in% c("Fishing vessel"),
                        !obs$spp %in% c("BOAT","BOFI")) %>% 
  mutate(spp = "BOFI", 
         N_Individuals = 1, 
         ID=ID+0.1,
         Association_tx = original_species_tx, Association_tx = as.character(Association_tx),
         Association_tx = replace(Association_tx,Association_tx=="GUSP","UNGU"))
obs = rbind(obs, to.add) %>% arrange(ID)
rm(to.add)

# add balloons
to.add = obs %>% filter(Comments %in% c("Off Effort, balloon pick-up (2)",
                                        "off effort, balloon retrieval",
                                        "off effort, balloon",
                                        "off effort, 2 balloon",
                                        "off effort for balloon",
                                        "get balloon, off effort") & spp %in% "ENDCNT") %>% 
  mutate(spp = "BALN", ID=ID+0.1,N_Individuals = 1,
         N_Individuals = replace(N_Individuals,
                                 Comments %in% c("Off Effort, balloon pick-up (2)","off effort, 2 balloon"),2))
obs = rbind(obs, to.add) %>% arrange(ID)
rm(to.add)

# effort 
# on == 1
# off == 2 OR 0?
obs = obs %>% mutate(offline = ifelse(Effort %in% 1,0,1)) 
#---------------------#


#---------------------#
# divide by protocol
#---------------------#
obs = rename(obs, date = Sighting_Date, time=gps_time, Latitude=LAT, Longitude=LON) %>% rowwise %>% 
  mutate(date_time = as.POSIXct(paste(date, time, sep=" ")))

obs_standard = obs[obs$Protocol %in% "Standardized",]
obs_other = obs[obs$Protocol %in% c("Other","Other-Put in comments"),]                 
obs_ss = obs[obs$Protocol %in% "Second Side",]                
obs_ww = obs[obs$Protocol %in% "Whale Watch",]
rm(obs)

track_standard = track[track$date %in% obs_standard$date,]
track_ss = track[track$date %in% obs_ss$date,]        
#track_ww = track[track$date %in% obs_ww$date,]
#track_other = track[track$date %in% obs_other$date,] 
rm(track)
#---------------------#


#---------------------#
# split by survey and QA/QC start/stops
#---------------------#
# transects
trans = as.data.frame(matrix(nrow=16, ncol=3, data=NA))
names(trans)=c("id","Latitude","Longitude")
trans = trans %>% mutate(id = c(1:16),
                         Latitude = c(42.442064,42.442114,42.400128,42.400195,42.358987,
                                     42.359006,42.316885,42.316856,42.275407,42.275291,42.233551,
                                     42.233512,42.191654,42.191532,42.15019,42.150184),
                         Longitude = c(-70.479151,-70.398143,-70.467651,-70.336545,-70.351623,
                                       -70.267848,-70.317331,-70.233612,-70.31024,-70.210123,
                                       -70.311017,-70.189543,-70.33466,-70.165411,-70.334833,-70.190561))

#  id# Longitude Latitude 
p1=cbind(-70.479151,42.442064)
p2=cbind(-70.398143,42.442114)
p3=cbind(-70.467651,42.400128)
p4=cbind(-70.336545,42.400195)
p5=cbind(-70.351623,42.358987)
p6=cbind(-70.267848,42.359006)
p7=cbind(-70.317331,42.316885)
p8=cbind(-70.233612,42.316856)
p9=cbind(-70.31024,42.275407)
p10=cbind(-70.210123,42.275291)
p11=cbind(-70.311017,42.233551)
p12=cbind(-70.189543,42.233512)
p13=cbind(-70.33466,42.191654)
p14=cbind(-70.165411,42.191532)
p15=cbind(-70.334833,42.15019)
p16=cbind(-70.190561,42.150184)

l12=Lines(list(Line(rbind(p1,p2))),ID="12")
l24=Lines(list(Line(rbind(p2,p4))),ID="24")
l43=Lines(list(Line(rbind(p4,p3))),ID="43")
l35=Lines(list(Line(rbind(p3,p5))),ID="35")
l56=Lines(list(Line(rbind(p5,p6))),ID="56")
l68=Lines(list(Line(rbind(p6,p8))),ID="68")
l87=Lines(list(Line(rbind(p8,p7))),ID="87")
l79=Lines(list(Line(rbind(p7,p9))),ID="79")
l910=Lines(list(Line(rbind(p9,p10))),ID="910")
l1012=Lines(list(Line(rbind(p10,p12))),ID="1012")
l1211=Lines(list(Line(rbind(p12,p11))),ID="1211")
l1113=Lines(list(Line(rbind(p11,p13))),ID="1113")
l1314=Lines(list(Line(rbind(p13,p14))),ID="1314")
l1416=Lines(list(Line(rbind(p14,p16))),ID="1416")
l1615=Lines(list(Line(rbind(p16,p15))),ID="1615")

SL = SpatialLines(list(l12,l24,l43,l35,l56,l68,l87,l79,l910,l1012,
                       l1211,l1113,l1314,l1416,l1615))
proj4string(SL) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
rm(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,
   l12,l24,l43,l35,l56,l68,l87,l79,l910,l1012,l1211,l1113,l1314,l1416,l1615)

# split by date
x = sort(unique(obs_standard$date))
a = bind_rows(filter(obs_standard, date %in% x[1]),
              filter(track_standard, date %in% x[1])) %>% 
  arrange(date_time)
b = filter(obs_standard, date %in% x[1])
d = filter(track_standard, date %in% x[1])


new.df = b %>% filter(is.na(spp))  %>% rowwise %>% 
  mutate(distance = distVincentySphere(c(Longitude, Latitude), 
                                       c(trans$Longitude[15], trans$Latitude[15]))) %>% 
  filter(distance<550)
  
library(geosphere)
require(raster)
sp.mydata <- d
coordinates(sp.mydata) <- ~Longitude+Latitude
proj4string(sp.mydata) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
ddd=rgeos::gIntersection(sp.mydata,SL)

dd <- distm(sp.mydata,sp.mydata)  
  
plot(a$Longitude, a$Latitude,col="grey")
points(a$Longitude[a$offline %in% 1], a$Latitude[a$offline %in% 1],col="yellow")
points(a$Longitude[a$offline %in% 0], a$Latitude[a$offline %in% 0],col="blue")

points(a$Longitude[!is.na(a$spp) & a$offline %in% 0],a$Latitude[!is.na(a$spp) & a$offline %in% 0],col="red")
points(a$Longitude[!is.na(a$spp) & a$offline %in% 1],a$Latitude[!is.na(a$spp) & a$offline %in% 1],col="pink")


# add points for ss and standardized tracks
obs_standard = obs_standard %>% group_by(date) %>% 
  arrange(date_time) %>% mutate(index =seq(1:length(Longitude)))
#---------------------#





