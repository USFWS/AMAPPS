#---------------------------#
# format BOEM HiDef Aerial data
#---------------------------#


#---------------------------#
# packages
#---------------------------#
require(dplyr)
require(zoo)
require(geosphere)
#---------------------------#


#---------------------------#
# directories
#---------------------------#
dir = "//IFW9mbm-fs1/SeaDuck/seabird_database/data_import/in_progress/BOEM_HiDef_NC"
#---------------------------#


#---------------------------#
# load data
#---------------------------#
data = read.csv(paste(dir,"BOEMHiDef_NC2011_aerial.csv",sep="/"))
data_track = read.csv(paste(dir,"BOEMHiDef_NC2011_aerial_track.csv",sep="/"))
#data_transect = read.csv(paste(dir,"BOEMHiDef_NC2011_aerial_transects.csv",sep="/"))
id = 144
#---------------------------#



#---------------------------#
# format track 
#---------------------------#
data_track = data_track %>% rename(lon = long) %>% 
  mutate(date = sapply(strsplit(as.character(date_time), " "),head,1),
         time = sapply(strsplit(as.character(date_time), " "),tail,1)) %>%
  filter(!X.trk.name %in% "/trk/name",
         !date %in% "2011-05-10") %>%
  arrange(date_time) 
#---------------------------#


#---------------------------#
# redefine observation lat/lons since they're off slightly
# due to NA time errors
#---------------------------#
data = mutate(data,
              date = sapply(strsplit(as.character(date_time), " "),head,1),
              time = sapply(strsplit(as.character(date_time), " "),tail,1))

for(a in 1:dim(data)[1]) {
  y = data_track[data_track$date %in% data$date[a],]
  if(min(abs(difftime(data$date_time[a], y$date_time[!is.na(y$date_time)], units = "mins")))<3) {
    ind = which.min(abs(difftime(data$date_time[a], y$date_time[!is.na(y$date_time)])))
    data$lat[a] = y$lat[!is.na(y$date_time)][ind]
    data$lon[a] = y$lon[!is.na(y$date_time)][ind]
  }
}

data_track = data_track %>% bind_rows(., filter(data, type %in% c("BEGCNT","ENDCNT","COMMENT"))) %>%
  mutate(type = as.character(type),
         type = replace(type, is.na(type),"WAYPNT"))
#---------------------------#


#---------------------------#
# fix transects
#---------------------------#
# transect # 9,10,20,21,32,33,38,39,44,45,48,49 don't exist
# fix error
data_track$source_transect_id[data_track$ID %in% c(446)] = 1
data_track$time[data_track$ID %in% c(482)] = data_track$time[data_track$ID %in% c(1813)]
data_track$lat[data_track$ID %in% c(482)] = data_track$lat[data_track$ID %in% c(1813)]
data_track$lon[data_track$ID %in% c(482)] = data_track$lon[data_track$ID %in% c(1813)]
data_track$comments = as.character(data_track$comments)
data_track$comments[data_track$ID %in% c(482)] = paste("start;  TIME ERROR, Changed from 16:47:45 to match other observers", sep="; ")
data_track = data_track[!data_track$ID %in% c(1861:1864),] # duplicates

