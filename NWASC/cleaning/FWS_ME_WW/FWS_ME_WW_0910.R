#---------------------#
# format FWS Maine Whale Watch cruise data
# 2008 + 2009
# no effort
#---------------------#


#---------------------#
# load packages
#---------------------#
require(dplyr) # %>% 
library(readxl)
require(odbc)
require(ggplot2)
#---------------------#


#---------------------#
# set paths
#---------------------#
dir.in <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/FWS/LindaWelch/"
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/FWS_ME_0910"
#---------------------#


#---------------------#
# load data
#---------------------#
filenames = list.files(dir.in, full.names=TRUE, pattern = "xls$")
#lapply(filenames, function(i) {read_excel(i)}) # formats are not the same
Jun09 = read_excel(filenames[1]) %>% mutate(group = "Jun09")
Oct09 = read_excel(filenames[2]) %>% mutate(group = "Oct09")
Sep09 = read_excel(filenames[3]) %>% mutate(group = "Sep09")
Aug09A = read_excel(filenames[4]) %>% mutate(group = "Aug09A")
Aug09B = read_excel(filenames[5]) %>% mutate(group = "Aug09B")
Aug10 = read_excel(filenames[6], skip = 5, col_names = FALSE) %>% mutate(group = "Aug10")# summary table up top in excel )
Jul10 = read_excel(filenames[7], skip = 6, col_names = FALSE) %>% mutate(group = "Jul10")# summary table up top in excel 
Jun10 = read_excel(filenames[8], skip = 5, col_names = FALSE) %>% mutate(group = "Jun10")# summary table up top in excel 
Oct10 = read_excel(filenames[9]) %>% mutate(group = "Oct10")
Sep10 = read_excel(filenames[10]) %>% mutate(group = "Sep10")
effort = read_excel(filenames[11])

# add column names
tmp_name = Jun09[0,] %>% 
  rename(date = year) %>% 
  select(-month,-day,-group) %>% 
  mutate(timeB = NA, timeC = NA, group=NA)
names(Jul10) = names(tmp_name)
names(Jun10) = names(tmp_name)
names(Aug10) = names(tmp_name)
rm(tmp_name)

# change col names
Sep10 = rename(Sep10, date = DATE, timeB = t2, timeC = period)
Oct10 = rename(Oct10, date = DATE, timeB = t2, timeC = period)

# combine data after minor formating
Aug09A = mutate(Aug09A, 
                w_KT = as.character(w_KT),
                cond = as.numeric(cond))
Aug09B = mutate(Aug09B, 
                w_KT = as.character(w_KT),
                act = as.character(act))
Aug10 = mutate(Aug10, 
               act = as.character(act))
Jun09 = mutate(Jun09, 
               trip = as.numeric(trip), 
               type = as.numeric(type))
Jul10 = mutate(Jul10, 
               act = as.character(act))
Oct09 = mutate(Oct09, 
               w_KT = as.character(w_KT),
               act = as.character(act))
Oct10 = mutate(Oct10, 
               act = as.character(act))
Sep10 = mutate(Sep10, 
               act = as.character(act),
               w_KT = as.character(w_KT))
Sep09 = mutate(Sep09, 
               w_KT = as.character(w_KT))

               
data = bind_rows(Aug09A, Aug09B, Aug10, 
                 Jun09, Jun10,
                 Jul10, 
                 Oct09, Oct10, 
                 Sep09, Sep10)

