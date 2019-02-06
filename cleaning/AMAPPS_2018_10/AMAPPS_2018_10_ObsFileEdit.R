##--------------------------##
# fixing errors in AMAPPS 2018 10 data
##--------------------------##


##--------------------------##
## Pilot notes

# crew 3521
# 343100	P	Active Military Restricted Area			
# 343600	P	Displaced beginning due to Active Military Restricted Area			
# 323100	P	Navy Battleship Activity			

# crew 4126
# UNLG	Unidentified large gull
# MOLA	Ocean sunfish

# crew 4446
# 432100	P	missed the western end due to Prohibited Area P-67						
# 423100	P	missed the western end due to Beverly Harbor						
# 440600	P	missed the western end due to Rockland Harbor						
# 
# manual edits by KEC for Crew4126rf_20181022_birds.asc, Crew4126rf_20181023_birds.asc, Crew4126rf_20181025_birds.asc for days that were wrong and causing import errors
#   Non-standard species or codes:								
#   Code	Description							
# MOMO	Mola Mola Ocean Sunfish							
# NOGAa	NOGA adult							
# NOGAi	NOGA immature 							
# UNSK	Unknown Skua							
# WIDO	White-sided Dolphin							
# HTOWR	Tower, aerial hazard							
# HLINE	Power or Phone Line or Cable, aerial hazard							
# SALPEN	Salmon Pen, aquaculture							
# BBGU	Black-backed Gull, unknown spp							
# 
# Other relevant information and comments:								
#   Note:  started slightly offshore on numerous transects due to coastal development.								
# Note:  distances to Trawlers (fishing vessels) and any other boats recorded  is shown in meters from transect centerline.								
# Note: NOGAi identified during this survey were subadults not juveniles. No known juveniles observed. It is highly likely that other subadults were coded as NOGAa.								
# 
# PILOT (LF) Condition Changes:								
#   442602 COCH 3 to 4								
# 441600 COCH 4 TO 2								
# 441100 COCH 5 TO 3								
# 440600 COCH 1 TO 4								
# 420600 COCH 3 TO 1								
# 
# PILOT (LF) CHANGED SPECIES CODING FROM VOICE FILES (BASED ON HAND NOTES DURING FLIGHT AND SUBSEQUENT RECONSIDERATION OF CODING)								
# 431100: GBBG TO UNSK								
# 430100: BIRD to UNTE								
# 425600:  COLO to ALCD								
# 425100: RBGU to UNTE								
# 424600: GRSH to ALCD								
# 422100:  BIRD to UNTE								
# 422100: GRSH 50 to MASH 50								
# 422100: GSSH 60 to MASH 60								
# 420100: BIRD to UNSP								
# 413600: GRSH to ALCD								
# 413602: BIRD 6 to UNSP 6								
# 413602: BIRD to UNSP								
# 404601: GRSH 15 to ALCD 15								
# 405101: BIRD 2 to UNPH 2								
# 405602: GRSH 12 to ALCD 12								
# 405602: BIRD to ALCD								

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

obs$type[obs$type %in% "MOMO"] = "MOLA"
obs$type[obs$type %in% "BIRD"] = "UNBI"
obs$type[obs$type %in% "DOLP"] = "UNDO"    
obs$type[obs$type %in% "HEGU"] = "HERG"      
obs$type[obs$type %in% "LEST"] = "LETU"      
obs$type[obs$type %in% "SEAL"] = "UNSE"      
obs$type[obs$type %in% "SALPEN"]	= "SPEN"
obs$type[obs$type %in% "GULL"]	= "UNGU"    
obs$type[obs$type %in% "LOST"]	= "LOTU"    
obs$age[obs$type %in% c("NOGAA")] = "adult"
obs$age[obs$type %in% c("NOGAI")] = "immature"
obs$type[obs$type %in% c("NOGAA", "NOGAI")] = "NOGA"
obs$type[obs$type %in% "ALCD"] = "UNAL"
obs$type[obs$type %in% "BBGU"] = "UBBG"     
obs$type[obs$type %in% "PORP"] = "UNPO" #unid porpoise   
obs$type[obs$type %in% "UNMG"] = "UNGU" #checking medium gull  
obs$type[obs$type %in% "UIST"] = "TURT"   
obs$type[obs$type %in% "RIST"] = "KRST"
obs$type[obs$type %in% "SCOT"] = "UNSC"  
obs$type[obs$type %in% "LOON"] = "UNLO"
obs$type[obs$type %in% "WHAL"] = "UNWH"
obs$type[obs$type %in% "MERG"] = "UNME"  
obs$type[obs$type %in% c("BRNT","ATBR")] = "BRAN"  
obs$type[obs$type %in% "CAGO"] = "CANG"  
obs$type[obs$type %in% "DUCK"] = "UNDU"
obs$type[obs$type %in% "DWSC"] = "DASC"   
obs$type[obs$type %in% "ABCU"] = "ABDU"
obs$type[obs$type %in% "BOATS"] = "BOAT"
obs$type[obs$type %in% "GEAR" & obs$comment %in% "fishing net"] = "FIGE"
obs$type[obs$type %in% "GEAR" & !obs$comment %in% "fishing net"] = "FGUN"
obs$type[obs$type %in% "GREA"] = "GREG"

obs$type[obs$type %in% "DOCO" & obs$count %in% 1000] = "UNDU" # listening to WAVfile this was miscoded
obs$type[obs$type %in% "DOCO"] = "DCCO"


