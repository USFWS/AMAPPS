library(dplyr)
library(zoo)
library(geosphere)

load("//ifw-hqfs1/MB SeaDuck/AMAPPS/clean_data/AMAPPS_2017_08/obstrack_part1.Rdata")

obstrack = mutate(obstrack, offline = ifelse(is.na(offline),0,offline)) %>% 
  rename(Lat=lat, Long=long)

transit = mutate(transit, transect = as.character(transect),
                 offline = 1) %>% 
  rename(Lat=lat, Long=long)

obs = obstrack %>% filter(!is.na(type), !type %in% c("BEGCNT","ENDCNT")) %>% ungroup()
track = obstrack %>% filter(type %in% c("BEGCNT","ENDCNT") | is.na(type)) %>% ungroup()

obs2 = transit %>% filter(!is.na(type), !type %in% c("BEGCNT","ENDCNT")) %>% ungroup()
transit = transit %>% filter(type %in% c("BEGCNT","ENDCNT") | is.na(type)) %>% ungroup()

obs2 = bind_rows(obs, obs2) %>% arrange(key, sec)

 #------------------------------#

# -------------------- #
# TRANSECT TABLE 
# -------------------- #
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
track.final = track %>% arrange(key, ID) %>%
  mutate(sec = as.numeric(as.character(sec)))

break.at.each.stop = filter(track.final, type %in% c("BEGSEG","BEGTRAN","BEGCNT")) %>%
  group_by(key, transect) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(key, transect, ID, start.stop.index)

new.key = left_join(track.final, break.at.each.stop, by=c("ID","key","transect")) %>% 
  arrange(key, transect, ID) %>% 
  mutate(start.stop.index = na.locf(start.stop.index), 
         newkey = paste(key, transect, start.stop.index, sep="_")) %>% ungroup %>% 
  select(-start.stop.index)

# fix breaks
 keys = unique(new.key$newkey)
 for(a in 1:length(keys)){
   if(any(new.key$sec[new.key$newkey %in% keys[a]] > new.key$sec[new.key$type %in% "ENDCNT" & 
                                                                 new.key$newkey %in% keys[a]])){
     new.key$transect[new.key$newkey %in% keys[a] &  
                       new.key$sec > new.key$sec[new.key$type %in% "ENDCNT" & 
                                                   new.key$newkey %in% keys[a]]] =NA }
 }
track2 = dplyr::select(new.key,-newkey,-begend)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% 
  group_by(newkey) %>% 
  arrange(ID) %>%
  mutate(lon = lead(Long, default = last(Long), order_by = ID),
         lat = lead(Lat, default = last(Lat), order_by = ID)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(Long, Lat), c(lon, lat))) %>%
  select(-lon, -lat) %>% 
  mutate(condition = replace(condition, condition==0, NA)) %>%
  group_by(newkey) %>%  
  summarise(transect = first(transect),
            seat = first(seat),
            obs = first(obs),
            key = first(key),
            AvgCondition = as.numeric(weighted.mean(condition, distance, na.rm=TRUE)), 
            DistFlown_nm = sum(distance, na.rm=TRUE)*0.000539957,
            transect_distance_nb = sum(distance, na.rm=TRUE),
            start_dt = as.POSIXct(paste(first(year),first(month),first(day), sep="/")),
            end_dt = as.POSIXct(paste(last(year),last(month),last(day), sep="/")),
            start_sec = first(sec), 
            end_sec  = last(sec),
            transect_time_min_nb = (end_sec-start_sec)/60,
            temp_start_lon = first(Long),
            temp_start_lat = first(Lat),
            temp_stop_lon = last(Long),
            temp_stop_lat = last(Lat))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, transect, seat)

# group by old key
transectTbl = df %>% group_by(key, transect) %>%  
  summarise(#transect = first(transect),
            seat = first(seat),
            obs = first(obs),
            AvgCondition = as.numeric(weighted.mean(AvgCondition, DistFlown_nm, na.rm=TRUE)), 
            DistFlown_nm = sum(DistFlown_nm),
            transect_distance_nb = sum(transect_distance_nb),
            start_dt = first(start_dt),
            end_dt = last(end_dt),
            start_sec = first(start_sec),
            end_sec = last(end_sec),
            transect_time_min_nb = sum(transect_time_min_nb),
            temp_start_lon = first(temp_start_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lon = last(temp_stop_lon),
            temp_stop_lat = last(temp_stop_lat)) %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, transect, seat)

rm(break.at.each.stop, df, new.key)    

# Check that the output looks ok
# and that each transect has two observers
transectTbl %>% group_by(transect) %>% summarise(numb = n()) %>% filter(numb %% 2 != 0 )
View(transectTbl)

