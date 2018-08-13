# -------------------------------- #
# QA/QC NYSERDA
#
# dataset names
#   "NYSERDA_OPA_Survey1_Summer 2016" 
#   "NYSERDA_OPA_Survey2_Fall 2016"   
#   "NYSERDA_OPA_Survey3_Winter 2017"
#   "NYSERDA_OPA_Survey4_Spring 2017" 
#   "NYSERDA_WEA_Survey1_Summer 2016" 
#   "NYSERDA_WEA_Survey2_Fall 2016"  
#   "NYSERDA_WEA_Survey3_Winter 2017" 
#   "NYSERDA_WEA_Survey4_Spring 2017"
# -------------------------------- #


# -------------------------------- #
# load packages
# -------------------------------- #
require(RODBC) # odbcConnect
require(odbc)
require(rgdal) # read shapefiles
require(dplyr)
library(readxl)
require(ggplot2)
# -------------------------------- #


# -------------------------------- #
# define paths
# -------------------------------- #
surveyFolder = "NYSERDA"

# SET INPUT/OUTPUT DIRECTORY PATHS
dir <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received"
setwd(dir)
dir.in <- paste(dir, surveyFolder, sep = "/") 
dir.out <- paste(gsub("datasets_received", "data_import/in_progress", dir), surveyFolder,  sep = "/") 
dir.gis <- paste(dir.in, "NYSERDA YR1 shps", sep="/")
# -------------------------------- #


# -------------------------------- #
# load data 
# -------------------------------- #
data = read_excel(paste(dir.in,"Submit NWASC - NYSERDA Year1 - TargetObs.xlsx",sep="/"))

# filter to polylines for transect lines (polgons are camera space, TargetObs are observations)
OPA_Effort = readOGR(dir.gis,"NYSERDA_YR1_OPA_Effort_polyline")
WEA_Effort = readOGR(dir.gis,"NYSERDA_YR1_WEA_Effort_polyline")
# both are formatted as
# ..@ data       
#   .. ..$ TransectID: Factor
# .. ..$ TransectNo: num 
# .. ..$ Survey    : Factor w/ 4 levels "NYSERDA_OPA_Survey1_Summer 2016"
# .. ..$ DateTaken : Factor w/ 37 levels "2016/07/26"
# .. ..$ START_X   : num [1:190] -73.5 
# .. ..$ START_Y   : num [1:190] 39.3 
# .. ..$ END_X     : num [1:190] -73.8 
# .. ..$ END_Y     : num [1:190] 40.3 
# -------------------------------- #


# -------------------------------- #
# # reformat 
# -------------------------------- #
OPA_effort_tbl = as.data.frame(OPA_Effort)
WEA_effort_tbl = as.data.frame(WEA_Effort)

# add dataset ID numbers for easier sorting and joining
#  173, 'NYSERDA_OPA_Survey1_Summer 2016'
#  398, 'NYSERDA_OPA_Survey2_Fall 2016'
#  399, 'NYSERDA_OPA_Survey3_Winter 2017'
#  400, 'NYSERDA_OPA_Survey4_Spring 2017'
OPA_effort_tbl = OPA_effort_tbl %>% mutate(dataset_id = NA,
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey1_Summer 2016", 173),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey2_Fall 2016", 398),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey3_Winter 2017", 399),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey4_Spring 2017", 400))

#  401, 'NYSERDA_WEA_Survey1_Summer 2016'
#  402, 'NYSERDA_WEA_Survey2_Fall 2016'
#  403, 'NYSERDA_WEA_Survey3_Winter 2017'
#  404, 'NYSERDA_WEA_Survey4_Spring 2017'
WEA_effort_tbl = WEA_effort_tbl %>% mutate(dataset_id = NA,
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey1_Summer 2016", 401),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey2_Fall 2016", 402),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey3_Winter 2017", 403),
                                           dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey4_Spring 2017", 404))