# fill in WAYPNT transect #s
data_track$source_transect_id[data_track$ID %in% c(37893:37895,41151:41155)] = 5
data_track$source_transect_id[data_track$ID %in% c(37896:38125)] = 6
data_track$source_transect_id[data_track$ID %in% c(41308:41583, 41599:41789)] = 7
data_track$source_transect_id[data_track$ID %in% c(41803:42141, 42183:42381)] = 8
data_track$source_transect_id[data_track$ID %in% c(43253:43274)] = 11
data_track$source_transect_id[data_track$ID %in% c(43377:43594)] = 12
data_track$source_transect_id[data_track$ID %in% c(43628:43867)] = 13
data_track$source_transect_id[data_track$ID %in% c(43878:44212)] = 14
data_track$source_transect_id[data_track$ID %in% c(44269:44363)] = 15
data_track$source_transect_id[data_track$ID %in% c(44727:45059)] = 16
data_track$source_transect_id[data_track$ID %in% c(45080:45395)] = 17
data_track$source_transect_id[data_track$ID %in% c(45697:46199)] = 18
data_track$source_transect_id[data_track$ID %in% c(46222:46711)] = 19
data_track$source_transect_id[data_track$ID %in% c(47038:47537)] = 22
data_track$source_transect_id[data_track$ID %in% c(47556:48027)] = 23
data_track$source_transect_id[data_track$ID %in% c(48369:48899)] = 24
data_track$source_transect_id[data_track$ID %in% c(48932:49085, 49120:49328)] = 25
data_track$source_transect_id[data_track$ID %in% c(49640:50125)] = 26
data_track$source_transect_id[data_track$ID %in% c(50138:50581)] = 27
data_track$source_transect_id[data_track$ID %in% c(51894:52366)] = 28
data_track$source_transect_id[data_track$ID %in% c(52391:52801)] = 29
data_track$source_transect_id[data_track$ID %in% c(53083:53355)] = 30
data_track$source_transect_id[data_track$ID %in% c(53632:53882)] = 31
data_track$source_transect_id[data_track$ID %in% c(54446:54711, 54741:54864)] = 34
data_track$source_transect_id[data_track$ID %in% c(54896:55164)] = 35
data_track$source_transect_id[data_track$ID %in% c(56322:56626)] = 36
data_track$source_transect_id[data_track$ID %in% c(56635:56924)] = 37
data_track$source_transect_id[data_track$ID %in% c(87441:87864)] = 40
data_track$source_transect_id[data_track$ID %in% c(87883:88166)] = 41
data_track$source_transect_id[data_track$ID %in% c(88565:88950)] = 42
data_track$source_transect_id[data_track$ID %in% c(88967:89401)] = 43
data_track$source_transect_id[data_track$ID %in% c(89701:90119)] = 46 
data_track$source_transect_id[data_track$ID %in% c(90145:90542)] = 47
data_track$source_transect_id[data_track$ID %in% c(90696:91118)] = 50
data_track$source_transect_id[data_track$ID %in% c(91141:91525)] = 51
# several transects seem to have BEG/END points that are further away from other points
# most likely projection shift? eg(22,23,24,28,29,20,34,35,37,42,43,46,47,50,51)

# add missing BEG/END POINTS
# 11
to.add = data_track[data_track$ID %in% c(574),]
to.add$ID = 1889.99
to.add$observers = "MB"
to.add$comments = "ADDED ENDCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
# 15
to.add = data_track[data_track$ID %in% c(726),]
to.add$ID = 1896.89
to.add$observers = "MB"
to.add$comments = "ADDED BEGCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
# 16
to.add = data_track[data_track$ID %in% c(731),]
to.add$ID = 1899.88
to.add$observers = "MB"
to.add$comments = "ADDED ENDCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
# 17
to.add = data_track[data_track$ID %in% c(732),]
to.add$ID = 1899.89
to.add$observers = "MB"
to.add$comments = "ADDED BEGCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
# 18
to.add = data_track[data_track$ID %in% c(756),]
to.add$ID = 1906.88
to.add$observers = "MB"
to.add$comments = "ADDED ENDCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
# 19
to.add = data_track[data_track$ID %in% c(757),]
to.add$ID = 1906.89
to.add$observers = "MB"
to.add$comments = "ADDED BEGCNT based on other observer"
data_track = bind_rows(data_track, to.add)
rm(to.add)
#---------------------------#


