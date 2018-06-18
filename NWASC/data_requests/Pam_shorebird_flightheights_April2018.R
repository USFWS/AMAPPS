#-------------------- #
# Pam, looking for flight heights of shorebirds
# created April 2018
# edited June 2018 for updated request of figure
# ------------------- #

# ------------------------ #
# load packages
# ------------------------ #
library(RODBC)
require(odbc)
library(dplyr)
require(ggplot2)
require(rgdal)
require(ggmap)
# ------------------------ #


# ------------------------ #
# directory for export
# ------------------------ #
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/Pam_shorebird_flightheight_2018"
# ------------------------ #

# ------------------------ #
# load data
# ------------------------ #
# get dataset list
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
dataset = dbGetQuery(db, "select * from dataset")
spp = dbGetQuery(db, "select * from lu_species")

# get old data
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008',database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select [Geometry].STY as lat, [Geometry].STX as lon, * from observation
                     where spp_cd in ('BBPL','DUNL','LESA','PEEP','PIPL','REKN','RUTU','SAND',
                     'SEPL','SESA','SHOR','UNCA','USAN','USSB','WRSA')")

# # list
# BBPL - black bellied plover
# DUNL - dunlin
# LESA -	Least Sandpiper
# PEEP -	Unidentified peep
# PIPL - Piping Plover
# REKN -	Red Knot
# RUTU -	Ruddy Turnstone
# SAND -	Sanderling
# SEPL -	Semipalmated Plover	
# SESA -	Semipalmated Sandpiper
# SHOR -	Unidentified shorebird
# UNCA -	Unidentified Calidris (Sandpiper, Sanderling, Dunlin, Red Knot)	
# USAN -	Unidentified Sandpiper
# USSB -	Unidentified small shorebird
# WRSA -	White-rumped Sandpiper



old_obs = old_obs %>% 
  mutate(obs_dt = as.character(as.Date(obs_dt, format = "%Y-%m-%d"))) %>%
  dplyr::select(-Geometry)
coordinates(old_obs) <- ~ lon + lat
proj4string(old_obs) <- CRS("+init=epsg:4269")
old_obs = as.data.frame(spTransform(old_obs, CRS("+init=epsg:4326 +proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")))

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlQuery(db, "select * from observation
                where spp_cd in ('BBPL','DUNL','LESA','PEEP','PIPL','REKN','RUTU','SAND',
                'SEPL','SESA','SHOR','UNCA','USAN','USSB','WRSA')")
odbcClose(db)

obs = dplyr::rename(obs, lat = temp_lat, lon = temp_lon) %>% 
  mutate(observation_id = observation_id + 804175,
         obs_count_general_nb = replace(obs_count_general_nb, obs_count_general_nb==obs_count_intrans_nb, NA),
         obs_dt = ifelse(grepl("/",obs$obs_dt), as.character(as.Date(obs$obs_dt[grepl("/",obs$obs_dt)], format = "%m/%d/%Y")), 
                         as.character(as.Date(obs$obs_dt[grepl("-",obs$obs_dt)], format = "%Y-%m-%d"))))

# combine old and new
# create month and filter to Jan. + Feb.
obs = mutate(obs, source_obs_id = as.character(source_obs_id),
             source_transect_id = as.character(source_transect_id),
             travel_direction_tx = as.character(travel_direction_tx),
             visibility_tx = as.character(visibility_tx),
             wind_speed_tx = as.character(wind_speed_tx),
             wind_dir_tx = as.character(wind_dir_tx),
             heading_tx = as.character(heading_tx),
             obs_dt = as.Date(obs_dt,format="%Y-%m-%d"))

old_obs = old_obs %>% 
  mutate(obs_dt = as.Date(obs_dt,format="%Y-%m-%d"),
         source_obs_id = as.character(source_obs_id))

all_dat = bind_rows(old_obs, obs) %>% 
  dplyr::select(observation_id, spp_cd, original_species_tx, 
                lat, lon, obs_dt, 
                dataset_id, comments_tx,
                obs_count_intrans_nb, obs_count_general_nb,
                flight_height_tx) %>%
  filter(!is.na(flight_height_tx))


# dataset info
dataset = filter(dataset, dataset_id %in% unique(all_dat$dataset_id))

# export
write.csv(all_dat, file = paste(dir.out, "shorebird_flightheights.csv",sep="/"))
write.csv(dataset, file = paste(dir.out, "shorebird_flightheight_datasets.csv",sep="/"))

# format
all_dat = all_dat %>% mutate(fh=flight_height_tx,
                             fh = gsub("[^0-9.]", "", fh))
all_dat$fh[grep("-",all_dat$flight_height_tx)] = apply(cbind(as.numeric(gsub("[^0-9.]", "", sapply(strsplit(all_dat$flight_height_tx[grep("-",all_dat$flight_height_tx)], "-"),head, 1))),
                                                             as.numeric(gsub("[^0-9.]", "", sapply(strsplit(all_dat$flight_height_tx[grep("-",all_dat$flight_height_tx)], "-"),tail, 1)))),1,mean)
all_dat$sd = NA
all_dat$sd[grep("-",all_dat$flight_height_tx)] = apply(cbind(as.numeric(gsub("[^0-9.]", "", sapply(strsplit(all_dat$flight_height_tx[grep("-",all_dat$flight_height_tx)], "-"),head, 1))),
                                                             as.numeric(gsub("[^0-9.]", "", sapply(strsplit(all_dat$flight_height_tx[grep("-",all_dat$flight_height_tx)], "-"),tail, 1)))),1,sd)

all_dat = all_dat %>% mutate(fh = as.numeric(fh)) %>% filter(!is.na(fh)) %>% 
  left_join(., dplyr::select(dataset, dataset_id, dataset_name,survey_type_cd), by = "dataset_id") %>% 
  mutate(survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "a", "airplane"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "b", "boat"),
         survey_type_cd = replace(survey_type_cd, survey_type_cd %in% "c", "camera")) %>%
  left_join(.,dplyr::select(spp,spp_cd, common_name), by="spp_cd") %>% 
  mutate(common_name = replace(common_name, is.na(common_name),"Unidentified shorebird"))
  
