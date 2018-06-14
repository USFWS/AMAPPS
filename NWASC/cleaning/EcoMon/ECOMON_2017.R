# ------------ #
# ECOMON 2017 data
# GU1701
# GU1702
# GU1706
# ------------ #


# ------------ #
# load packages
# ------------ #
require(dplyr)
require(readxl)
require(odbc)
require(zoo)
# ------------ #


# ------------ #
# load data
# ------------ #
obs <- read_excel("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdSightings2017.xlsx")
effort <- read.csv("Z:/seabird_database/datasets_received/EcoMon/ECOMON_2017/EcomonSeabirdEffort2017Rev.csv")
# ------------ #


# ------------ #
# fix errors
# ------------ #
names(obs) = tolower(names(obs))
names(effort) = tolower(names(effort))

obs$original_species_tx = paste(obs$species,obs$comname,obs$sciname,sep="_")

# ------- #
# look up species errors
# ------- #
db <- dbConnect(odbc::odbc(), driver='SQL Server', server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species")

tmp <- !obs$species %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$species[tmp]))

obs$species[obs$species %in% "BASW"] = "BARS" #Barn swallow
obs$species[obs$species %in% "LEST"] = "LETE" #least tern
obs$species[obs$species %in% "LHSP"] = "UNSP" #Leach's/Hartcourt's storm-petrel
obs$species[obs$species %in% "PASS"] = "UNPA" 
obs$species[obs$species %in% "RWBB"] = "RWBL" #Red-winged blackbird
obs$species[obs$species %in% "STTE"] = "CATE" #Common/Arctic tern
obs$species[obs$species %in% "TRPE"] = "HEPE" #Trinidad petrel aka Herald Petrel
obs$species[obs$species %in% "WTTB"] = "WTTR" #White-tailed tropicbird
# ------- #

# ------- #
# split time and date
# ------- #
obs = mutate(obs, 
             date = as.Date(sapply(strsplit(sightdatetimelocal," "),head,1),format="%d-%b-%y"), 
             time = sapply(strsplit(sightdatetimelocal," "),tail,1)) #%>% 
#dplyr::select(-sightdatetimelocal)

effort = effort %>% 
  arrange(tripid,transect,leg,id) %>% 
  rowwise() %>% 
  mutate(datetimelocal = as.character(datetimelocal),
         date = as.Date(sapply(strsplit(datetimelocal," "),head,1),format="%d-%b-%y"), 
         hour = as.numeric(substring(sapply(strsplit(datetimelocal," "),tail,2)[1],1,2)),
         min = substring(sapply(strsplit(datetimelocal," "),tail,2)[1],4,5),
         sec = substring(sapply(strsplit(datetimelocal," "),tail,2)[1],7,8),
         p = sapply(strsplit(datetimelocal," "),tail,1),
         hour = ifelse(p %in% "PM" & !hour %in% "12", hour+12, hour),
         time = paste(hour,min,sec,sep=":")) #%>% 
#dplyr::select(-datetimelocal,-hour,-min,-sec,-p)
# ------- #

# ------- #
# add age id, associate, & behavior_id
# ------- #
obs = obs %>%
  mutate(behavior_id = behaviordesc,
         association = assocdesc) %>%
  rename(type = species,behavior_tx = behaviordesc, age_tx = age) %>% 
  rowwise %>% 
  mutate(age_id = ifelse(age_tx %in% 'Adult',1,ifelse(age_tx %in% 'Subadult',7,5)),
         behavior_id = replace(behavior_id,behavior_id %in% c("directional flight","non-directional flight"),13),
         behavior_id = replace(behavior_id,behavior_id %in% c("feeding"),9),
         behavior_id = replace(behavior_id,behavior_id %in% c("following ship"),15),
         behavior_id = replace(behavior_id,behavior_id %in% c("milling"),21),
         behavior_id = replace(behavior_id,behavior_id %in% c("other"),23),
         behavior_id = replace(behavior_id,behavior_id %in% c("pattering"),42),
         behavior_id = replace(behavior_id,behavior_id %in% c("piracy"),24),
         behavior_id = replace(behavior_id,behavior_id %in% c("sitting"),35),
         behavior_id = replace(behavior_id,behavior_id %in% c("porpoising"),25),
         behavior_id = replace(behavior_id,behavior_id %in% c("diving"),8),
         behavior_id = replace(behavior_id,behavior_id %in% c("unknown"),44), 
         association = replace(association,association %in% "associated with other individuals",type),
         association = replace(association,association %in% "solitary bird",NA),
         association = replace(association,association %in% "association unknown",'UNKN'),
         association = replace(association,is.na(association) & behavior_id %in% 15,"BOAT")) %>% 
  as.data.frame()
