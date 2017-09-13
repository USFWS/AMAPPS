# ------------------------# 
# change names
#names(obs)[names(obs) == "__in_Flock"] <- "count"
names(obs)[names(obs) == "Flock_COR"] <- "count"
obs$original_species_tx = obs$type
obs$type = toupper(obs$type)
# ------------------------# 


# ------------------------# 
# Fix flock count
names(obs)[names(obs) == "__in_Flock"] <- "in_flock"
obs$dataChange = ""
obs$dataChange[is.na(obs$count)] = paste("Changed COUNT from ",obs$count[is.na(obs$count)])
obs$dataChange[obs$count==0] = paste("Changed COUNT from 0")
obs$count[is.na(obs$count)] = obs$in_flock[is.na(obs$count)]
obs$count[obs$count==0] = obs$in_flock[obs$count==0]
obs$count[obs$count=="500+"] = 500
obs$count[obs$in_flock %in% "HERG"] = 10
obs$type[obs$in_flock %in% "HERG"] = "HERG"
obs$count[obs$count=="?"] = NA
# ------------------------# 


# ------------------------# 
# convert units to latlong
#utm_zone = "19T"
obs$Northing = as.numeric(as.character(obs$Northing))
obs$Northing[obs$Northing==0]=NA
obs$Easting = as.numeric(as.character(obs$Easting))
obs$Easting[obs$Easting==0]=NA

# prepare UTM coordinates matrix (rgdal)
utms = cbind(obs$Easting,obs$Northing)
utms = utms[!is.na(utms[,1]),] # will not work with NA's
utmcoor<-SpatialPoints(utms, proj4string=CRS("+proj=utm +zone=19T"))
#utmdata$X and utmdata$Y are corresponding to UTM Easting and Northing, respectively. zone= UTM zone
# converting
longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat +datum=WGS84"))
longlatcoor = as.data.frame(longlatcoor)
colnames(longlatcoor) = c("lon","lat")

tmp = obs[!is.na(obs$Northing),]
tmp2 = obs[is.na(obs$Northing),]
tmp2$lat=""
tmp2$lon=""
obs = rbind(cbind(tmp,longlatcoor),tmp2)
rm(tmp,tmp2,longlatcoor,utms,utmcoor)
colnames(obs) = tolower(colnames(obs))
obs$behavior=gsub("\\s", "", obs$behavior)
# ------------------------# 


# ------------------------# 
# SPECIES
obs$type[obs$type=="ATLANTICWHITE-SIDEDDOLPHIN"] = "WSDO"
obs$type[obs$type %in% c("UNMG","UNIDENTIFIEDMERG")] = "UNME"
obs$type[obs$type=="DEADCOEI"] = "COEI"
obs$type[obs$type=="DEADGULL"] = "UNGU"
obs$type[obs$type=="DEADFLOATINGALCID"] = "UNAL"
obs$type[obs$type=="FINWHALE"] = "FIWH"
obs$type[obs$type=="HARBORPORPOISE"] = "HAPO"
obs$type[obs$type=="HARBORSEAL"] = "HASE"
obs$type[obs$type=="HUMPBACKWHALE"] = "HUWH"
obs$type[obs$type=="MINKEWHALE"] = "MIWH"
obs$type[obs$type=="MONARCHBUTTERFLY"] = "MONA"
obs$type[obs$type %in% c("UN-IDSHARK","UN-IDSHARK")] = "SHAR"
obs$type[obs$type=="UNIDDOLPHIN"] = "UNDO"
obs$type[obs$type=="LARGEWHALE"] = "UNLW"
obs$type[obs$type %in% c("UNIDWHALE","WHALE")]="UNWH"
obs$type[obs$type %in% c("POSSIBLEBAT")] = "UBAT"
obs$type[obs$type %in% c("GULLSP","GULLUKNOWN","GULL","UGU")] = "UNGU"
obs$type[obs$type %in% c("NORTHBFULMAR","FULMARNORTH","NOFULMAR","NORTHERNFULMAR","NNOFU")] = "NOFU"    
obs$type[obs$type %in% c("MANXSHEAR")] = "MASH"
obs$type[obs$type %in% c("SHEARWTERLIKE", "SHEARWATER","SHEARWATERLIKE", "SHEARWATERLIKEBIRD")] = "UNSH" 
obs$type[obs$type %in% c("PETREL")] = "UNPE"
obs$type[obs$type %in% c("UNIDPHALAROPE", "PHALAROPE")] = "UNPH"
obs$type[obs$type %in% c("WHITEFACESTORMPETRELPOSSIBLE", "WFPETREL","WFSTROMPET","POSSIBLEWHITEFACESTORMPETREL")] = "WFSP"
obs$type[obs$type %in% c("UNIDSANDPIPER", "UNIDSANDPIPERS")] = "USAN"
obs$type[obs$type %in% c("UNIDSHOREBIRD")] = "SHOR"
obs$type[obs$type %in% c("UNKNOWN")] = "UNKN"
obs$type[obs$type %in% c("COMLOON")] = "COLO"
obs$type[obs$type %in% c("GREATSHEAR","GREATSHEARWATER","GRSHEAR","GREATSHER","GRSHEARWATER","GRETSHEAR","GRSW")] = "GRSH"
obs$type[obs$type %in% c("BONAGULL")] = "BOGU"
obs$type[obs$type %in% c("BLSCOTER")] = "BLSC"
obs$type[obs$type %in% c("DOVKIE")] = "DOVE"
obs$type[obs$type %in% c("GBBY","GBG","GGBBG","GBBT")] = "GBBG"      
obs$type[obs$type %in% c("HEGU")] = "HERG"      
obs$type[obs$type %in% c("PUFF")] = "ATPU"      

# guesses since contact listed with data no longer available
obs$type[obs$type=="BLDU"] = "ABDU"
obs$type[obs$type=="CAGO"] = "CANG"
obs$type[obs$type %in% c("DEADULGU","ULGU")] = "UNLG"
obs$type[obs$type=="LSTP"] = "LEAS"
obs$type[obs$type=="UNGE"] = "UNGR"
obs$type[obs$type %in% c("UNID","UNK")] = "UNKN"
obs$type[obs$type %in% c("BLGE","GACO","G3SH","COM")] = "UNKN" # couldn't figure out these codes      
# ------------------------# 

# ------------------------# 
# TIME
obs$gps_date = as.Date(obs$gps_date)	
# ------------------------# 
