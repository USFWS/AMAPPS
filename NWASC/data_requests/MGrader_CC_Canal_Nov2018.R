#41.735597, -70.612283, with a 1.5 km radius

# ------------------ # 
# load packages
# ------------------ # 
require(dplyr)
require(ggplot2)
require(maps)
library(sp)
library(rgeos)
library(rgdal)
require(RODBC)
require(odbc)
require(ggmap)
require(lubridate)
library(readr)
# ------------------ # 

# ------------- #
# create poly
# ------------- #
w = as.data.frame(matrix(nrow=1,ncol=2,data=c(-70.612283, 41.735597)))
names(w) = c("lon","lat")
coordinates(w) = ~lon+lat
proj4string(w) = CRS("+proj=longlat") 
#w = spTransform(w, CRS("+proj=utm +zone=19 +ellps=WGS84 +datum=WGS84 +units=m +no_defs +towgs84=0,0,0"))
w = spTransform(w, CRS("+proj=longlat +init=epsg:4326"))

cc_1.5km_buffer <- gBuffer(w, width = 1.5, byid = TRUE ) 
cc_1.5km_buffer = spTransform(cc_1.5km_buffer, CRS("+proj=longlat +init=epsg:4326"))

# plot
ww = as.data.frame(w)

# get map https://www.rdocumentation.org/packages/ggmap/versions/2.6.1/topics/get_map
bc_bbox <- make_bbox(lat = c(40.2, 43.5), lon = c(-72.5, -69))
cc <- get_map(location = bc_bbox, 
              source = "google", 
              maptype = "watercolor")

ggmap(cc) + coord_fixed(1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "magenta") +
  geom_polygon(data = cc_1.5km_buffer, aes(x = long, y= lat),fill="white",alpha=0.2,col="black") +
  theme_bw() + ggtitle("1.5 km buffer")
# ------------- #


# ------------------ #
# load data
# ------------------ #
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
datasets = dbGetQuery(db, "select * from dataset")
spp = dbGetQuery(db, "select * from lu_species")
#obs = dbGetQuery(db, "select * from observations")
dbDisconnect(db)

# obs data (temp)
obs <- read_csv("Z:/seabird_database/data_sent/TWhite_archive_Oct2018/obs_Oct2018.csv")
# ------------------ #

# ------------------ #
# subset data
# ------------------ #

# make spatial
all_data = left_join(obs,dplyr::select(spp,spp_cd,species_type_id,common_name,genus,species),by="spp_cd") %>% 
                       filter(!is.na(longitude), !is.na(latitude), species_type_id %in% 1)
coordinates(all_data) = ~longitude+latitude
proj4string(all_data) <- CRS("+proj=longlat +init=epsg:4326")

# pull whats in the bounding box
x = sp::over(all_data, cc_1.5km_buffer)
cc.data = as.data.frame(all_data[!is.na(x),])
nodata = as.data.frame(all_data[is.na(x),])

cc.data = as.data.frame(cc.data)
ggmap(cc) + coord_fixed(1.3) + 
  geom_point(data = ww, aes(x=lon,y=lat), col = "magenta") +
  geom_polygon(data = cc_1.5km_buffer, aes(x = long, y= lat),fill="white",alpha=0.2,col="black") +
  theme_bw() + ggtitle("Observations within a 1.5 km buffer") +
  geom_point(data = cc.data, aes(x=longitude ,y=latitude, col = spp_cd))

# filter out share level 1

# filter datasets
cc.datasets = filter(datasets, dataset_id %in% cc.data$dataset_id)

# export
write.csv(cc.data,"Z:/seabird_database/data_sent/MGrader_CC_Canal_Nov2018/observations.csv")
write.csv(cc.datasets,"Z:/seabird_database/data_sent/MGrader_CC_Canal_Nov2018/datasets.csv")
# ------------- #