#---------------------------#
# duplicate track data so that each has its own effort
#---------------------------#
track_DH = data_track[(data_track$date_time < data_track$date_time[data_track$ID==710] & data_track$date_time > data_track$date_time[data_track$ID==703]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==717] & data_track$date_time > data_track$date_time[data_track$ID==711]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==725] & data_track$date_time > data_track$date_time[data_track$ID==718]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==728] & data_track$date_time > data_track$date_time[data_track$ID==726]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==731] & data_track$date_time > data_track$date_time[data_track$ID==729]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==735] & data_track$date_time > data_track$date_time[data_track$ID==732]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==756] & data_track$date_time > data_track$date_time[data_track$ID==736]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==773] & data_track$date_time > data_track$date_time[data_track$ID==757]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==728] & data_track$date_time > data_track$date_time[data_track$ID==726]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==818] & data_track$date_time > data_track$date_time[data_track$ID==774]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==843] & data_track$date_time > data_track$date_time[data_track$ID==820]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==888] & data_track$date_time > data_track$date_time[data_track$ID==844]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==909] & data_track$date_time > data_track$date_time[data_track$ID==889]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1191] & data_track$date_time > data_track$date_time[data_track$ID==1160]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1213] & data_track$date_time > data_track$date_time[data_track$ID==1193]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1249] & data_track$date_time > data_track$date_time[data_track$ID==1214]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1253] & data_track$date_time > data_track$date_time[data_track$ID==1250]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1255] & data_track$date_time > data_track$date_time[data_track$ID==1254]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1260] & data_track$date_time > data_track$date_time[data_track$ID==1256]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1362] & data_track$date_time > data_track$date_time[data_track$ID==1342]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1373] & data_track$date_time > data_track$date_time[data_track$ID==1363]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1375] & data_track$date_time > data_track$date_time[data_track$ID==1374]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1379] & data_track$date_time > data_track$date_time[data_track$ID==1376]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2714] & data_track$date_time > data_track$date_time[data_track$ID==2706]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2723] & data_track$date_time > data_track$date_time[data_track$ID==2715]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2758] & data_track$date_time > data_track$date_time[data_track$ID==2753]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2771] & data_track$date_time > data_track$date_time[data_track$ID==2759]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2814] & data_track$date_time > data_track$date_time[data_track$ID==2811]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2820] & data_track$date_time > data_track$date_time[data_track$ID==2815]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2929] & data_track$date_time > data_track$date_time[data_track$ID==2925]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2932] & data_track$date_time > data_track$date_time[data_track$ID==2930]),]
track_DH = track_DH %>% filter(!type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT","COMMENT") & observers=="DH")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "DH", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)    
#
track_EH = data_track[(data_track$date_time < data_track$date_time[data_track$ID==558] & data_track$date_time > data_track$date_time[data_track$ID==544]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==564] & data_track$date_time > data_track$date_time[data_track$ID==559]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==566] & data_track$date_time > data_track$date_time[data_track$ID==565]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==568] & data_track$date_time > data_track$date_time[data_track$ID==567]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==570] & data_track$date_time > data_track$date_time[data_track$ID==569]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==572] & data_track$date_time > data_track$date_time[data_track$ID==571]),]
track_EH =track_EH %>% filter(!type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT","COMMENT") & observers=="EH")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "EH", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)   
#
track_MB = data_track[(data_track$date_time < data_track$date_time[data_track$ID==1840.00] & data_track$date_time > data_track$date_time[data_track$ID==1835.00]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1846.00] & data_track$date_time > data_track$date_time[data_track$ID==1841.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1848.00] & data_track$date_time > data_track$date_time[data_track$ID==1847.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1851.00] & data_track$date_time > data_track$date_time[data_track$ID==1849.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1853.00] & data_track$date_time > data_track$date_time[data_track$ID==1852.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1856.00] & data_track$date_time > data_track$date_time[data_track$ID==1854.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1860.00] & data_track$date_time > data_track$date_time[data_track$ID==1857.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1888.00] & data_track$date_time > data_track$date_time[data_track$ID==1865.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1889.99] & data_track$date_time > data_track$date_time[data_track$ID==1889.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1897.00] & data_track$date_time > data_track$date_time[data_track$ID==1896.89]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1899.88] & data_track$date_time > data_track$date_time[data_track$ID==1898.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1903.00] & data_track$date_time > data_track$date_time[data_track$ID==1899.89]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1906.88] & data_track$date_time > data_track$date_time[data_track$ID==1904.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1911.00] & data_track$date_time > data_track$date_time[data_track$ID==1906.89]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1969.00] & data_track$date_time > data_track$date_time[data_track$ID==1963.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1973.00] & data_track$date_time > data_track$date_time[data_track$ID==1970.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1979.00] & data_track$date_time > data_track$date_time[data_track$ID==1974.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1987.00] & data_track$date_time > data_track$date_time[data_track$ID==1980.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==1997.00] & data_track$date_time > data_track$date_time[data_track$ID==1988.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2007.00] & data_track$date_time > data_track$date_time[data_track$ID==1998.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2051.00] & data_track$date_time > data_track$date_time[data_track$ID==2049.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2053.00] & data_track$date_time > data_track$date_time[data_track$ID==2052.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2055.00] & data_track$date_time > data_track$date_time[data_track$ID==2054.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2058.00] & data_track$date_time > data_track$date_time[data_track$ID==2056.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2063.00] & data_track$date_time > data_track$date_time[data_track$ID==2059.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2067.00] & data_track$date_time > data_track$date_time[data_track$ID==2064.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2070.00] & data_track$date_time > data_track$date_time[data_track$ID==2068.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2072.00] & data_track$date_time > data_track$date_time[data_track$ID==2071.00]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2725.00] & data_track$date_time > data_track$date_time[data_track$ID==2724.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2730.00] & data_track$date_time > data_track$date_time[data_track$ID==2726.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2776.00] & data_track$date_time > data_track$date_time[data_track$ID==2772.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2781.00] & data_track$date_time > data_track$date_time[data_track$ID==2777.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2864.00] & data_track$date_time > data_track$date_time[data_track$ID==2854.00]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==2868.00] & data_track$date_time > data_track$date_time[data_track$ID==2865.00]),]
track_MB = track_MB %>% filter(!type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT","COMMENT") & observers=="MB")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "MB", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)   
#
track_MH = data_track[(data_track$date_time < data_track$date_time[data_track$ID==446] & data_track$date_time > data_track$date_time[data_track$ID==417]) | 
                        (data_track$date_time < data_track$date_time[data_track$ID==457] & data_track$date_time > data_track$date_time[data_track$ID==447]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==463] & data_track$date_time > data_track$date_time[data_track$ID==458]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==469] & data_track$date_time > data_track$date_time[data_track$ID==464]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==477] & data_track$date_time > data_track$date_time[data_track$ID==470]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==481] & data_track$date_time > data_track$date_time[data_track$ID==478]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==482] & data_track$date_time > data_track$date_time[data_track$ID==513]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==543] & data_track$date_time > data_track$date_time[data_track$ID==529]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==574] & data_track$date_time > data_track$date_time[data_track$ID==573]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==590] & data_track$date_time > data_track$date_time[data_track$ID==575]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==608] & data_track$date_time > data_track$date_time[data_track$ID==591]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==622] & data_track$date_time > data_track$date_time[data_track$ID==609]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==627] & data_track$date_time > data_track$date_time[data_track$ID==623]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==629] & data_track$date_time > data_track$date_time[data_track$ID==628]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==637] & data_track$date_time > data_track$date_time[data_track$ID==630]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==678] & data_track$date_time > data_track$date_time[data_track$ID==638]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==702] & data_track$date_time > data_track$date_time[data_track$ID==679]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==974] & data_track$date_time > data_track$date_time[data_track$ID==910]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==992] & data_track$date_time > data_track$date_time[data_track$ID==975]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1050] & data_track$date_time > data_track$date_time[data_track$ID==993]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1076] & data_track$date_time > data_track$date_time[data_track$ID==1051]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1131] & data_track$date_time > data_track$date_time[data_track$ID==1077]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1159] & data_track$date_time > data_track$date_time[data_track$ID==1132]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1297] & data_track$date_time > data_track$date_time[data_track$ID==1261]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1326] & data_track$date_time > data_track$date_time[data_track$ID==1298]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1334] & data_track$date_time > data_track$date_time[data_track$ID==1327]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1336] & data_track$date_time > data_track$date_time[data_track$ID==1335]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1341] & data_track$date_time > data_track$date_time[data_track$ID==1337]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1425] & data_track$date_time > data_track$date_time[data_track$ID==1380]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1442] & data_track$date_time > data_track$date_time[data_track$ID==1426]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1445] & data_track$date_time > data_track$date_time[data_track$ID==1443]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==1450] & data_track$date_time > data_track$date_time[data_track$ID==1446]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2700] & data_track$date_time > data_track$date_time[data_track$ID==2686]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2705] & data_track$date_time > data_track$date_time[data_track$ID==2701]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2744] & data_track$date_time > data_track$date_time[data_track$ID==2738]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2752] & data_track$date_time > data_track$date_time[data_track$ID==2745]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2826] & data_track$date_time > data_track$date_time[data_track$ID==2821]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2835] & data_track$date_time > data_track$date_time[data_track$ID==2827]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2941] & data_track$date_time > data_track$date_time[data_track$ID==2933]) |
                        (data_track$date_time < data_track$date_time[data_track$ID==2951] & data_track$date_time > data_track$date_time[data_track$ID==2942]),]
