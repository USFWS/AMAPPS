# -------------- #
# load packages
# -------------- #
library(odbc)
library(RODBC)
library(dplyr)
# -------------- #

db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spp = dbGetQuery(db, "select * from lu_species")


spp_tb = spp
spp_tb = mutate(spp_tb, 
                spp_cd = replace(spp_cd, is.na(spp_cd),"--"),
                group = replace(group, is.na(group),"--"),
                common_name = replace(common_name, is.na(common_name),"--"),
                genus = replace(genus, is.na(genus),"--"),
                species = replace(species, is.na(species),"--"),
                ITIS_id = replace(ITIS_id, is.na(ITIS_id),"--"),
                new = paste(spp_cd,group,common_name,genus,species,ITIS_id, sep = "|"))


x = filter(spp_tb, species_type_id %in% 1) %>% dplyr::select(new)
write.csv(x,file="C:/Users/kecoleman/Downloads/x.csv",row.names=FALSE)

# create x for each species type
# copy and paste into each species type in the github page
# https://github.com/USFWS/AMAPPS/edit/master/NWASC/Species_Codes.md


