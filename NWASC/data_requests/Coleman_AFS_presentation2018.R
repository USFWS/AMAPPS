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
spp = dbGetQuery(db, "select * from lu_species")

# old data
db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
old_obs = dbGetQuery(db,"select observation_id, spp_cd from observation")

# add new data to old
db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
obs <- sqlFetch(db, "observation")
mysteries = obs[obs $spp_cd %in% c('1','AWSD','COMD','DRSP','MOSP','SASP','SCRE','SPSP'),]

odbcClose(db)

obs = obs %>% mutate(observation_id = observation_id + 804175) %>%
  dplyr::select(observation_id, spp_cd)

# combine old and new
# creat month column
dat = bind_rows(old_obs,obs)
#add nyserda data in the works
#NYSERDA = NYSERDA %>% mutate(observation_id = row_number()+999957) %>% dplyr::select(observation_id, spp_cd)
dat = bind_rows(dat, NYSERDA)

all.dat = dat %>% 
  mutate(spp_cd = replace(spp_cd, spp_cd %in% c("UNPL","PEEP"), "SHOR"),
         spp_cd = replace(spp_cd, spp_cd %in% c("UNCT","CASP","RODO","LUDU",
                                                "RUTO","SHEA","SHSP"),"UNKN"),
         spp_cd = replace(spp_cd, spp_cd %in% "CRTE", "UCRT"), 
         spp_cd = replace(spp_cd, spp_cd %in% "KRILL", "ZOOP"),
         spp_cd = replace(spp_cd, spp_cd %in% "NONE", "UNKN"), 
         spp_cd = replace(spp_cd, spp_cd %in% "UNPI", "UNSE"), 
         spp_cd = replace(spp_cd, spp_cd %in% "GLSP","PIWH"), 
         spp_cd = replace(spp_cd, spp_cd %in% "ROTE", "ROST"),
         spp_cd = replace(spp_cd, spp_cd %in% "HEGU", "HERG"), 
         spp_cd = replace(spp_cd, spp_cd %in% "GULL", "UNGU"),
         spp_cd = replace(spp_cd, spp_cd %in% "3", "UNSC"),
         spp_cd = replace(spp_cd, spp_cd %in% "YTVI", "UNKN"),
         spp_cd = replace(spp_cd, spp_cd %in% "CAGO", "CANG"),
         spp_cd = replace(spp_cd, spp_cd %in% "BASW", "BARS"), 
         spp_cd = replace(spp_cd, spp_cd %in% "TRAW", "BOTD"), 
         spp_cd = replace(spp_cd, spp_cd %in% "SURF", "SUSC"), 
         spp_cd = replace(spp_cd, spp_cd %in% "UMMM", "UNMM"),
         spp_cd = replace(spp_cd, spp_cd %in% "PHAL", "UNPH"),
         spp_cd = replace(spp_cd, spp_cd %in% "TEAL", "UNTL"),
         spp_cd = replace(spp_cd, spp_cd %in% "TERN", "UNTE"),
         spp_cd = replace(spp_cd, spp_cd %in% "SKUA", "UNSK"),
         spp_cd = replace(spp_cd, spp_cd %in% "SCRE", "EASO"),
         spp_cd = replace(spp_cd, spp_cd %in% "COMD", "CODO"),
         spp_cd = replace(spp_cd, spp_cd %in% "SPSP", "UNSP"),
         spp_cd = replace(spp_cd, spp_cd %in% "MOSP", "UNMO"),
         spp_cd = replace(spp_cd, spp_cd %in% "DRSP", "GRDA"),
         spp_cd = replace(spp_cd, spp_cd %in% "SASP", "USAN")) %>%
  filter(!spp_cd %in% c("TRAN","BEGSEG","Comment","COMMENT","12","1","AWSD")) %>%
  left_join(., spp, by="spp_cd") 

# pull out bats as different type
#all.dat = mutate(all.dat, species_type_id = replace(species_type_id, spp_cd %in% c("REBA", "UBAT"),9))
# pull out balloons
#all.dat = mutate(all.dat, species_type_id = replace(species_type_id, spp_cd %in% c("BALN","LABA","MYBA"),10))