track_MH = track_MH %>% filter(!type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT","COMMENT") & observers=="MH")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "MH", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)   
#
track_RaH = data_track[(data_track$date_time < data_track$date_time[data_track$ID==1793] & data_track$date_time > data_track$date_time[data_track$ID==1789.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1797] & data_track$date_time > data_track$date_time[data_track$ID==1795.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1799] & data_track$date_time > data_track$date_time[data_track$ID==1798.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1801] & data_track$date_time > data_track$date_time[data_track$ID==1800.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1808] & data_track$date_time > data_track$date_time[data_track$ID==1804.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1811] & data_track$date_time > data_track$date_time[data_track$ID==1809.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1827] & data_track$date_time > data_track$date_time[data_track$ID==1814.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1833] & data_track$date_time > data_track$date_time[data_track$ID==1828.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1914] & data_track$date_time > data_track$date_time[data_track$ID==1912.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1920] & data_track$date_time > data_track$date_time[data_track$ID==1915.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1922] & data_track$date_time > data_track$date_time[data_track$ID==1921.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1924] & data_track$date_time > data_track$date_time[data_track$ID==1923.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1926] & data_track$date_time > data_track$date_time[data_track$ID==1925.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1928] & data_track$date_time > data_track$date_time[data_track$ID==1927.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1932] & data_track$date_time > data_track$date_time[data_track$ID==1929.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1934] & data_track$date_time > data_track$date_time[data_track$ID==1933.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1936] & data_track$date_time > data_track$date_time[data_track$ID==1935.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1941] & data_track$date_time > data_track$date_time[data_track$ID==1937.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1949] & data_track$date_time > data_track$date_time[data_track$ID==1942.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1954] & data_track$date_time > data_track$date_time[data_track$ID==1950.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==1962] & data_track$date_time > data_track$date_time[data_track$ID==1955.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2012] & data_track$date_time > data_track$date_time[data_track$ID==2008.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2022] & data_track$date_time > data_track$date_time[data_track$ID==2013.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2045] & data_track$date_time > data_track$date_time[data_track$ID==2022.5]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2033] & data_track$date_time > data_track$date_time[data_track$ID==2027.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2041] & data_track$date_time > data_track$date_time[data_track$ID==2034.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2043] & data_track$date_time > data_track$date_time[data_track$ID==2042.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2048] & data_track$date_time > data_track$date_time[data_track$ID==2046.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2783] & data_track$date_time > data_track$date_time[data_track$ID==2782.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2786] & data_track$date_time > data_track$date_time[data_track$ID==2784.0]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2843] & data_track$date_time > data_track$date_time[data_track$ID==2838.0]),]
track_RaH = track_RaH %>% filter(!type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT","COMMENT") & observers=="RaH")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "RaH", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)   
#
track_RiH = data_track[(data_track$date_time < data_track$date_time[data_track$ID==2077] & data_track$date_time > data_track$date_time[data_track$ID==2073]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2081] & data_track$date_time > data_track$date_time[data_track$ID==2078]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2084] & data_track$date_time > data_track$date_time[data_track$ID==2082]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2087] & data_track$date_time > data_track$date_time[data_track$ID==2085]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2733] & data_track$date_time > data_track$date_time[data_track$ID==2731]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2736] & data_track$date_time > data_track$date_time[data_track$ID==2734]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==2994] & data_track$date_time > data_track$date_time[data_track$ID==2977]) | 
                         (data_track$date_time < data_track$date_time[data_track$ID==3013] & data_track$date_time > data_track$date_time[data_track$ID==2995]),]
