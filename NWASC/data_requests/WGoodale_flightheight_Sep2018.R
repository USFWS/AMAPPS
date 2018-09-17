# -------------- #
# packages
# -------------- #
require(RODBC)
require(odbc)
require(dplyr)
# -------------- #


# -------------- #
# data
# -------------- #
# old data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
old.obs = dbGetQuery(db,"select geography.Lat as latitude, geography.Long as longitude, *
                     from observation where flight_height_tx is not null")
dbDisconnect(db)

# new data 
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
new.obs <- sqlQuery(db, "select * from observation where flight_height_tx is not null")
odbcClose(db)
# -------------- #


# -------------- #
# format and join
# -------------- #
# -------------- #