data = data %>% 
  rename(date2 = date,
         unknown_time = time) %>% 
  mutate(year = ifelse(year %in% 0009, 2009, year),
         year = ifelse(year %in% 2008, 2009, year),
         date = NA,
         date = ifelse(is.na(date2),
                       as.character(as.POSIXct(paste(year, month, day, sep ="-"), format = '%Y-%m-%d')), 
                       as.character(date2)),
         time = sapply(strsplit(as.character(timeB), " "),tail,1),
         loc = ifelse(ht %in% c("A","J","UK"), loc, age),
         age = ifelse(age %in% c("IN","OUT"), ht, age),
         age = ifelse(age %in% "A", "adult", age),
         age = ifelse(age %in% "J", "juvenile", age),
         age = ifelse(age %in% "UK", "unknown", age),
         age = ifelse(age %in% "S", "subadult", age),
         age = ifelse(age %in% "I", "immature", age),
         age = ifelse(age %in% c("MIX","MIXED"), "mixed", age),
         age = ifelse(age %in% c("1822", "L","M","H","HH","VAR"), NA, age)) %>% 
  rename(condition = cond, 
         seastate = sea, 
         wind_dir = w_dir, 
         wind_knots = w_KT, 
         transect = trans, 
         visibility = view, 
         seconds_from_midnight = sec_af_mid, 
         count = num, 
         comments = notes) #%>% 
 # select(-date2, -year, -month, -day, -timeB, -timeC, -ht, -loc, -act, -WX, -'..17', -'..19') 

         # not sure what ht, loc, and act are so removing for now
         # loc could be offline?
         # ht = ifelse(act %in% "20 H", "H", ht),


rm(Aug09A, Aug09B, Aug10, Jun09, Jun10, Jul10, Oct09, Oct10, Sep09, Sep10)

# there are issues with duplicated data
data = data[!duplicated(data),]

# Code 3. Observation Conditions (75)
# 1 = Bad (general observations only)
# 2 = Poor (no quantitative analysis)
# 3 = Fair
# 4 = Average
# 5 = Good
# 6 = Excellent
# 7 = Maximum
data = data %>% 
  mutate(condition = replace(condition, condition %in% 7, "Best conditions"),
         condition = replace(condition, condition %in% 6, "Excellent"),
         condition = replace(condition, condition %in% 5, "Good"),
         condition = replace(condition, condition %in% 4, "Average"),
         condition = replace(condition, condition %in% 3, "Fair"),
         condition = replace(condition, condition %in% 2, "Poor"))

# Code 5. Sea State (49)
# 0 = Calm
# 1 = Rippled (0.0 1-0.25 ft)
# 2 = Wavelet (0.26-2.0 ft)
# 3 = Slight (2-4 ft)
# 4 = Moderate (4-8 ft)
# 5 = Rough (8-13 ft)
# 6 = Very rough (13-20 ft)
# 7 = High (20-30 ft)
# 8 = Over 30 ft			
data = data %>% 
  mutate(seastate = replace(seastate, seastate %in% 0, "Calm"),
         seastate = replace(seastate, seastate %in% 1, "Rippled (0.0 1-0.25 ft)"),
         seastate = replace(seastate, seastate %in% 2, "Wavelet (0.26-2.0 ft)"),
         seastate = replace(seastate, seastate %in% 3, "Slight (2-4 ft)"),
         seastate = replace(seastate, seastate %in% 4, "Moderate (4-8 ft)"))
         
# Code 6. Weather (55-56)		
# 00 = Clear to partly cloudy (0-50% cloud cover)
# 03 = Cloudy to overcast (51-100% cloud cover)	
# 41 = Fog (patchy)			
# 43 = Fog (solid)			
# 68 = Rain			
# 71 = Snow			
# 87 = Hail
data = data %>% 
  mutate(weather = WX, 
         weather = replace(weather, weather %in% 0, "Clear to partly cloudy (0-50% cloud cover)"),
         weather = replace(weather, weather %in% 3, "Cloudy to overcast (51-100% cloud cover)"),
         weather = replace(weather, weather %in% 41, "Fog (patchy)"),
         weather = replace(weather, weather %in% 43, "Fog (solid)"),
         weather = replace(weather, weather %in% 68, "Rain"),
         weather = replace(weather, weather %in% c(1,2), NA))
# not sure what 1 or 2 are probably typos? Or conversions are not listed



         
#---------------------#


#---------------------#
# format species
#---------------------#
data$original.spp.codes = data$species

db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species")
dbDisconnect(db)

tmp <- !data$species %in% spplist$spp_cd
x = data$species[tmp][!data$species[tmp] %in% c("BEGCNT","ENDCNT","COMMENT","COCH")]
message("Found ", length(x), " entries with non-matching AOU codes")
unique(x); rm(x)

