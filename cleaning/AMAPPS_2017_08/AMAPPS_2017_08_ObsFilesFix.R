##--------------------------##
# fixing errors in AMAPPS 2017 08 data
##--------------------------##


##--------------------------##
## Pilot notes

## Crew 4446
## Non-standard species or codes:		
# Code	Description	
# MOMO	Mola Mola Ocean Sunfish	
#	NOGA adult	Note that Koneff did not record age class on Aug 18, and only Koneff used these codes.  TPW put age class in comments.
# NOGAi	NOGA immature 	Note that Koneff did not record age class on Aug 18, and only Koneff used these codes.  TPW put age class in comments.
# UNSK	Unknown Skua	
# WIDO	White-sided Dolphin	
# FIWH	Fin Whale	
## Other relevant information and comments:															
# Note:  started slightly offshore on numerous transects due to coastal development.															
# Note:  distances to Trawlers (fishing vessels) is shown in meters from transect centerline.															
# Note:  MDK had no BEGSEG for 444100															
# Note: TPW recorded data on TRAWL in a different format on 8/18 than on other days															
# Note: MDK did not record ENDCNT/BEGCNT when going over land on 442601 due to high density traffic/workload.  Use breaks from TPW.															
# Note: called the start of 423600 a little late (~1mile).  Entire transect was surveyed.															
# Note:  TPW missed start point for 423100 and the geographic location of the start point for MDK should be verified on line.  Note that this line was started east of the published start point to due harbor boat traffic.															
# Note: Did not record the ENDSEG for 415100.															
# Note: Called the end of 415101 about 1/2 mile late.															
# Note: Cut off the West end of 412101 (ended early) which overlies Martha's Vineyard.															
##--------------------------##


##--------------------------##
# species errors
##--------------------------##
obs$type = as.vector(obs$type) # not sure why this is coming in as a matrix - need to check
obs$original.spp.codes = obs$type

db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
spplist <- sqlFetch(db, "lu_species")
odbcClose(db)

tmp <- !obs$type %in% spplist$spp_cd
message("Found ", sum(tmp), " entries with non-matching AOU codes")
sort(unique(obs$type[tmp]))
rm(spplist)

obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("lobster boat","400, lobster boat",
                                                    "300,lobster boat",
                                                    "600, lobster boat no birds following",
                                                    "lobster boat no birds following",
                                                    "lobster boat with 3 HEGU fowing")] = "BOLO"
obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("fishing birds following",
                                                    "fishing with gannets and gulls following")] = "BOFI"

obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "BODU"] = "BODO"   
obs$type[obs$type %in% "DDCO"] = "DCCO"  
obs$type[obs$type %in% "DOLP"] = "UNDO"    
obs$type[obs$type %in% "DUCK"] = "UNDU"    
obs$type[obs$type %in% "HEGU"] = "HERG"      
obs$type[obs$type %in% "LEST"] = "LETU"      
obs$type[obs$type %in% "LHSP"] = "LESP"      
obs$type[obs$type %in% "SEAL"] = "UNSE"      
obs$type[obs$type %in% "UNSB"] = "SHOR"   
obs$type[obs$type %in% c("UIST","UNTU")] = "TURT"   
obs$type[obs$type %in% "WHAL"] = "UNWH"      
obs$type[obs$type %in% "WSIP"] = "WISP"  
obs$type[obs$type %in% "TRAWL"] = "BOTD"
obs$type[obs$type %in% "MOMO"] = "MOLA"
obs$type[obs$type %in% "WIDO"] = "WSDO"
obs$type[obs$type %in% "SALPEN"]	= "SPEN"
obs$type[obs$type %in% "GULL"]	= "UNGU"    
obs$type[obs$type %in% "HTOWR"]	= "TOWR"   
obs$type[obs$type %in% "LOST"]	= "LOTU"    
obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA", "NOGAI")] = "NOGA"

tmp = obs$type != obs$original.spp.codes
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", obs$original.spp.codes[tmp], sep = "")
rm(tmp)

# pull out type for useful comments
# change comment codes with no text in comment to remove -> will be removed in transects
obs$type[obs$type %in% "COMMENT" & obs$comment %in% c("lobster gear hundreds of pots",
                                                      "lobster gear everywhere")] = "FGLO"
obs = mutate(obs, type = replace(type, type %in% "COMMENT","REMOVE"))

message("Fixed AOU codes")

## remove duplicate fields

##--------------------------##