data = data %>% mutate(dataset_id = NA,
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey1_Summer 2016", 173),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey2_Fall 2016", 398),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey3_Winter 2017", 399),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_OPA_Survey4_Spring 2017", 400),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey1_Summer 2016", 401),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey2_Fall 2016", 402),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey3_Winter 2017", 403),
                       dataset_id = replace(dataset_id, Survey %in% "NYSERDA_WEA_Survey4_Spring 2017", 404),
                       Time = sapply(strsplit(as.character(Time), " "),tail,1))
# -------------------------------- #


# -------------------------------- #
# validate species
# -------------------------------- #
#db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
#spplist <- sqlFetch(db, "lu_species")
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
spplist <- dbGetQuery(db, "select * from lu_species")
odbcClose(db)

data$spp_cd[data$original_species_tx %in% "Common/White-sided Dolphin"] = "UNDO"              
data$spp_cd[data$original_species_tx %in% "Cownose/Bullnose Ray"] = "UNRA"   
data$spp_cd[data$original_species_tx %in% c("Other","needs id")] = "UNKN"    
data$spp_cd[data$original_species_tx %in% "Sunfish-species unknown"] = "MOLA" #only one in Atlantic  
data$spp_cd[data$original_species_tx %in% "Party boat"] = "BOAT"  
data$spp_cd[data$original_species_tx %in% "Unid. schooling pelagic-species unknown"] = "FISH" 
data$spp_cd[data$original_species_tx %in% "Thresher Shark"] = "UNTS"                          
data$spp_cd[data$original_species_tx %in% "Bluntnose Stingray"] = "BLST"
data$spp_cd[data$original_species_tx %in% "Cobia"] = "COBI"                                  
data$spp_cd[data$original_species_tx %in% "Dusky Shark"] = "DUSH"                             
data$spp_cd[data$original_species_tx %in% "Great Hammerhead"] = "GHSH"                       
data$spp_cd[data$original_species_tx %in% "Sharptail Sunfish"] = "SHSU"                      
data$spp_cd[data$original_species_tx %in% "Shortfin Mako"] = "SMSH"                          
data$spp_cd[data$original_species_tx %in% "Smooth Hammerhead"] = "SHSH"    
data$spp_cd[data$original_species_tx %in% "Spiny Dogfish (Spurdog)"] = "SPDF"  
data$spp_cd[data$original_species_tx %in% "Tiger Shark"] = "TISH"                           
data$spp_cd[data$original_species_tx %in% "Whale Shark"] = "WHSH"       

# added to db
#(4,'BLST','Bluntnose Stingray',NULL,'Dasyatis','say',160954,NULL),
#(4,'COBI','Cobia',NULL,'Rachycentron','canadum',168566,NULL),
#(4,'DUSH','Dusky Shark',NULL,'Carcharhinus','obscurus',160268,NULL),
#(4,'GHSH','Great Hammerhead Shark',NULL,'Sphyrna','mokarran',160515,NULL),
#(4,'SHSU','Sharptail Sunfish',NULL,'Masturus','lanceolatus',173419,NULL), 
#(4,'SMSH','Shortfin Mako Shark',NULL,'Isurus','oxyrinchus',159924,NULL),
#(4,'SHSH','Smooth Hammerhead shark',NULL,'Sphyrna','zygaena',160505,NULL),
#(4,'SPDF','Spiny dogfish (Spurdog, Grayfish, piked dogfish)',NULL,'Squalus','acanthias',160617,NULL),
#(4,'TISH','Tiger shark',NULL,'Galeocerdo','cuvier',160189,NULL),
#(4,'WHSH','Whale shark',NULL,'Rhincodon','typus',159857,NULL),
# -------------------------------- #


# -------------------------------- #
# plots
# -------------------------------- #
ggplot(data[data$dataset_name %in% "NYSERDA_OPA_Survey1_Summer 2016",], aes(Longitude, Latitude,col=as.character(TransectNo)))+geom_point()+theme_bw()

ggplot(data[data$dataset_name %in% "NYSERDA_WEA_Survey1_Summer 2016",], aes(Longitude, Latitude,col=as.character(TransectNo)))+geom_point()+theme_bw()
# -------------------------------- #