data$species[data$species %in% "BEGTRS"] = "BEGCNT"      
data$species[data$species %in% "Boat"] = "BOAT"            
data$species[data$species %in% "Hseal"] = "HASE"           
data$species[data$species %in% c("CurrentRp","CurrentrP")] = "OCFR"       
data$species[data$species %in% "ENDTRS"] = "ENDCNT"          
data$species[data$species %in% "GrayS"] = "GRSE"           
data$species[data$species %in% "Seaweed"] = "MACR"         
data$species[data$species %in% c("UNSB","UNPL")] = "SHOR"            
data$species[data$species %in% "DWSC"] = "DASC"           
data$species[data$species %in% "RedAlgae"] = "ALGA"        
data$species[data$species %in% "Tuna"] = "TUNA"            
data$species[data$species %in% "BIRD"] = "UNBI"            
data$species[data$species %in% "Basking"] = "BASH"         
data$species[data$species %in% "Sunfish"] = "MOLA"         
data$species[data$species %in% c("BUTTER","BUTTERFLY")] = "UBUT"       
data$species[data$species %in% "AMBlDuCK"] = ""        
data$species[data$species %in% c("HUMMINGBIRD", "HUMMING")] = "UNHU"      
data$species[data$species %in% "P0JA"] = "POJA"            
data$species[data$species %in% "Fish"] = "FISH"            
data$species[data$species %in% "DRAGONFLY"] = "DRAG"       
data$species[data$species %in% "GEESE"] = "UGOO"           
data$species[data$species %in% "Trawl"] = "BOTD"           
data$species[data$species %in% "GOLD"] = "AMGO" # goldfinch            
data$species[data$species %in% "Shark"] = "SHAR"           
data$species[data$species %in% "UNFALCON"] = "FALC"        
data$species[data$species %in% "CAGO"] = "CANG"           
data$species[data$species %in% "CEWA"] = "CEDW"           
data$species[data$species %in% "Moth"] = "UNMO"            
data$species[data$species %in% "YSFL"] = "NOFL" # yellow-shafted flicker, northern flicker    
data$species[data$original.spp.codes %in% "AMBlDuCK"] = "ABDU"
data$species[data$species %in% "HBWH"] = "HUWH"           
data$species[data$species %in% "YEWA"] = "YWAR" # yellow warbler 
data$species[data$species %in% "BASW"] = "BARS" 
data$species[data$species %in% "UNHA"] = "HAWK" # unidentified hawk           
data$species[data$species %in% "RIDU"] = "RNDU" # ringneck duck?          
data$species[data$species %in% "SPSP"] = "SPSA" # spotted sandpiper                   
data$species[data$species %in% "SPPL"] = "SEPL" # semipalmated plover 

# need to add code
# "WCPE" white chinned petrel added

# filter odd rows out (NAs and extra headers)
data = data %>% filter(!species %in% c(NA, "species"))

# behavior = action (act)
# Code 17. Bird Behavior (56-57)
# 00 = Undetermined
# 01 = Sitting on water
# 10 = Sitting on floating object
# 15 = Sitting on land
# 20 = Flying in direct & consistent heading
# 29 = Flying, height variable
# 31 = Flying, circling ship
# 32 = Flying, following ship
# 34 = Flying, being pirated
# 35 = Flying, milling or circling (foraging)
# 48 = Flying, meandering
# 61 = Feeding at or near surface while flying (dipping or pattering)
# 65 = Feeding at surface (scavenging)
# 66 = Feeding at or near surface, not diving or flying (surface seizing)
# 70 = Feeding below surface (pursuit diving)
# 71 = Feeding below surface (plunge diving)
# 82 = Feeding above surface (pirating)
# 90 = Courtship display
# 98 = Dead
# 
# Code 18. Mammal Behavior (56-57)
# 00 = Undetermined
# 01 = Leaping
# 02 = Feeding
# 03 = Mother with young
# 04 = Synchronous diving
# 05 = Bow riding
# 06 = Porpoising
# 07 = Hauled out
# 08 = Sleeping
# 09 = Avoidance
# 14 = Curious/following
# 15 = Cetacea/pinniped association
# 16 = Pinniped/bird association
# 17 = Cetacea/bird association
# 18 = Breeding/copulation
# 19 = Moribund/dead