sum.dat = all.dat %>% 
  group_by(species_type_id) %>% 
  summarise(n = n()) %>% filter(!is.na(species_type_id))
all.dat = filter(all.dat, !is.na(species_type_id))


# plots
options(scipen=10000)

ggplot(sum.dat, aes(x = reorder(species_type_id,-n), y=n, 
                    fill=as.character(species_type_id),
                    col=as.character(species_type_id)))+
  geom_bar(stat="identity")+theme_bw()+
  geom_text(data=sum.dat,aes(x=reorder(species_type_id,-n),y=n,label=n),vjust=-0.2,size=10)+
  theme(legend.position = "none",
        text = element_text(size=22))+
  scale_x_discrete("Species Type", labels = c("1"="Seabirds","2"="Cetaceans","3"="Sea Turtles",
                                              "4"="Fishes","5"="Other","6"="Bugs","7"="Boats",
                                              "8"="Landbirds"))+
  ylab("Number of Records")
# ----- # 

# ----- # 
#
fishes = filter(all.dat, species_type_id %in% 4) %>% 
  mutate(grouping = NA, 
         grouping = replace(grouping, spp_cd %in% c("BASH","BLSH","DUSH","GHSH","GWSH","HASH",
                                                    "MAKO","OWTS","SCHA","SHAR","SHSH","SMSH",
                                                    "TISH","UNTS","WHSH","SPDF"), "Sharks"),
         grouping = replace(grouping, spp_cd %in% c("BLST","CNRA","GOMR","MARA",
                                                    "UNRA","UNSR"), "Rays"),
         grouping = replace(grouping, spp_cd %in% c("CAJE","MOON","PMOW","UNJE"), "Jellies"),
         grouping = replace(grouping, spp_cd %in% c("YETU","SKTU","BLAT","BFTU",
                                                    "ALTU","FAAL","TUNA","BONI",
                                                    "KIMA","WAHO","SPMA"),"Scombridae"), #tuna, mackerels, bonito
         grouping = replace(grouping, spp_cd %in% c("WHMA","SAIL","BLMA","BIFI","SWFI"),"Billfishes"),
         grouping = replace(grouping, spp_cd %in% c("THHE","BAIT"),"Forage Fishes"),
         #grouping = replace(grouping, spp_cd %in% c("KIMA","WAHO","SPMA"),"Spanish mackerels"),
         grouping = replace(grouping, spp_cd %in% c("MOLA","SHSU"),"Sunfishes"),
         grouping = replace(grouping, spp_cd %in% c("UFFI"),"Flying fish"),
         grouping = replace(grouping, spp_cd %in% c("UNLF","UNSF","FISH"),"Unidentified Fish"),
         grouping = replace(grouping, spp_cd %in% c("UNEL"), "Unidentified Elasmobranchii"),
         grouping = replace(grouping, spp_cd %in% c("HOCR"),"Horseshoe Crab"),
         grouping = replace(grouping, spp_cd %in% c("COBI"),"Cobia"),
         grouping = replace(grouping, spp_cd %in% c("BLUE"),"Bluefish"),
         grouping = replace(grouping, spp_cd %in% c("MAMA"),"Coryphaena")) #Dolphinfishes

sum.fish = fishes %>% 
  group_by(grouping) %>% 
  summarise(n = n()) 


ggplot(sum.fish, aes(x = reorder(grouping, n), y = n, 
                     fill=grouping, col=grouping))+
  geom_bar(stat="identity")+
  geom_text(data=sum.fish,aes(x=reorder(grouping,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=25))+
  ylab("Number of Records")+
  xlab("Species Groupings")+ 
  scale_y_continuous(limits=c(0,61500))
# ----- # 

# ----- # 
sum.turt = all.dat %>% 
  filter() %>% 
  summarise(n = n()) 


ggplot(sum.fish, aes(x = reorder(grouping, n), y = n, 
                     fill=grouping, col=grouping))+
  geom_bar(stat="identity")+
  geom_text(data=sum.fish,aes(x=reorder(grouping,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=25))+
  ylab("Number of Records")+
  xlab("Species Groupings")+ 
  scale_y_continuous(limits=c(0,61500))
