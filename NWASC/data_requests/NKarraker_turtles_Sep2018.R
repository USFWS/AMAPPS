# --------------- #
# all seaturtles 
#
# date: Oct. 2018
# written by: K. Coleman
# --------------- #

# -------------- #
# load packages
# -------------- #
library(odbc)
library(RODBC)
library(sp)
library(dplyr)
require(ggplot2)
# -------------- #


# -------------- #
# load data
# -------------- #
# get species list
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spp = dbGetQuery(db, "select * from lu_species where species_type_id = 3")

# old data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select * from observation where spp_cd in ('GRTU','HATU','KRST','LETU','LOTU','SMTU','TURT','UNCH')")

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlQuery(db, "select * from observation where spp_cd in ('GRTU','HATU','KRST','LETU','LOTU','SMTU','TURT','UNCH')")
odbcClose(db)

obs = obs %>% mutate(observation_id = observation_id + 804175) %>%
  dplyr::select(observation_id, spp_cd)

# combine old and new
# creat month column
obs = bind_rows(old_obs,obs)

# ------------ # 
# effort
ids = sort(unique(obs$dataset_id))
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
effort = dbGetQuery(db, "select * from all_effort where dataset_id in ('7','8','12','15','22','23','30','31','33',
'39','42','71','76','77','78','80','84','85','90','99','111','112','113','114','115','117','118',
'122','124','127','129','130','132','135','137','138','139','140','141','142','143','144','146',
'148','151','152','153','154','158','161','162','164','165','168','173','178','179','181','183','226',
'242','395','398','399','400','401','402')")
datasets = dbGetQuery(db, "select * from dataset where dataset_id in ('7','8','12','15','22','23','30','31','33',
'39','42','71','76','77','78','80','84','85','90','99','111','112','113','114','115','117','118',
'122','124','127','129','130','132','135','137','138','139','140','141','142','143','144','146',
'148','151','152','153','154','158','161','162','164','165','168','173','178','179','181','183','226',
'242','395','398','399','400','401','402')")
odbcClose(db)

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
transects <- sqlQuery(db, "select * from transect")
odbcClose(db)
transects = filter(transects, dataset_id %in% ids)

# fortmat
source("//ifw-hqfs1/MB SeaDuck/seabird_database/Rfunctions/transformDatasets.R")
datasets=transformDataset(datasets)
datasets$platform_name_id[datasets$platform_name_id %in% 26]='R/V Auk'
#datasets$survey_method_cd[datasets$dataset_id %in% c(178,179,181)]="continuous time strip" #need to fix

# export
write.csv(datasets,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/datasets.csv",row.names = F)
write.csv(obs,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/observations.csv",row.names = F)
write.csv(effort,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/effort.csv",row.names = F)
write.csv(transects,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/newTransects.csv",row.names = F)

# export sans 1 
sl1 = ids[datasets$share_level_id %in% 1]
datasets1 = filter(datasets, !dataset_id %in% sl1)
obs1 = filter(obs, !dataset_id %in% sl1)
effort1 = filter(effort, !dataset_id %in% sl1)
transects1 = filter(transects, !dataset_id %in% sl1)

write.csv(datasets1,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/datasets_without_shareLevel1.csv",row.names = F)
write.csv(obs1,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/observations_without_shareLevel1.csv",row.names = F)
write.csv(effort1,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/effort_without_shareLevel1.csv",row.names = F)
write.csv(transects1,"//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/NKarraker_turtles_Sep2018/newTransects_without_shareLevel1.csv",row.names = F)






