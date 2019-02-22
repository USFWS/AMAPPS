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
#---------------------#


#---------------------#
# set paths
#---------------------#
dir.in <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/FWS/LindaWelch/"
dir.out <-"//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/FWS_ME_0910" 
#---------------------#


#---------------------#
# load data
#---------------------#
filenames = list.files(dir.in, full.names=TRUE)
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
  rename(date = year) %>% select(-month,-day,-group) %>% 
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
  rename(condition = cond, seastate = sea, wind_dir = w_dir, 
         wind_knots = w_KT, transect = trans, visibility = view, 
         seconds_from_midnight = sec_af_mid, count = num, comments = notes) %>% 
  select(-date2, -year, -month, -day, -timeB, -timeC, -ht, -loc, -act, -WX, -'..17', -'..19') 

         # not sure what ht, loc, and act are so removing for now
         # loc could be offline?
         # ht = ifelse(act %in% "20 H", "H", ht),


rm(Aug09A, Aug09B, Aug10, Jun09, Jun10, Jul10, Oct09, Oct10, Sep09, Sep10)
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
data$species[data$species %in% "UNSB"] = "SHOR"            
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
data$species[data$species %in% "GOLD"] = "AMGO"            
data$species[data$species %in% "Shark"] = "SHAR"           
data$species[data$species %in% "UNFALCON"] = "FALC"        
data$species[data$species %in% "CAGO"] = "CANG"           
data$species[data$species %in% "CEWA"] = "CEDW"           
data$species[data$species %in% "Moth"] = "UNMO"            
data$species[data$species %in% "YSFL"] = "NOFL"     
data$species[data$original.spp.codes %in% "AMBlDuCK"] = "ABDU"
data$species[data$species %in% "HBWH"] = "HUWH"           
data$species[data$species %in% "YEWA"] = "YWAR"  
data$species[data$species %in% "BASW"] = "BARS" 

data = data %>% filter(!species %in% c(NA, "species"))

data$species[data$species %in% c("UNHA","WCPE","RIDU","UNPL","SPPL","SPSP")] = "UNKN"     
#data$species[data$species %in% "UNHA"] = ""            
#data$species[data$species %in% "WCPE"] = ""           
#data$species[data$species %in% "RIDU"] = ""           
#data$species[data$species %in% "UNPL"] = ""           
#data$species[data$species %in% "SPSP"] = ""           
#data$species[data$species %in% "SPPL"] = ""            
#---------------------#


#---------------------#
# group by cruise for different survey numbers
#---------------------#
#data %>% group_by(group, boat, date, trip) %>% summarise(n=n())
data = data %>% group_by(group, boat, date, trip) %>% 
  mutate(key = paste(group, date, boat, trip, sep="_"))
#---------------------#


#---------------------#
# fix transects
#---------------------#
data = data %>% arrange(key, seconds_from_midnight, time) %>% mutate(index = seq(1:length(species)))

key.list = sort(unique(data$key))

for (a in 1:length(key.list)) {
  y = data[data$key %in% key.list[a],]
  # ggplot(y, aes(long, lat, col = as.character(transect)))+ geom_point() + 
  #   geom_point(data = y[y$species %in% "BEGCNT",],aes(long, lat), size = 3, col="darkgreen",pch=6)+
  #   geom_point(data = y[y$species %in% "ENDCNT",],aes(long, lat), size = 3, col="red",pch=7)+
  #   theme_bw()
  
  # investigate transects that have an off # of BEG/END
  yy = y %>% filter(species %in% c("BEGCNT","ENDCNT")) %>% 
    group_by(transect) %>% summarise(n=n()) %>% filter(n %% 2 != 0)
  
  if(dim(yy)[1]>0) {
    for(b in 1:length(yy$transect)){
      x = y[y$transect %in% yy$transect[b],] %>% arrange(seconds_from_midnight, time)
      xx = x[x$species %in% c("BEGCNT","ENDCNT"),]
      
      ggplot(x, aes(long, lat, col = as.character(transect)))+ geom_point() + 
        geom_point(data = xx[xx$species %in% "BEGCNT",],aes(long, lat), size = 3, col="darkgreen",pch=6)+
        geom_point(data = xx[xx$species %in% "ENDCNT",],aes(long, lat), size = 3, col="red",pch=7)+
        theme_bw()
      
      # edits based on observations above
      if(all(!xx$species %in% "BEGCNT" & dim(xx)[1] %in% 1)){
        to.add = x[1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comment = "ADDED BEGCNT since one was missing",
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
        }
                       
      if(all(!xx$species %in% "ENDCNT" & dim(xx)[1] %in% 1)){  
        to.add = x[dim(x)[1],]
        to.add = mutate(to.add, 
                        species = "ENDCNT", 
                        comment = "ADDED ENDCNT since one was missing",
                        index = index+0.1)
        data = rbind(data, to.add)
        cat("Added ENDCNT to transect\n")
        rm(to.add)
      }
      if(all(length(xx$species[xx$species %in% "BEGCNT"])>length(xx$species[xx$species %in% "ENDCNT"]) & dim(xx)[1] > 1 & dim(xx)[1] < 4)){
        to.add = x[which(x$species %in% "BEGCNT")[2]-1,]
        to.add = mutate(to.add, 
                        species = "ENDCNT", 
                        comment = "ADDED ENDCNT since one was missing",
                        index = index-0,1)
        data = rbind(data, to.add)
        cat("Added ENDCNT to transect\n")
        rm(to.add)
      }
      
      if(all(length(xx$species[xx$species %in% "ENDCNT"])>length(xx$species[xx$species %in% "BEGCNT"]) & dim(xx)[1] > 1 & dim(xx)[1] < 4 & xx$species[1] %in% "BEGCNT")){  
        to.add = x[which(x$species %in% "ENDCNT")[1]+1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comment = "ADDED BEGCNT since one was missing",
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
      }
      if(all(length(xx$species[xx$species %in% "ENDCNT"])>length(xx$species[xx$species %in% "BEGCNT"]) & dim(xx)[1] > 1 & !xx$species[1] %in% "BEGCNT")){  
        to.add = x[1,]
        to.add = mutate(to.add, 
                        species = "BEGCNT", 
                        comment = "ADDED BEGCNT since one was missing",
                        index = index-0.1)
        data = rbind(data, to.add)
        cat("Added BEGCNT to transect\n")
        rm(to.add)
      }
      
    }
  }
}

# one transect with >4 beg/ends
data$species[data$key %in% "Jun09_2009-06-30_FV_NA" & data$transect %in% 2 & data$species %in% "BEGCNT"][3]="delete"
data = filter(data, !species %in% "delete")
#---------------------#


#---------------------#
# export
#---------------------#
write.csv(data, file = paste(dir.out, "data.csv", sep="/"), row.names=FALSE)
#---------------------#