##--------------------------##
## fill in other fields from comments
##--------------------------##
#behavior
obs$behavior[obs$comment %in% c("f","s","F","S") & obs$behavior %in% ""] = obs$comment[obs$comment %in% c("f","s","F","S") & obs$behavior %in% ""]
obs$behavior[obs$comment %in% c("300,F, following lobster boat",
                                   "300,F, following trawler",
                                   "300,F,following fishing boat",
                                   "300,F,following trawler")]="f"
obs$behavior[obs$comment %in% c("600,S,adult, following trawler")]="s"
obs$behavior = tolower(obs$behavior)

#age
obs$age[obs$comment %in% c("adult","600,S,adult, following trawler","adult in rockweed",
                           "adult, following trawler","adult,counting on transit transect",
                           "adult,following trawler","adult,transit transect",
                           "adults,following fishing boat")] = "adult"
obs$age[obs$comment %in% c("aubadult","subadult",
                           "sub adult","subadult, fish in bill",
                           "subadult,counting on transit transect",
                           "subadult,transit transect")] = "subadult"
obs$age[obs$comment %in% c("juvenile","juvenile, following fishing boat")] = "juvenile"

#association
obs$association[obs$comment %in% c("following fishing boat",
                                   "300,F,following fishing boat",
                                   "adults,following fishing boat",
                                   "juvenile, following fishing boat")] = "BOFI"
obs$association[obs$comment %in% c("with lobster boat","following lobster boat",
                                   "300,F, following lobster boat",
                                   "300,lobster boat","400, lobster boat")] = "BOLO"
obs$association[obs$comment %in% c("feeding over humpback whale")] = "HUWH"
obs$association[obs$comment %in% c("adult in rockweed")] = "RCKW"
obs$association[obs$comment %in% c("300,F, following trawler",
                                   "300,F,following trawler",
                                   "600,S,adult, following trawler",
                                   "adult, following trawler",
                                   "adult,following trawler")] = "BOTD"
obs$association[obs$comment %in% c("associated with salmon pens")] = "SPEN"

# distance
obs$distance.to.obs[obs$comment %in% c("100")] = 100                                          
obs$distance.to.obs[obs$comment %in% c("1000,no birds following")]=1000                                           
obs$distance.to.obs[obs$comment %in% c("200")] = 200
obs$distance.to.obs[obs$comment %in% c("300","300, birds following","300,birds following",
                                          "300,F, following lobster boat","300,F, following trawler",
                                          "300,F,following fishing boat","300,F,following trawler",
                                          "300,lobster boat" )] = 300                                          
obs$distance.to.obs[obs$comment %in% c("400","400, lobster boat")] = 400                                          
obs$distance.to.obs[obs$comment %in% c("50")] = 50                                           
obs$distance.to.obs[obs$comment %in% c("500")] = 500
obs$distance.to.obs[obs$comment %in% c("600",
                                          "600, lobster boat no birds following",
                                          "600,S,adult, following trawler")] = 600                                          
obs$distance.to.obs[obs$comment %in% c("700")] = 700
##--------------------------##