#"MIXD"   
# "50%HERG; 20%RBGU; 30%GBBG" 
# "50%HERG;50%LAGU"           
# "S 75%BLSC;25%SUSC"        
# "100BLSC;3WWSC"             
# "50%GBBG; 50%HERG"; "50%GBBG;50%HERG"          
# "75%BOGU; 25%HERG"          
# "75%LAGUE;25%BOGU"         
# "50%HERG;50%LAGU"; "50%HERG;50%LAGU"           
# "50% BLSC;50% SUSC"   

# fix those formatted incorrectly
to.add1 = obs[obs$type %in% "MIXD" & obs$comment %in% "100BLSC;3WWSC",]
to.add2 = obs[obs$type %in% "MIXD" & obs$comment %in% "100BLSC;3WWSC",]
to.add1 = mutate(to.add1, type = "BLSC", count = 100, dataChange = "type changed from MIXD")
to.add2 = mutate(to.add1, type = "WWSC", count = 3, dataChange = "type changed from MIXD")
obs = rbind(obs, to.add1, to.add2)
  
# fix those formatted correctly
obs = fixMixed(obs)

# species erorr from mixed
obs$type[obs$type %in% "LAGUE"] = "LAGU"

tmp = obs$type != obs$original.spp.codes
obs$dataChange[tmp] = paste(obs$dataChange[tmp], "; changed TYPE from ", obs$original.spp.codes[tmp], sep = "")
rm(tmp)

# second test
tmp <- !obs$type %in% spplist$spp_cd
x = obs$type[tmp][!obs$type[tmp] %in% c("BEGCNT","ENDCNT","COMMENT","COCH")]
if(length(x)>0){message("Found ", length(x), " entries with non-matching AOU codes")
  message(list(unique(x)))
  rm(x)
}else(message("All species codes have been corrected"))
# ##--------------------------##
# 
# 
# ##--------------------------##
# # fix transects errors
# ##--------------------------##
o = "sfy"
t = "1"
x = obs[obs$transect %in% t & obs$obs %in% o,]
  
# Transects      BegFreq EndFreq Observer
# 265    ------     103     102      sfy
# no transect #s but some counts at for transects
obs$transect[obs$obs %in% "sfy" & obs$type %in% c("BEGCNT","ENDCNT")] = obs$count[obs$obs %in% "sfy" & obs$type %in% c("BEGCNT","ENDCNT")]

# 82     300100       3       1      jsw
obs$type[obs$obs %in% "jsw" & obs$transect %in% 300100 & obs$sec %in% 45968.50] = "ENDCNT"

# 51     313100       1       3      jsw
# looks fine, not sure why this came up?
# error is with jep
obs$type[obs$obs %in% "jep" & obs$transect %in% 313100 & obs$sec %in% 37703.60] = "BEGCNT"

# retry
checkBegEnd(obs)
# Transects BegFreq EndFreq Observer
# 266         1       1       0      sfy
# one BEG, no other comments so changing the '1' back to NA
# also changing all "" to NA
obs$transect[obs$obs %in% "sfy" & obs$transect %in% c("","1")] = NA
##--------------------------##


# ---------- #
# counts/ behavior/ band
# ---------- #
# "0.5"
# "1.0.5"   
# "1.2.F"
# "2.2.S"
# ""

# behavior
obs$behavior[obs$count %in% c("1.2.F")] = "F"
obs$behavior[obs$count %in% c("2.2.S")] = "S"

# band
obs$band[obs$count %in% c("1.2.F","2.2.S")] = "2"

# count
obs$count[obs$count %in% c("1.2.F")] = 1
obs$count[obs$count %in% c("2.2.S")] = 2

# boat counts
obs$dataChange[obs$count %in% c("0.5","1.0.5")] = paste(obs$dataChange[obs$count %in% c("0.5","1.0.5")],
                                                        "; changed dsitance based on comment",
                                                        sep="")
obs$distance.to.obs[obs$count %in% c("0.5","1.0.5")] = 0.5

obs$dataChange[obs$type %in% c("BOTD","BOAT") & obs$count %in% ""] = paste(obs$dataChange[obs$type %in% c("BOTD","BOAT") & obs$count %in% ""],
                                                                           "; changed count from ''; count is estimated",
                                                                           sep="")
obs$count[obs$type %in% c("BOTD","BOAT") & obs$count %in% ""] = 1

# correct boat codes
obs$type[obs$type %in% "BOAT" & obs$comment %in% "trawler"] = "BOTD"  
obs$type[obs$type %in% "BOAT" & obs$comment %in% "fishing boat"] = "BOFI"  
       
# add distance based on comments
obs$distance.to.obs[obs$type %in% "BOTD" & obs$comment %in% "; distance: 1/4mi"] =  (1/4)*0.868976
obs$distance.to.obs[obs$type %in% "BOTD" & obs$comment %in% "; distance: 1/10mi"] = (1/10)*0.868976
obs$distance.to.obs[obs$type %in% "BOTD" & obs$comment %in% "; distance: 1/2mi"] =  (1/2)*0.868976
obs$distance.to.obs[obs$type %in% "BOTD" & obs$comment %in% "; distance: 1/8mi"] =  (1/8)*0.868976
obs$distance.to.obs[obs$type %in% "BOTD" & obs$comment %in% "; distance: 1mi"] = 0.868976
# ---------- #


# ---------- #
# dates
# ---------- #
# date errors were in naming - fixed file name errors
# ---------- #


# # ---------- # 
# # condition
# # ---------- # 
# # ---------- # 
# 
# 
# # ---------- # 
# # offline
# # ---------- # 
# ##--------------------------##
# 
