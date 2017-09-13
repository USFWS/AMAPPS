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
# DataChange comments for spp_cd errors
changes = c("TRAWL","MOMO","WIDO","NOGAA,NOGAI")
for (a in 1:length(changes)) {
  obs$dataChange[which(obs$type == changes[a])] = 
    paste(obs$dataChange[which(obs$type == changes[a])],
          "; Changed TYPE from ", changes[a], sep ="") 
}
rm(changes, a)

# CODE ERRORS
obs$original.spp.codes = obs$type

obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("lobster boat","400, lobster boat",
                                                    "300,lobster boat",
                                                    "600, lobster boat no birds following",
                                                    "lobster boat no birds following",
                                                    "lobster boat with 3 HEGU fowing")] = "BOLO"
obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("fishing birds following",
                                                    "fishing with gannets and gulls following")] = "BOFI"

obs$type[obs$type %in% "TRAWL"] = "BOTD"
obs$type[obs$type %in% "MOMO"] = "MOLA"
obs$type[obs$type %in% "WIDO"]	= "WSDO"

obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA, NOGAI")] = "NOGA"


message("Fixed AOU codes")
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
to.add = obs[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)

# MDK did not record ENDCNT/BEGCNT when going over land on 442601 
to.add = obs[obs$transect %in% 442601 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)

# TPW missed start point for 423100, use MDK's	
to.add = obs[obs$transect %in% 423100 & obs$obs %in% "mdk" & obs$type %in% "BEGSEG",]
to.add$obs = "tpw"
to.add$comment = "added from mdk's record"
to.add$index = NA
obs = rbind(obs, to.add)

# Note: Did not record the ENDSEG for 415100.	
to.add = obs[obs$transect %in% 415100 & obs$obs %in% "tpw" & obs$type %in% "ENDSEG",]
to.add$obs = "mdk"
to.add$comment = "added from tpw's record"
to.add$index = NA
obs = rbind(obs, to.add)
rm(to.add)
# Note: Called the end of 415101 about 1/2 mile late.
##--------------------------##


##--------------------------##
# fix errors
##--------------------------##

## counts
obs$count[obs$count %in% c("1.1.f","1.2.f.adult")] = 1
obs = obs[obs$obs %in% "mdk" && !obs$count %in% "",]

# investigate high counts
x = obs[as.numeric(obs$count) > 100 & !obs$type %in% c("BEGSEG","ENDSEG","BEGCNT","ENDCNT","COCH"),]
obs$distance.to.obs[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 200
obs$count[obs$type %in% "BOTD" & obs$obs %in% "tpw" & obs$count %in% "200"] = 1
rm(x)

## dates
# mdk uses 5 instead of 8
obs$month[obs$obs %in% "mdk"] = 8
##--------------------------##