# ------- #

# ------- #
# add type in effort
# ------- #
effort = mutate(effort, type = NA,
                type =ifelse(event %in% 1,"BEGCNT",ifelse(event %in% 3,"ENDCNT","WAYPNT")))
# ------- #

# ------- #
# assign transect ids and effort to obs
# ------- #
# check that there are BEG and ENDs for all 
effort %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% 
  arrange(date, time, transect) %>% 
  group_by(tripid,transect) %>% 
  summarise(count = n()) %>% 
  filter(count %% 2!=0)

# observations are on effort
obs = mutate(obs, effort = "on")



# fix those with odd efforts
# x = effort[effort$tripid %in% "GU1702" & effort$transect %in% 83,] %>% 
#   mutate(type = ifelse(type %in% "WAYPNT","W",type)) %>% arrange(time)

effort = mutate(effort, comments=as.character(comments))

#GU1701    69.0   
effort$type[effort$tripid %in% "GU1701" & effort$transect %in% 69 & effort$time %in% "12:44:14"] = "BEGCNT"
effort$comments[effort$tripid %in% "GU1701" & effort$transect %in% 69 & effort$time %in% "12:44:14"] = "Added BEGCNT based on effort"
#GU1701    70.0     
effort$type[effort$tripid %in% "GU1701" & effort$transect %in% 70 & effort$time %in% "16:32:39"][2] = "COMMENT"
effort$comments[effort$tripid %in% "GU1701" & effort$transect %in% 70 & effort$time %in% "16:32:39"][2] = "Changed to comment based on effort"
#GU1702     4.00    
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 4 & effort$time %in% "17:45:16"] = "ENDCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 4 & effort$time %in% "17:45:16"] = "Added ENDCNT based on effort"
#GU1702     8.00
# one have one BEG???
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 4 & effort$time %in% "5:45:45"] = "COMMENT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 4 & effort$time %in% "5:45:45"] = "changed to COMMENT based on effort"
#GU1702     9.00     
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 9 & effort$time %in% "6:44:01"] = "BEGCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 9 & effort$time %in% "6:44:01"] = "Added BEGCNT based on effort"
#GU1702    11.0      
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 11 & effort$time %in% "11:10:42"] = "BEGCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 11 & effort$time %in% "11:10:42"] = "Added BEGCNT based on effort"
#GU1702    12.0    
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 12 & effort$time %in% "17:10:17"] = "ENDCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 12 & effort$time %in% "17:10:17"] = "Added ENDCNT based on effort"
#GU1702    35.0     
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 35 & effort$time %in% "17:48:28"] = "ENDCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 35 & effort$time %in% "17:48:28"] = "Added ENDCNT based on effort"
#GU1702    83.0     
effort$type[effort$tripid %in% "GU1702" & effort$transect %in% 83 & effort$time %in% "7:35:22"] = "ENDCNT"
effort$comments[effort$tripid %in% "GU1702" & effort$transect %in% 83 & effort$time %in% "7:35:22"] = "Added ENDCNT based on effort"

#
# combine and assign
obstrack = bind_rows(obs,effort) %>% 
  mutate(datetime = as.POSIXct(paste(date, time, sep = " "), format = "%Y-%m-%d %H:%M:%S")) %>% 
  arrange(tripid,datetime) %>%
  mutate(newId = seq(1:length(id)), effort = ifelse(newId %in% 1:3,"off",effort)) %>% # because can't start off effort with na.locf
  group_by(tripid,date) %>%
  mutate(effort = ifelse(newId<newId[!is.na(effort)][1],"off",effort), effort = na.locf(effort))