track_RiH = track_RiH %>% filter(!type %in% c("BEGCNT","ENDCNT")) %>%
  bind_rows(., filter(data_track, type %in% c("BEGCNT","ENDCNT") & observers=="RiH")) %>% 
  select(ID, lat, lon, date_time, visibility, source_transect_id, type, observers, date, time) %>% 
  mutate(observers = "RiH", source_transect_id = paste(source_transect_id, observers, sep="_")) %>% arrange(date_time)   
track_RiH = track_RiH[!duplicated(track_RiH),]        
# 
# remove old data track file, replace it with a aggregation for each observer
rm(data_track)
data_track = rbind(track_DH, track_EH, track_MB, track_MH, track_RaH, track_RiH)
rm(track_DH, track_EH, track_MB, track_MH, track_RaH, track_RiH)
#
#---------------------------#


#---------------------------#
# format observation data
#---------------------------#
data = filter(data, !type %in% c("BEGCNT","ENDCNT","COMMENT")) %>%
  mutate(date = sapply(strsplit(as.character(date_time), " "),head,1),
         time = sapply(strsplit(as.character(date_time), " "),tail,1),
         source_transect_id = paste(source_transect_id, observers, sep="_"),
         source_transect_id = replace(source_transect_id, offline==1, NA)) %>%
  arrange(source_transect_id, date_time)
