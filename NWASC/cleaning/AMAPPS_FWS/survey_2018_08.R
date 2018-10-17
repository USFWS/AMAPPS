##--------------------------##
# fixing errors in AMAPPS 2018 08 data
##--------------------------##


##--------------------------##
## Pilot notes

# crew3521
# 343100	P	Active Military Restricted Area													
# 343600	P	Displaced beginning due to Active Military Restricted Area													
# 334100	P	Air Traffic Control denied the westernmost 3 nautical miles													
# 303100	P	Ended early due to lightning storm													
# 302600	P	Ended early due to lightning storm													
# 302100	P	Ended early due to lightning storm													
# 
# # crew4126
# 352600		16 Aug pilot forgot to record start count, use observer's recording			
# 353600		16 Aug stopped count over land			
# 354100		16 Aug stopped count over land			
# 354600		17 Aug stopped count over land			
# 355100		17 Aug stopped count over land			
# 355600		17 Aug stopped count over land			
# 360100		17 Aug stopped count over land			
# 363600	P	17 Aug lost distance due to restricted airspace			
# 364101	P	17 Aug lost distance due to restricted airspace			
# 364601	P	17 Aug lost distance due to restricted airspace			
# 364601	P	18 Aug picked up the remainder of the transect lost on 17 Aug			
# 372100		18 Aug stopped count over land			
# 384600		19 Aug stopped count over land			
# 381600		19 Aug stopped count over land			
# 380600		19 Aug 2 times stopped count over land			
# 375600		19 Aug 4 times stopped count over land			
# 375100		19 Aug stopped count over land			
# 380601		19 Aug circled to look at shark, no distance lost			
# 391100		20 Aug observer had land on his side so has a stop count, but pilot did not have land so no stop count recorded			
# 395100		21 Aug circled to look at dolphins, no distance lost			
# 402100		21 Aug circled to look at whale, no distance lost			
# 402600		21 Aug stopped count over land			
# 404100		22 Aug stopped count over land			
# 410101		22 Aug 2 times stopped count over land			
# 410100		22 Aug stopped midline to get fuel, no distance lost			
# 405600		22 Aug 2 times stopped count over land			
# 410600		22 Aug 3 times stopped count over land			
# 411100		22 Aug 2 times stopped count over land			
# 411600		22 Aug first two stops were for over land, 3rd stop was circling, no distance lost			
# 
# UISB	Unidentified shorebirds
# 
# 
# # crew4446
# 432100	P	missed the western end due to Prohibited Area P-67						
# 423100	P	missed the western end due to Beverly Harbor						
# 440600	P	missed the western end due to Rockland Harbor						
# 424100	P	missed the western end due to boats and surfers in the water						
# 413101-02	M	not enough time on aircraft to complete before inspection (informed BOEM before survey), may try to return later in early sept						
# 412601-02	M	not enough time on aircraft to complete before inspection (informed BOEM before survey), may try to return later in early sept						
# 412101-02	M	not enough time on aircraft to complete before inspection (informed BOEM before survey), may try to return later in early sept						
# 411601-02	M	not enough time on aircraft to complete before inspection (informed BOEM before survey), may try to return later in early sept						
# Note there are number ENDCNT/BEGCNTs in database due to passing over land areas or areas of fog.								
# 
# MOMO	Mola Mola Ocean Sunfish	
# NOGAa	NOGA adult	
# NOGAi	NOGA immature 	
# UNSK	Unknown Skua	
# WIDO	White-sided Dolphin	
# HTOWR	Tower, aerial hazard	
# HLINE	Power or Phone Line or Cable, aerial hazard	
# SALPEN	Salmon Pen, aquaculture	
# BBGU	Black-backed Gull, unknown spp	
##--------------------------##


##--------------------------##
# species errors
##--------------------------##
obs$type = as.vector(obs$type) # not sure why this is coming in as a matrix - need to check
obs$original.spp.codes = obs$type

db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw-dbcsqlcl1', database='NWASC')
spplist = dbGetQuery(db,"select * from lu_species")
dbDisconnect(db)

tmp <- !obs$type %in% spplist$spp_cd
x = obs$type[tmp][!obs$type[tmp] %in% c("BEGCNT","ENDCNT","COMMENT","COCH")]
message("Found ", length(x), " entries with non-matching AOU codes")
unique(x); rm(x)

# obs$type[obs$type %in% "TRAWL" & obs$comment %in% c("lobster boat","400, lobster boat",
#                                                     "300,lobster boat",
#                                                     "600, lobster boat no birds following",
#                                                     "lobster boat no birds following",
#                                                     "lobster boat with 3 HEGU fowing")] = "BOLO"

obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "DOLP"] = "UNDO"    
obs$type[obs$type %in% "HEGU"] = "HERG"      
obs$type[obs$type %in% "LEST"] = "LETU"      
obs$type[obs$type %in% "SEAL"] = "UNSE"      
obs$type[obs$type %in% "UIST"] = "TURT"   
obs$type[obs$type %in% "SALPEN"]	= "SPEN"
obs$type[obs$type %in% "GULL"]	= "UNGU"    
obs$type[obs$type %in% "HTOWR"]	= "TOWR"   
obs$type[obs$type %in% "LOST"]	= "LOTU"    
obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA", "NOGAI")] = "NOGA"
obs$type[obs$type %in% "GRST"] = "GRTU"# green sea turtle
obs$type[obs$type %in% "GREA"] = "GREG"
obs$type[obs$type %in% "ALCD"] = "UNAL"
obs$type[obs$type %in% "BAL"] = "BALN" #checking     
obs$type[obs$type %in% "BBGU"] = "UBBG"     
obs$type[obs$type %in% "EIDE"] = "UNEI"     
obs$type[obs$type %in% "GEAR"] = "FIGE"     
obs$type[obs$type %in% "PORP"] = "UNPO" #unid porpoise     
#obs$type[obs$type %in% "PUSP"] = ""     
obs$type[obs$type %in% "RIST"] = "KRST" #Ridley sea turtle
obs$type[obs$type %in% "UNMG"] = "UNGU" #checking medium gull?    
obs$type[obs$type %in% "UNSD"] = "SPDO" 

obs$type[obs$comment == "rockweed line"]="RCKW"
obs$type[obs$comment %in% c("hundreds of lobsters pots","hundreds of lobster traps in area")] = "FGLO"

to.add = obs[obs$type %in% "MIXD",]     
obs$count[obs$type %in% "MIXD"]=30
obs$type[obs$type %in% "MIXD"]="LAGU"
to.add$count=10
to.add$type="UNGU"
obs = rbind(obs, to.add)
rm(to.add)

tmp = obs$type != obs$original.spp.codes
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", obs$original.spp.codes[tmp], sep = "")
rm(tmp)

# second test
tmp <- !obs$type %in% spplist$spp_cd
x = obs$type[tmp][!obs$type[tmp] %in% c("BEGCNT","ENDCNT","COMMENT","COCH")]
if(length(x)>0){message("Found ", length(x), " entries with non-matching AOU codes")
  message(unique(x)); rm(x)
  }else(message("All species codes have been corrected"))
# ##--------------------------##
# 
# 
