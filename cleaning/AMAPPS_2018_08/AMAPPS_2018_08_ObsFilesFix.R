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
# ##--------------------------##
# # fix transects errors
# ##--------------------------##
t = 293100
s = "lf"
ggplot(obs[obs$transect %in% t & obs$seat %in% s,], aes(long, lat))+geom_point()

ggplot(track[track$transect %in% t & track$seat %in% s,], aes(long, lat))+geom_point()

# Transects	BegFreq	EndFreq	Observer
# 0	26	24	tpw
# 293100	2	1	jsw


# 295600	2	1	jsw
# 302600	3	2	jsw
# 324100	1	3	jsw
# 325600	1	2	jsw
# 332600	1	2	jsw
# 335100	5	6	jsw
# 352100	3	2	jsw
# 352101	2	1	jsw
# 352600	1	2	sde
# 362100	1	2	sde
# 391100	4	2	sde
# 412100	2	1	sde
# 415101	2	1	mdk
# 420600	2	1	mdk
# 440100	6	5	mdk
# 440600	14	15	mdk
# 441600	17	18	mdk
# 442100	4	5	mdk
# 442101	3	4	mdk
# 443600	17	16	mdk

# #390600
# obs$dataChange[obs$transect %in% 393600 & obs$day %in% 26] = "Changed TRANSECT from 393600"
# obs$transect[obs$transect %in% 393600 & obs$day %in% 26] = 390600
#   
# # MDK had no BEGSEG for 444100
# obs$type[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGCNT" & obs$sec %in% 31483.70]="BEGSEG"
# to.add = obs[obs$transect %in% 444100 & obs$obs %in% "tpw" & obs$type %in% "BEGSEG",]
# to.add$obs = "mdk"
# to.add$comment = "added from tpw's record"
# to.add$index = NA
# to.add$seat = "lf"
# obs = rbind(obs, to.add)
# 
# ## descriptive plots
# #ggplot(filter(obs,obs %in% "mdk"), aes(long,lat,col=transect))+geom_point()
# 
# #ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
# #       aes(long,lat,col=transect))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)
# 
# #ggplot(filter(obs,obs %in% "mdk", type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")), 
# #       aes(long,lat,col=type))+geom_point()+geom_text(aes(label=transect),hjust=0, vjust=0)
# 
# ##--------------------------##
# 
# 
# ##--------------------------##
# # fix errors
# ##--------------------------##
# 
# # ---------- #  
# # counts
# # ---------- # 
obs$comment[obs$count %in% c("2to3")] = "2to3"
obs$count[obs$count %in% c("2to3")] = NA

obs$comment[obs$count %in% c("3to2")] = "3to2"
obs$count[obs$count %in% c("3to2")] = NA

obs$count[obs$count %in% c("0")] = NA

obs$comment[obs$count %in% c("2.0.f")] = "2.0.f"
obs$behavior[obs$count %in% c("2.0.f")] = "f"
obs$count[obs$count %in% c("2.0.f")] = 2

obs$behavior[obs$count %in% c("1.0")] = "f"
obs$count[obs$count %in% c("1.0")] = 1   

obs$comment[obs$count %in% c("2.2.f.adult")] = "2.2.f.adult"
obs$behavior[obs$count %in% c("2.2.f.adult")] = "f"
obs$age[obs$count %in% c("2.2.f.adult")] = "adult"
#obs$band[obs$count %in% c("2.2.f.adult")] = 2
obs$count[obs$count %in% c("2.2.f.adult")] = 2 #check what second 2 and 0s above mean for tim white, band?

obs$count[obs$count %in% c("4COCH3")] = NA

# ## investigate high counts
obs[as.numeric(obs$count) > 100 & !obs$type %in% c("BEGSEG","ENDSEG","BEGCNT","ENDCNT","COCH"),]

## boat counts
obs[as.numeric(obs$count) > 2 & obs$type %in% c("BOAT","BOTD","BOFI"),]
# # ---------- # 
# 
# # ---------- # 
# # dates
# # ---------- # 
# # mdk uses 5 instead of 8
# obs$month[obs$obs %in% "mdk"] = 8
# obs = mutate(obs, date = as.Date(paste(month, day, year, sep="/"),format="%m/%d/%Y"),
#              month = as.numeric(month), day = as.numeric(day), year = as.numeric(year))
# 
# # jfv says it's the 30th when it was flown on the 26th
# obs$comment[obs$obs %in% "jfv" & obs$day %in% 30] = paste(obs$comment[obs$obs %in% "jfv" & obs$day %in% 30],
#                                                           "DAY changed from 30", sep = "; ")
# obs$day[obs$obs %in% "jfv" & obs$day %in% 30] = 26
# # ---------- # 
# 
# 
# # ---------- # 
# # distance
# # ---------- # 
# # change meters to nm
# obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] = obs$distance.to.obs[obs$obs %in% c("tpw","mdk")] * 0.000539957
# # ---------- # 
# 
# 
# # ---------- # 
# # condition
# # ---------- # 
# to.add = obs[obs$transect %in% 350100 & obs$sec %in% 39841.16,]
# obs$count[obs$transect %in% 350100 & obs$sec %in% 39841.16]=4
# to.add = mutate(to.add,
#                 condition = 3,
#                 index=index+0.1,
#                 dataChange = "Added COCH based on other COCH")
# obs = rbind(obs,to.add)
# rm(to.add)
# # ---------- # 
# 
# 
# # ---------- # 
# # offline
# # ---------- # 
# obs$offline[is.na(obs$transect) & 
#               obs$comment %in% c("counting on transit leg","counting on transit transect","transit transect") & 
#               obs$offline %in% 0] = 1
# 
# # fix offline for tpw
# obs$type[obs$obs %in% 'tpw' & obs$transect %in% 0 & obs$type %in% c('BEGCNT','ENDCNT')] = 'COMMENT'
# obs$transect[obs$obs %in% 'tpw' & obs$transect %in% 0] = NA
# obs$offline[obs$obs %in% 'tpw' & is.na(obs$transect)] = 1
# 
# # there are others who listed offline BEG and END records which screw up some things later on
# obs$type[obs$offline %in% 1 & obs$type %in% c('BEGCNT','ENDCNT')] = 'COMMENT'
# 
# #
# obs$dataChange[obs$day %in% 20 & obs$obs %in% 'tpw' & obs$sec %in% c(40287.65,40287.65,40327.38,40480.69,40535.10)]= paste(obs$dataChange[obs$day %in% 20 & obs$obs %in% 'tpw' & obs$sec %in% c(40287.65,40287.65,40327.38,40480.69,40535.10)],
#                                                                                                                            " changed to offline", sep = "; ")
# obs$transect[obs$day %in% 20 & obs$obs %in% 'tpw' & obs$sec %in% c(40287.65,40287.65,40327.38,40480.69,40535.10)]=NA
# obs$offline[obs$day %in% 20 & obs$obs %in% 'tpw' & obs$sec %in% c(40287.65,40287.65,40327.38,40480.69,40535.10)]=1
# # ---------- #
# 
# message("Fixed other errors")
# ##--------------------------##
# 
