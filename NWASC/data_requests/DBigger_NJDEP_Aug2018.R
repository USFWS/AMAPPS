# -------------- #
# query for D. Bigger to check if aerial NJDEP is in the db (https://www.nj.gov/dep/dsr/ocean-wind/report.htm)
# if so, then we should split this out from the boat surveys
# -------------- #

# -------------- #
# packages
# -------------- #
require(odbc)
require(RODBC)
require(dplyr)
require(rgdal)
# -------------- #

# -------------- #
# data
# -------------- #
# in database
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
dates <- dbGetQuery(db, "select distinct obs_dt, platform_tx from observation where dataset_id = 91")

db <- odbcDriverConnect('driver={SQL Server}; server=ifw-dbcsqlcl1.fws.doi.net; database=NWASC; trusted_connection=true')
ds <- sqlQuery(db, "select * from dataset where dataset_id = 91")
ppl <- sqlQuery(db, "select * from lu_people where user_id = 56")

# raw data
fgdb <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/NewJerseyDEP/GIS/Layers/NJDEP Layers.gdb"

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)
print(fc_list)
# -------------- #

# -------------- #
# mutate
# -------------- #
dates = dates %>% mutate(obs_dt = as.Date(obs_dt, format = "%Y-%m-%d"),
                         year = format(obs_dt, "%Y"),
                         month = format(obs_dt, "%m")) %>%
  arrange(obs_dt) %>%
  filter(year %in% "2008", month %in% "04")
# -------------- #