# plot
p=ggplot(all_dat, aes(reorder(common_name,fh), fh, 
                    col=as.character(dataset_name),
                    shape=survey_type_cd, 
                    stroke=2))+
  geom_jitter(width = 0.25)+
  geom_errorbar(aes(ymin=fh-sd, ymax=fh+sd), width=.5)+
  coord_flip()+
  theme_bw()+ 
  xlab("Species")+
  ylab("Flight Height in meters")+
  guides(col=guide_legend("Dataset Name"),
         shape=guide_legend("Platform"))+
  ggtitle("Flight Heights in the Northwest Atlantic Seabird Catalog")
p
ggsave(file = paste(dir.out, "flight_heights.png",sep="/"),plot=p)  

# give.n <- function(x){
#   return(c(y = -15, label = length(x)))
# }
# library(grid)
# test=grobTree(textGrob("n=",x=rep(-20,12),y=unique(all_dat$common_name)))
# z=as.factor(sort(unique(all_dat$common_name)))
all_dat = mutate(all_dat, n = 1,
                 n = ifelse(common_name %in% "Black-bellied Plover",7,n),
                 n = ifelse(common_name %in% "Dunlin",14,n),
                 n = ifelse(common_name %in% "Least Sandpiper",27,n),
                 n = ifelse(common_name %in% "Unidentified shorebird",75,n),
                 n = ifelse(common_name %in% "Ruddy Turnstone",4,n),
                 n = ifelse(common_name %in% "Sanderling",39,n),
                 n = ifelse(common_name %in% "Semipalmated Plover",9,n),
                 n = ifelse(common_name %in% "Semipalmated Sandpiper",23,n),
                 n = ifelse(common_name %in% "Unidentified Sandpiper",4,n),
                 n = ifelse(common_name %in% "Unidentified small shorebird",29,n),
                 new_common = paste(common_name, "(n=", n, ")", sep=" "))

p=ggplot(all_dat, aes(reorder(new_common,fh), fh, fill=common_name))+
  geom_boxplot()+
  coord_flip()+
  theme_bw()+ 
  xlab("Species")+
  ylab("Flight Height in meters")+
  ggtitle("Flight Heights in the Northwest Atlantic Seabird Catalog")+
  theme(legend.position = "none",
        text = element_text(size=20))#+ 
  #stat_summary(fun.data = give.n, geom = "text", 
  #             position = position_dodge(width = 0.75))#+
  #annotate_custom(test)+
  #annotate("text",x=rep(-20,12),y=z,label=rep("n=",12))
 # text(data = all_dat, aes(common_name, yy), 
  #     row.names(n), cex=0.6, pos=4, col="red")
p
ggsave(file = paste(dir.out, "flight_heights_boxplot.png",sep="/"),plot=p)  