#data = mutate(data, 
#              species_type = ifelse(species %in% spplist$spp[spplist$species_type_id %in% 2,"marinemammal",ifelse(species %in% spplist$spp[spplist$species_type_id %in% c(1,8),"bird",NA)))#s,
#              act = ifelse(act %in%, ,)))

#---------------------#


#---------------------#
# address long/long errors
#---------------------#
data = mutate(data, 
              lat = ifelse(lat %in% "0", NA, lat), 
              long = ifelse(long %in% "0", NA, long))
#---------------------#


#---------------------#
# add seat
#---------------------#
data = mutate(data, seat = NA,
              seat = sapply(strsplit(boat, "-"), tail, 1),
              seat = ifelse(seat %in% c("STAR", "STARB"), "starboard", seat),
              seat = ifelse(seat %in% c("na","0","FV"), NA, seat),
              seat = tolower(seat))

# add observer id if sorting by observer instead of seat
data = mutate(data, obs = seat)

# change boats to boat names
# BO = ?
# FV = Friendship V
# AC or ACAT = Atlanticat
data = mutate(data, 
              boat = sapply(strsplit(boat, "-"), head, 1),
              boat = ifelse(boat %in% "FV", "Friendship V", boat),
              boat = ifelse(boat %in% c("AC","ACAT"), "AtlantiCat", boat))
#---------------------#


#---------------------#
# group by cruise for different survey numbers
# fix transects
#---------------------#
# remove general observations and station counts from transects
data = mutate(data, transect = ifelse(type %in% c(1,7), NA, transect),
              species = ifelse(type %in% c(1,7) & species %in% c("BEGCNT", "ENDCNT"), "COMMENT", species))

#data %>% group_by(group, boat, date, trip) %>% summarise(n=n())
data = data %>% 
  mutate(trip = ifelse(trip %in% 0, NA, trip),
         key = paste(group, date, boat, seat, trip, transect, sep="_")) %>% 
  arrange(date, key, seconds_from_midnight, time) %>% 
  group_by(key) %>% 
  mutate(index = seq(1:length(species)))

key.list = sort(unique(data$key))

# one transect with >4 beg/ends
data$species[data$key %in% "Jun09_2009-06-30_Friendship V_NA_NA_2" & data$species %in% "BEGCNT"][3]="delete"
data = filter(data, !species %in% "delete")

