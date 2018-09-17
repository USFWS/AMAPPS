# --------------- #
# look at what landbirds are in the database
#
# date: Jan. 2018
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
dat = bind_rows(old_obs,obs)
