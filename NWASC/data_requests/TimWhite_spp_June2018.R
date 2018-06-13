# -------------- #
# all species codes with common names requested
# June 13, 2018
# -------------- #

# -------------- #
# Packages
# -------------- #
require(odbc)
require(dplyr)
# -------------- #

# -------------- #
# Data
# -------------- #
db <- dbConnect(odbc::odbc(), driver='SQL Server', server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species") %>%
  dplyr::select(-order,-family,-subfamily) #not filled in yet
# -------------- #


# -------------- #
# export
# -------------- #
write.csv(spplist, "Z:/seabird_database/data_sent/TimWhite_spp_June2018/species_codes.csv")
# -------------- #