# fix others
for (a in 1:length(key.list)) {
  y = data[data$key %in% key.list[a],]
  yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
  
  if(dim(yy)[1]>0) {
      x = y %>% arrange(seconds_from_midnight, time, index)
      xx = x[x$species %in% c("BEGCNT","ENDCNT"),]

      # edits based on observations above
      
      # transect only has one ENDCNT and is missing BEGCNT
      if(all(!xx$species %in% "BEGCNT" & dim(xx)[1] %in% 1)){
        to.add = x[1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comments = "ADDED BEGCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
        }
                       
      # transect only has one BEGCNT and is missing ENDCNT
      if(all(!xx$species %in% "ENDCNT" & dim(xx)[1] %in% 1)){  
        to.add = x[dim(x)[1],]
        to.add = mutate(to.add, 
                        species = "ENDCNT", 
                        comments = "ADDED ENDCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index+0.1)
        data = rbind(data, to.add)
        cat("Added ENDCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      }
      
      # transect has more ENDCNTs than BEGCNTs and is missing first BEGCNT
      if(all(length(xx$species[xx$species %in% "ENDCNT"])>length(xx$species[xx$species %in% "BEGCNT"]) & dim(xx)[1] > 1 & !xx$species[1] %in% "BEGCNT")){  
        to.add = x[1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comments = "ADDED BEGCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      }
      
      
      # transect has more BEGCNTs than ENDCNTs and is missing last ENDCNT
      if(all(length(xx$species[xx$species %in% "BEGCNT"])>length(xx$species[xx$species %in% "ENDCNT"]) & dim(xx)[1] > 1 & !xx$species[length(xx$species)] %in% "ENDCNT")){  
        to.add = x[length(x$species),]
        to.add = mutate(to.add, 
                        species = "ENDCNT", 
                        comments = "ADDED ENDCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index+0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      }
      
      # transect has more BEGCNTs than ENDCNTs
      if(all(length(xx$species[xx$species %in% "BEGCNT"])>length(xx$species[xx$species %in% "ENDCNT"]) & dim(xx)[1] > 1 & dim(xx)[1] < 4)){
        to.add = x[which(x$species %in% "BEGCNT")[2]-1,]
        to.add = mutate(to.add, 
                        species = "ENDCNT", 
                        comments = "ADDED ENDCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index-0,1)
        data = rbind(data, to.add)
        cat("Added ENDCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      }
      
      # transect has more ENDCNTs than BEGCNTs
      if(all(length(xx$species[xx$species %in% "ENDCNT"])>length(xx$species[xx$species %in% "BEGCNT"]) & dim(xx)[1] > 1 & dim(xx)[1] < 4 & xx$species[1] %in% "BEGCNT")){  
        to.add = x[which(x$species %in% "ENDCNT")[1]+1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comments = "ADDED BEGCNT since one was missing",
                        age = NA, 
                        original.spp.codes = NA, 
                        count = NA, 
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
        y = data[data$key %in% key.list[a],]
        yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
        x = y %>% arrange(seconds_from_midnight, time, index)
        xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      }
      
    }
  }




# double check 
data %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% 
  group_by(key, transect) %>% summarise(n=n()) %>% filter(n %% 2 != 0)

# ungroup
data = as.data.frame(data)

# check for transects that don't have either a BEG or END

#effort.list = data %>% filter(species %in% "ENDCNT") %>% group_by(key) %>% summarise(first(key))
#key.list[!key.list %in% effort.list$key]; rm(effort.list)

x = data[data$key %in% "Aug09A_2009-08-06_Friendship V_starboard_3",] %>% 
  arrange(seconds_from_midnight, time, index)
to.add = x[1,]
to.add = mutate(to.add, 
                species = "BEGCNT", 
                comments = "ADDED BEGCNT since one was missing",
                age = NA, 
                original.spp.codes = NA, 
                count = NA, 
                index = index-0.1)
to.add2 = x[dim(x)[1],]
to.add2 = mutate(to.add2, 
                species = "ENDCNT", 
                comments = "ADDED ENDCNT since one was missing",
                age = NA, 
                original.spp.codes = NA, 
                count = NA, 
                index = index+0.1)
data = rbind(data, to.add, to.add2)
cat("Added BEGCNT and ENDCNT to transect\n")
rm(to.add, to.add2, x)


x = data[data$key %in% "Jun09_2009-06-13_Friendship V_NA_NA_5",] %>% 
  arrange(seconds_from_midnight, time, index)
to.add = x[1,]
to.add = mutate(to.add, 
                species = "BEGCNT", 
                comments = "ADDED BEGCNT since one was missing",
                age = NA, 
                original.spp.codes = NA, 
                count = NA, 
                index = index-0.1)
to.add2 = x[dim(x)[1],]
to.add2 = mutate(to.add2, 
                 species = "ENDCNT", 
                 comments = "ADDED ENDCNT since one was missing",
                 age = NA, 
                 original.spp.codes = NA, 
                 count = NA, 
                 index = index+0.1)
data = rbind(data, to.add, to.add2)
cat("Added BEGCNT and ENDCNT to transect\n")
rm(to.add, to.add2, x)

# error BEGCNTs added
data = filter(data, !is.na(key))

# check that every BEG has an END after it 
# and every END has a BEG before it
test.set = data %>% 
  filter(species %in% c("BEGCNT","ENDCNT")) %>% 
  arrange(seconds_from_midnight, time, index) 
test = cbind(test.set$key[1:dim(test.set)[1]-1], 
             test.set$key[2:dim(test.set)[1]],
             test.set$species[1:dim(test.set)[1]-1], 
             test.set$species[2:dim(test.set)[1]]) %>% 
  as.data.frame()
names(test) = c("key1","key2","starts","stops")
test %>% rowwise() %>% filter(key1 %in% key2, starts %in% stops)

# add original transect column with trip + transect
data = mutate(data, source_transect = paste("trip_", trip, "_transect_", transect, sep=""))
#---------------------#



#---------------------#
# fix boats
#---------------------#
data = mutate(data, 
              species = ifelse(species %in% "BOAT" & comments %in% c("LOBSTER NO BIRD","LOBSTER BOAT",
                                                                     "LOBSTERS NO BIRDS","LOBSTER BEYOND 300",
                                                                     "LOBSTER NO BIRDS","LOBSTER"), 
                               "BOLO", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("ACADIAN","ACADIAN NO BIRDS","ACAT"), 
                               "BOWW", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("BH FERRY","BH FERRY NO BIRDS"), 
                               "BOFE", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("CLAM DRAGGERS",
                                                                     "CLAM DRAGGERS NO BIRDS","CLAM TRAWLERS",
                                                                     "CRAB TRAWLER NO BIRDS","TRAWL NO BIRDS" ,
                                                                     "TRAWLER NO BIRDS"), 
                               "BOTD", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("COAST GUARD","COASTGUARD NO BIRDS"), 
                               "BOCG", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("CRUISE SHIP","SM CRUISE SHIP NO BIRDS",
                                                                     "NATURE CRUISE NO BIRDS"), 
                               "BOCR", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("FISHING","FISHING BOAT NO BIRDS",
                                                                     "FISHING NO BIRDS","TUNA",                                            
                                                                     "TUNA BOAT NO BIRDS",                              
                                                                     "TUNA FISHING",                                    
                                                                     "TUNA FISHING NO BIRDS",                           
                                                                     "TUNABOAT NO BIRDS"), 
                               "BOFI", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("GREAT EASTERN TANKER"), 
                               "BOTA", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("LG PURSE SEINER FAR AWAY 150FT 'WESTERN VENTURE'",
                                                                     "PURSE NO BIRDS","PURSE SEINER"), 
                               "BOPS", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("SAIL","SAILBOAT","SAILBOAT NO BIRD",                                
                                                                     "SAILBOAT NO BIRDS","SAILBOATS"), 
                               "BOSA", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("YACHT"), 
                               "BOYA", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("PLEASURE NO BIRDS"), 
                               "BOPL", species),
              species = ifelse(species %in% "BOAT" & comments %in% c("KAYAKERS","KAYAKS","KAYAKS NO BIRDS"), 
                               "BOKA", species))
#---------------------#


#---------------------#
# summarise effort
#---------------------#
# assign dataset id + name
data = mutate(data, dataset_name = paste("BarHarborWW", 
                                         format(as.Date(date, format = "%Y-%m-%d"), "%m%d%Y"),
                                         sep="_"))

db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
datalist = dbGetQuery(db,"select * from dataset")
dbDisconnect(db)

data = left_join(data, select(datalist, dataset_name, dataset_id), by = "dataset_name")


# since no offline data, can just grab first and last in group for BEG/END
effort = data %>% 
  filter(species %in% c("BEGCNT","ENDCNT")) %>% 
  group_by(dataset_id, dataset_name) %>%
  summarise(start_dt = first(date),
            end_dt = last(date),
            start_time = first(time),
            end_time = last(time),
            start_species = first(species),
            end_species = last(species))



#"BarHarborWW_06302009" -> a mess
#"BarHarborWW_08092009" -> Aug09A_2009-08-09_Friendship V_starboard_2_3
#"BarHarborWW_08252009" 
"BarHarborWW_08272009" #-> trip 1 transect 3+6 missing BEG
"BarHarborWW_10102009" 
"BarHarborWW_10112009"
"BarHarborWW_09102010" 
"BarHarborWW_NA" 


#---------------------#


#---------------------#
# export
#---------------------#
data = select(data, -'1', -unknown_time, -trip, -transect, -type, -boat, -key)
  
write.csv(data, file = paste(dir.out, "data.csv", sep="/"), row.names=FALSE)
#---------------------#