# Check that there isn't an Av. condition of zero
if(any(transectTbl$AvgCondition %in% c(0,NA))) {
  write.csv(transectTbl [transectTbl $AvgCondition %in% c(0,NA),], file.path(dir.out, "AvgCondition.0.csv"),  row.names = FALSE, na = "")
  print("Average condition of zero. The following transects need to be investigated: ")
  transectTbl [transectTbl$AvgCondition %in% c(0,NA),]
}

# 
transectTbl = transectTbl %>% 
  mutate(weather_tx = round(AvgCondition),
         weather_tx = replace(weather_tx, weather_tx==1, "1 - worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==2, "2 - bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx==3, "3 - average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==4, "4 - good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==5, "5 - excellent observation conditions"))
write.csv(transectTbl, file = paste(dir.out, "/", yearLabel, "_transectTbl.csv", sep=""), row.names=FALSE)
# -------------------- #

# -------------------- #
# OBSERVATION TABLE
# -------------------- #
obsTbl = obs2 %>% filter(!type %in% c("WAYPNT","BEGSEG", "BEGCNT", "ENDSEG", "ENDCNT", "COCH")) %>% 
  mutate(comment = paste(comment, dataChange, sep = "; "),
         weather_tx = round(condition),
         weather_tx = replace(weather_tx, weather_tx==1, "1 - worst observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==2, "2 - bad observation conditions"), 
         weather_tx = replace(weather_tx, weather_tx==3, "3 - average observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==4, "4 - good observation conditions"),
         weather_tx = replace(weather_tx, weather_tx==5, "5 - excellent observation conditions")) %>% 
  select(-dataChange) %>% 
  rename(longitude_dd = Long, latitude_dd = Lat, Time_secs = sec, surveyband = band, 
         Count = count, ConditionCode = condition, SpeciesId = type) %>% 
  arrange(ID)
write.csv(obsTbl, file = paste(dir.out,"/", yearLabel,"_Observations.csv", sep=""), row.names=FALSE)
# -------------------- #


# -------------------- #
# TRACK TABLE
# -------------------- #
track3 = bind_rows(track2, transit) %>% 
  arrange(key, sec) %>% 
  dplyr::select(Lat,Long,transect,year,month,day,seat,obs,condition,
                offline,WAVfile,sec,GPSerror,type,comment,index,file,
                crew,dataChange,dataError,original.spp.codes,date,key,
                ID,bearing,sbearing) %>% 
  mutate(type = replace(type, is.na(type),"WAYPNT"),
         date = paste(year, month, day, sep="-"))

write.csv(track3, file =paste(dir.out,"/", yearLabel, "_Track.csv", sep=""), row.names=FALSE)
# -------------------- #


save.image(paste(dir.out,"obstrack_final.Rdata",sep="/"))
# -------------------- #

require(ggplot2)

keys = sort(unique(obs$key))
keys = sort(unique(obs$key[obs$seat %in% 'lf']))

n = 34
n= n+1;

ggplot()+
  geom_point(data = track3[track3$key %in% keys[n],],       
             aes(x=Long, y=Lat,col=as.character(transect)), shape = 20)+
  geom_point(data = track3[track3$key %in% keys[n] & track3$offline %in% 0 & 
      track3$type %in% "BEGCNT",], aes(x=Long, y=Lat),col="green",shape=15)+
  geom_point(data = track3[track3$key %in% keys[n] & track3$offline %in% 0 & 
      track3$type %in% "ENDCNT",], aes(x=Long, y=Lat),col="red",shape=15)+
  
  geom_point(data = obs2[obs2$key %in% keys[n] & !obs2$offline %in% 0,], 
                 aes(x=Long, y=Lat),col="blue",shape=1)+
  geom_point(data = obs2[obs2$key %in% keys[n] & obs2$offline %in% 0,], 
                 aes(x=Long, y=Lat,col=transect),shape=17)


ggplot()+
  geom_point(data = track[track$key %in% keys[n],], aes(x=Long, y=Lat,col=as.character(transect)), shape = 20)+
  geom_point(data = track[track$key %in% keys[n] & track$type %in% "BEGCNT" & track$offline %in% 0,], 
             aes(x=Long, y=Lat),col="green",shape=15)+
  geom_point(data = track[track$key %in% keys[n] & track$type %in% "ENDCNT" & track$offline %in% 0,], 
             aes(x=Long, y=Lat),col="red",shape=9)+
  geom_point(data = obs[obs$key %in% keys[n] & !obs$offline %in% 0,], 
             aes(x=Long, y=Lat),col="blue",shape=1)+
  geom_point(data = obs[obs$key %in% keys[n] & obs$offline %in% 0,], 
             aes(x=Long, y=Lat,col=transect),shape=17)