#obstrack$effort = na.locf(obstrack$effort)
obstrack$transect[obstrack$effort %in% "on"] = na.locf(obstrack$transect[obstrack$effort %in% "on"])
obstrack$effort[obstrack$type %in% c('BEGCNT','ENDCNT')] = "on"
obstrack$transect[obstrack$effort %in% "off"] = NA
obstrack$offline = ifelse(obstrack$effort %in% "off",1,0)

# fix offline obs after last end
obstrack = obstrack %>% arrange(desc(datetime)) %>%
  group_by(tripid,transect) %>%
  mutate(offline = ifelse(newId>newId[type %in% "ENDCNT"][1],1,offline)) %>%
  ungroup() %>% 
  arrange(datetime)

# pull obstrack apart
rm(obs,effort)
obs = obstrack[!obstrack$type %in% c("BEGCNT","ENDCNT","WAYPNT"),]
effort = obstrack[obstrack$type %in% c("BEGCNT","ENDCNT","WAYPNT"),]
# ------- #

# ------------ #


# ------------ #
# split by survey and assign id
#  GU1701 2017-05-16 to 2017-06-06 -> id 393
#  GU1702 2017-06-10 to 2017-06-22 -> id 394
#  GU1706 2017-10-31 to 2017-11-09 -> id 412
# ------------ #
obs = obs %>% mutate(dataset_id = 412,
                     dataset_id = replace(dataset_id,tripid %in% 'GU1701',393),
                     dataset_id = replace(dataset_id,tripid %in% 'GU1702',394))
effort = effort %>% mutate(dataset_id = 412,
                           dataset_id = replace(dataset_id,tripid %in% 'GU1701',393),
                           dataset_id = replace(dataset_id,tripid %in% 'GU1702',394))


obs1 = obs[obs$dataset_id %in% 393,]
obs2 = obs[obs$dataset_id %in% 394,]
obs6 = obs[obs$dataset_id %in% 412,]

effort1 = effort[effort$dataset_id %in% 393,]
effort2 = effort[effort$dataset_id %in% 394,]
effort6 = effort[effort$dataset_id %in% 412,]
# ------------ #

# ------------ #
# exportS
# ------------ #
dir.out = "Z:/seabird_database/data_import/in_progress/EcoMon/ECOMON_2017"
write.csv(obs1, paste(dir.out,"GU1701_obs.csv",sep="/"))
write.csv(obs2, paste(dir.out,"GU1702_obs.csv",sep="/"))
write.csv(obs6, paste(dir.out,"GU1706_obs.csv",sep="/"))
write.csv(effort1, paste(dir.out,"GU1701_effort.csv",sep="/"))
write.csv(effort2, paste(dir.out,"GU1702_effort.csv",sep="/"))
write.csv(effort6, paste(dir.out,"GU1706_effort.csv",sep="/"))
# ------------ #

# test plot
require(ggplot2)

n = c(1:5)
e = effort2
o = obs2
transect.list = sort(unique(e$transect))

ggplot(e[e$transect %in% transect.list[n],],aes(lon,lat,col=as.character(transect)))+geom_point()+
  geom_point(data=e[e$transect %in% transect.list[n] & e$type %in% "BEGCNT",], aes(x=lon, y=lat),col="darkgreen",size=3,shape=7)+
  geom_point(data=e[e$transect %in% transect.list[n] & e$type %in% "ENDCNT",], aes(x=lon, y=lat),col="red",size=3,shape=9)+
  theme_bw()+
  geom_point(data=o[o$transect %in% transect.list[n] & o$offline %in% 0,],aes(x=lon,y=lat,col=as.character(transect)),shape=3,size=3)+
  geom_point(data=o[o$transect %in% transect.list[n] & !o$offline %in% 0,],aes(x=lon,y=lat),shape=6,size=3,col="grey")


ggplot(e,aes(lon,lat,col=as.character(transect)))+geom_point()+
  geom_point(data=o, aes(x=lon, y=lat,col=as.character(transect)),shape=3,size=3)