#---------------------------#


#---------------------------#
# fromat transects from track
#---------------------------#
# average condition is weighted by distance flown at each observation condition
# distance flown per transect is in nautical miles, distance between points in meters 
break.at.each.stop = filter(data_track, type %in% c("BEGCNT")) %>%
  group_by(source_transect_id) %>% mutate(start.stop.index = seq(1:n())) %>% ungroup() %>% 
  select(source_transect_id, ID, start.stop.index)
new.key = left_join(data_track, break.at.each.stop, by=c("ID","source_transect_id")) %>% 
  mutate(start.stop.index = na.locf(start.stop.index), 
         newkey = paste(source_transect_id, start.stop.index, sep="_")) %>% select(-start.stop.index)

# grouped by new key to avoid counting time and distance traveled between breaks
df = new.key %>% group_by(newkey)  %>% 
  mutate(lagged.lon = lead(lon, default = last(lon), order_by = ID),
         lagged.lat = lead(lat, default = last(lat), order_by = ID)) %>%
  rowwise() %>% mutate(distance = distVincentySphere(c(lon, lat), c(lagged.lon, lagged.lat))) %>%
  select(-lagged.lon, -lagged.lat) %>% 
  group_by(newkey) %>%  
  summarise(observer = first(observers),
            source_transect_id = first(source_transect_id),
            transect_distance_nb = sum(distance, na.rm=TRUE),
            temp_start_lon = first(lon),
            temp_stop_lon = last(lon),
            temp_start_lat = first(lat),
            temp_stop_lat = last(lat),
            start_dt = as.character(first(date)),
            end_dt = as.character(last(date)),
            start_tm = first(time), 
            end_tm  = last(time),
            transect_time_min_nb = difftime(first(date_time), last(date_time), units="mins"))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id)
#
transectTbl = df %>% 
  group_by(source_transect_id)  %>% 
  arrange(start_tm) %>% 
  summarise(observer = first(observer),
            temp_start_lon = first(temp_start_lon),
            temp_stop_lon = last(temp_stop_lon),
            temp_start_lat = first(temp_start_lat),
            temp_stop_lat = last(temp_stop_lat),
            start_dt = as.character(first(start_dt)),
            end_dt = as.character(last(end_dt)),
            start_tm = first(start_tm), 
            end_tm  = last(end_tm),
            transect_time_min_nb = sum(transect_time_min_nb),
            transect_distance_nb = sum(transect_distance_nb))  %>%
  ungroup() %>% as.data.frame %>% arrange(start_dt, source_transect_id) %>%
  mutate(transect_distance_nb = replace(transect_distance_nb,transect_distance_nb==0,NA)) %>%
  filter(!source_transect_id %in% c("NA_RiH", "NA_DH", "NA_EH", "NA_MB", "NA_MH", "NA_RaH"))
rm(df, new.key, break.at.each.stop)
#---------------------------#