##--------------------------##
# fix transects errors
##--------------------------##
# MDK had no BEGSEG for 444100
obs$type[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT" & obs$sec %in% 31483.70]="BEGSEG"
to.add = obs[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
to.add$seat = "lf"
obs = rbind(obs, to.add)

# MDK did not record ENDCNT/BEGCNT when going over land on 442601 
obs$type[obs$transect %in% 442601 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT" & obs$sec %in% 38768.43] = "BEGSEG"
to.add = obs[obs$transect %in% 442601 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
to.add$seat = "lf"
obs = rbind(obs, to.add)

# TPW missed start point for 423100, use MDK's	
obs$type[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGCNT"] = "BEGSEG"
to.add = obs[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGSEG",]
to.add$obs = "tpw"
to.add$comment = "added from mdk's record"
to.add$index = NA
to.add$seat = "rf"
obs = rbind(obs, to.add)

# Note: Did not record the ENDSEG for 415100.	
obs$type[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT"] = "BEGSEG"
obs$type[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDCNT"] = "ENDSEG"
to.add = obs[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
to.add$seat = "lf"
obs = rbind(obs, to.add)
rm(to.add)

# Note: Called the end of 415101 about 1/2 mile late.

# 441100 
#missing 2 ends or typo for beg
obs$type[obs$transect %in% 441100 & obs$obs %in% "tpw" & obs$sec %in% c(61518.03, 62576.77)] = "REMOVE"
#change ENDCNT to END SEG
obs$type[obs$transect %in% 444100 & obs$obs %in% "mdk" & obs$type %in% "ENDCNT" & obs$sec %in% 32331.37]="ENDSEG" 

# 442602 typo for beg
obs$type[obs$transect %in% 442602 & obs$obs %in% "mdk" & obs$sec %in% 37227.20] = "BEGSEG"

# 443100 double end
obs$type[obs$transect %in% 443100 & obs$obs %in% "tpw" & obs$sec %in% 35851.50] = "REMOVE"

# 444600 double end
obs$type[obs$transect %in% 444600 & obs$obs %in% "tpw" & 
           obs$sec %in% 31284.55 & obs$type %in% "ENDCNT"] = "REMOVE"

#change ENDCNT to END SEG
obs$type[obs$transect %in% 411601 & obs$obs %in% "mdk" & obs$type %in% "ENDCNT"]="ENDSEG" 

# remove dublicates coded as remove
obs = filter(obs, !type %in% "REMOVE")

# change offline obs transects to NA
obs = mutate(obs, offline = ifelse(offline %in% "y", 1, 0),
             transect = replace(transect, transect %in% c("0","000000"),NA),
             transect = ifelse(offline %in% 1, NA, transect))

# missing transects (NAs)
# tpw 434100
# tpw 433600
# tpw 430600
# tpw 424100 add Beg?
# tpw 8/24 40522.50: 40610.21 -> all off transect counts by mdk times. 414101 ends at 40522.35
# twp 412101

# jsw missing transects
obs$offline[obs$obs %in% "jsw"] = 0 # no offline indicated
obs$offline[obs$obs %in% "jsw" & 
              obs$sec %in% c(49480.29,50794.27,50833.73,32384.48,35213.19,39706.75) & 
              obs$type  %in% "TOWR"] = 1
obs$transect[obs$obs %in% "jsw"] = NA # currently "null"
obs$transect[obs$obs %in% "jsw" & obs$type %in% c("BEGCNT","ENDCNT")] = obs$count[obs$obs %in% "jsw" & obs$type %in% c("BEGCNT","ENDCNT")]
obs$transect[obs$obs %in% "jsw" & obs$offline %in% 0] = na.locf(obs$transect[obs$obs %in% "jsw" & obs$offline %in% 0]) #all offline are na so dont need to change transects to NA for offline yet

# jsw 324600, switch BEG and END
obs$type[obs$obs %in% "jsw" & obs$transect %in% "324600" & obs$sec %in% 55539.87] = "ENDCNT"
obs$type[obs$obs %in% "jsw" & obs$transect %in% "324600" & obs$sec %in% 55239.01] = "BEGCNT"

if(any(is.na(obs$transect[obs$offline %in% 0]))){
  message("missing transect number for on transect record")}

if(any(!is.na(obs$transect[obs$offline %in% 1]))){
  message("remove transect number for offline record")}

message("Fixed transect errors")

## descriptive plots
#ggplot(filter(obs,obs %in% "mdk"), aes(long,lat,col=transect))+geom_point()

#ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
#       aes(long,lat,col=transect))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)

#ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
#       aes(long,lat,col=type))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)
##--------------------------##


##--------------------------##
# fix errors
##--------------------------##

## counts
obs$count[obs$count %in% c("1.1.f","1.2.f.adult")] = 1
obs$distance.to.obs[obs$count %in% c("1/4")] = 0.25
obs$distance.to.obs[obs$count %in% c("1.5")] = 1.5
obs$count[obs$count %in% c("1/4","1.5")] = 1
obs$count[obs$count %in% "0"] = NA
obs = filter(obs, !count %in% "")

## investigate high counts
#x = obs[as.numeric(obs$count) > 100 & !obs$type %in% c("BEGSEG","ENDSEG","BEGCNT","ENDCNT","COCH"),]
obs$distance.to.obs[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 200
obs$count[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 1
#rm(x)

## dates
# mdk uses 5 instead of 8
obs$month[obs$obs %in% "mdk"] = 8
obs = mutate(obs, date = as.Date(paste(month, day, year, sep="/"),format="%m/%d/%Y"),
             month = as.numeric(month), day = as.numeric(day), year = as.numeric(year))

## change meters to nm
obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] = obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] * 0.000539957

## condition

message("Fixed other errors")
##--------------------------##
