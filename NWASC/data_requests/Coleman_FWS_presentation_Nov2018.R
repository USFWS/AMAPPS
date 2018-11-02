# --------------- #
# Oct. 2018
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
# db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
# spp = dbGetQuery(db, "select * from lu_species")
# odbcClose(db)
# # 
# # old data
# db <- dbConnect(odbc::odbc(), driver='SQL Server',server='ifw9mbmsvr008', database='SeabirdCatalog')
# old_obs = dbGetQuery(db,"select observation_id, spp_cd from observation")
# 
# # add new data to old
# db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
# obs <- sqlFetch(db, "observation")
# mysteries = obs[obs $spp_cd %in% c('1','AWSD','COMD','DRSP','MOSP','SASP','SCRE','SPSP'),]
# 
# odbcClose(db)
# 
# obs = obs %>% mutate(observation_id = observation_id + 804175) %>%
#   dplyr::select(observation_id, spp_cd)
# 
# # combine old and new
# # creat month column
# dat = bind_rows(old_obs,obs)
# #add nyserda data in the works
# #NYSERDA = NYSERDA %>% mutate(observation_id = row_number()+999957) %>% dplyr::select(observation_id, spp_cd)
# dat = bind_rows(dat, NYSERDA)
# 
# all.dat = dat %>% 
#   mutate(spp_cd = replace(spp_cd, spp_cd %in% c("UNPL","PEEP"), "SHOR"),
#          spp_cd = replace(spp_cd, spp_cd %in% c("UNCT","CASP","RODO","LUDU",
#                                                 "RUTO","SHEA","SHSP"),"UNKN"),
#          spp_cd = replace(spp_cd, spp_cd %in% "CRTE", "UCRT"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "KRILL", "ZOOP"),
#          spp_cd = replace(spp_cd, spp_cd %in% "NONE", "UNKN"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "UNPI", "UNSE"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "GLSP","PIWH"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "ROTE", "ROST"),
#          spp_cd = replace(spp_cd, spp_cd %in% "HEGU", "HERG"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "GULL", "UNGU"),
#          spp_cd = replace(spp_cd, spp_cd %in% "3", "UNSC"),
#          spp_cd = replace(spp_cd, spp_cd %in% "YTVI", "UNKN"),
#          spp_cd = replace(spp_cd, spp_cd %in% "CAGO", "CANG"),
#          spp_cd = replace(spp_cd, spp_cd %in% "BASW", "BARS"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "TRAW", "BOTD"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "SURF", "SUSC"), 
#          spp_cd = replace(spp_cd, spp_cd %in% "UMMM", "UNMM"),
#          spp_cd = replace(spp_cd, spp_cd %in% "PHAL", "UNPH"),
#          spp_cd = replace(spp_cd, spp_cd %in% "TEAL", "UNTL"),
#          spp_cd = replace(spp_cd, spp_cd %in% "TERN", "UNTE"),
#          spp_cd = replace(spp_cd, spp_cd %in% "SKUA", "UNSK"),
#          spp_cd = replace(spp_cd, spp_cd %in% "SCRE", "EASO"),
#          spp_cd = replace(spp_cd, spp_cd %in% "COMD", "CODO"),
#          spp_cd = replace(spp_cd, spp_cd %in% "SPSP", "UNSP"),
#          spp_cd = replace(spp_cd, spp_cd %in% "MOSP", "UNMO"),
#          spp_cd = replace(spp_cd, spp_cd %in% "DRSP", "GRDA"),
#          spp_cd = replace(spp_cd, spp_cd %in% "SASP", "USAN")) %>%
#   filter(!spp_cd %in% c("TRAN","BEGSEG","Comment","COMMENT","12","1","AWSD")) %>%
#   left_join(., spp, by="spp_cd") 

# pull out bats as different type
#all.dat = mutate(all.dat, species_type_id = replace(species_type_id, spp_cd %in% c("REBA", "UBAT"),9))
# pull out balloons
#all.dat = mutate(all.dat, species_type_id = replace(species_type_id, spp_cd %in% c("BALN","LABA","MYBA"),10))

library(readr)
all.dat <- read_csv("Z:/seabird_database/data_sent/TWhite_archive_Oct2018/obs_Oct2018.csv")
dir.out = "//ifw-hqfs1/MB SeaDuck/seabird_database/data_sent/Coleman_2018_presentation/"

db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
spp = dbGetQuery(db, "select * from lu_species")
stc = dbGetQuery(db, "select * from lu_species_type")
odbcClose(db)
all.dat = all.dat %>%  left_join(., spp, by="spp_cd") %>% left_join(., stc, by="species_type_id") 

load("C:/Users/kecoleman/Downloads/species_group_lookup.RData")
x = select(species_group_lookup,SpeciesId, GroupId, Name) %>% rename(spp_cd = SpeciesId)
all.dat = left_join(all.dat, x, by="spp_cd")
rm(x)

aou_list =  read_csv("C:/Users/kecoleman/Downloads/NACC_list_species.csv")
#aou_sum = aou_list %>% group_by(order) %>% summarise(g = paste(unique(genus), collapse = ","))
aou_sum = aou_list %>% group_by(order) %>% summarise(g = list(unique(genus)),
                                                     o = list(rep(unique(order),length(unique(genus)))))
aou_sum_list = as.data.frame(cbind(unlist(aou_sum$o), unlist(aou_sum$g)))
names(aou_sum_list) = c("order2","genus")
aou_sum_list = mutate(aou_sum_list, genus = tolower(genus))

aou_list =  mutate(aou_list, genus = tolower(genus), species = tolower(species)) %>% 
  rename(gspecies = species) %>%
  select(order, family, subfamily, gspecies)
all.dat =  mutate(all.dat, genus = tolower(genus), species = tolower(species),
                  gspecies = paste(genus, species, sep = " ")) %>% 
  select(-order, -family, -subfamily)
all.dat = left_join(all.dat, aou_list, by=c("gspecies"))
all.dat = left_join(all.dat, aou_sum_list, by=c("genus"))


sum.dat = all.dat %>% 
  #group_by(species_type_id) %>% 
  group_by(species_type_ds,species_type_id) %>% 
  summarise(n = n()) %>% filter(!is.na(species_type_id))
all.dat = filter(all.dat, !is.na(species_type_id))


# plots
options(scipen=10000)

p = ggplot(sum.dat, aes(x = reorder(species_type_id,n), y=n, 
                    fill=as.character(species_type_id),
                    col=as.character(species_type_id)))+
  geom_bar(stat="identity")+theme_bw()+
  coord_flip()+
  geom_text(data=sum.dat,aes(x=reorder(species_type_id,n),y=n,label=n),hjust=0,size=10)+#vjust=-0.2,
  theme(legend.position = "none",
        text = element_text(size=22))+
  scale_x_discrete("Species Type", labels = c("1"="Seabirds","2"="Marine Mammals","3"="Sea Turtles",
                                              "4"="Fishes","5"="Other","6"="Bugs","7"="Boats",
                                              "8"="Landbirds"))+
  ylab("Number of Records")+ 
  scale_y_continuous(limits=c(0,700000))
p 
ggsave(paste(dir.out, "summary.png",sep=""), p)
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
sum.turt = filter(all.dat, species_type_id %in% 3) %>% 
  mutate(common_name = replace(common_name, common_name %in% c("Unidentified Cheloniidae species (Green Sea Turtle, Hawksbill Sea Turtle, and Flatback Sea Turtle)",
                               "Unidentified Small turtle - Loggerhead, Green, Hawksbill, or Kemp's Ridley"),
                               "Unidentified Sea Turtle")) %>% 
  group_by(common_name) %>% #summarise(n=n()) 
  summarise(counts = sum("obs_count_intrans_nb"),
            counts2 = sum("obs_count_general_nb"),
            n=n())
  
p = ggplot(sum.turt, aes(x = reorder(common_name, n), y = n, 
                     fill=common_name, col=common_name))+
  geom_bar(stat="identity")+
  geom_text(data=sum.turt,aes(x=reorder(common_name,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=25))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,3200))
p
ggsave(paste(dir.out, "seaturtles.png",sep=""), p)
# ----- # 


# ----- # 
# BUGS 
# ----- #
sum.bugs = filter(all.dat, species_type_id %in% 6) %>% 
  mutate(common_name = replace(common_name, spp_cd %in% c("BDDR","GRDA","DRAG","SWDA","WAGL"),"Dragonfly"),
         common_name = replace(common_name, spp_cd %in% c("UNMO"),"Moth"),
         common_name = replace(common_name, spp_cd %in% c("BUMB"),"Bee"),
         common_name = replace(common_name, spp_cd %in% c("BSTB","GISW","MONA","PLBU","SUBU",
                                                          "ORSU","CLSU","UBUT"),"Butterfly")) %>%
  group_by(common_name) %>% summarise(n=n()) 
  
p = ggplot(sum.bugs, aes(x = reorder(common_name, n), y = n, 
                         fill=common_name, col=common_name))+
  geom_bar(stat="identity")+
  geom_text(data=sum.bugs,aes(x=reorder(common_name,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=25))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,300))
p
ggsave(paste(dir.out, "bugs.png",sep=""), p)
# ----- # 




# ----- # 
# MARINE MAMMALS
# ----- #
# sum.mm = filter(all.dat, species_type_id %in% 2) %>% group_by(common_name) %>% summarise(n=n()) %>%
#   mutate(common_name = replace(common_name, common_name %in% c("Unidentified Baleen Whale","Unidentified Dwarf/Pygmy Sperm Whale",
#                                                                "Unidentified Fin/Sei whale","Unidentified large whale",
#                                                                "Unidentified small whale","Unidentified Toothed Whales",
#                                                                "Unidentified Beaked Whale","Unidentified Rorqual",
#                                                                "Unidentified Ziphiid (beaked whale)"),
#                                "Unidentified Whale"),
#          common_name = replace(common_name, common_name %in% c("Common Dolphin","Unidentified Common Dolphins"),
#                                "Unidentified Common Dolphin"),
#          common_name = replace(common_name, common_name %in% c("Unidentified Spotted Dolphins (Atlantic or Pantropical)"),
#                                "Unidentified Dolphin"),
#          common_name = replace(common_name, common_name %in% c("Unidentified Cetacean"),"Unidentified Marine Mammal")) %>% 
#          group_by(common_name) %>% summarise(n=sum(n)) 
sum.mm = filter(all.dat, species_type_id %in% 2) %>% 
  mutate(common_name2 = sapply(strsplit(common_name," "),tail,1),
         common_name2 = replace(common_name2, common_name2 %in% c("Whales","whale","whale)","Rorqual"),"Whale"),
         common_name2 = replace(common_name2, common_name2 %in% c("Dolphins","dolphin","Pantropical)"),"Dolphin"),
         common_name2 = replace(common_name2, common_name2 %in% "porpoise","Porpoise"),
         common_name2 = replace(common_name2, common_name2 %in% "Mammal","Unidentified Marine Mammal"),
         common_name2 = replace(common_name2, common_name2 %in% "Cetacean","Unidentified Cetacean")) %>% 
  group_by(common_name2) %>% summarise(n=n()) 

p = ggplot(sum.mm, aes(x = reorder(common_name2, n), y = n, 
                         fill=common_name2, col=common_name2))+
  geom_bar(stat="identity")+
  geom_text(data=sum.mm,aes(x=reorder(common_name2,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=20))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,10000))
p
ggsave(paste(dir.out, "marinemammals.png",sep=""), p)
# ----- # 



# ----- # 
# OTHER
# ----- #
sum.ot = filter(all.dat, species_type_id %in% 5) %>% 
  mutate(common_name2 = as.character(common_name),
         common_name2 = replace(common_name2, spp_cd %in% c("BALN","MYBA","PLAS","FUEL","FLJE",
                                                                  "LABA"), "Marine debris"),
         common_name2 = replace(common_name2, spp_cd %in% c("SARG","RCKW","ALGA","MACR"), "Aquatic plants"),
         common_name2 = replace(common_name2, spp_cd %in% c("TOWR","ANTE"), "Man-made obstacles"),
         common_name2 = replace(common_name2, spp_cd %in% c("SPEN","FGGI","FGLO","FGUN",
                                                                  "FIGE","BUOY"), "Fishing gear"),
         common_name2 = replace(common_name2, spp_cd %in% c("UBAT","REBA"),"Bats"),
         common_name2 = replace(common_name2, common_name2 %in% c("zooplankton"),"Zooplankton"),
         common_name2 = replace(common_name2, common_name2 %in% c("ocean front"),"Ocean front"),
         common_name2 = replace(common_name2, spp_cd %in% c("CHAN","ERRO"),"Field notes"),
         common_name2 = replace(common_name2, spp_cd %in% c("UNKN","UFOB"),"Unknown")) %>% 
  group_by(common_name2) %>% summarise(n=n()) 
 
p = ggplot(sum.ot, aes(x = reorder(common_name2, n), y = n, 
                       fill=common_name2, col=common_name2))+
  geom_bar(stat="identity")+
  geom_text(data=sum.ot,aes(x=reorder(common_name2,n),y=n,label=n),hjust=-0.1,size=5)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=15))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,18000))
p
ggsave(paste(dir.out, "other.png",sep=""), p)
# ----- # 



# ----- # 
# LANDBIRDS
# ----- #
sum.lb = filter(all.dat, species_type_id %in% 8) %>% 
  mutate(order2 = replace(order2, common_name %in% c("Black-throated Blue Warbler","Black-throated Green Warbler",                      
                                                     "Blackburnian Warbler","Blackpoll Warbler",                                 
                                                     "Cape May Warbler","Common or Hoary Redpoll",                           
                                                     "Hooded Warbler","Magnolia Warbler",                                  
                                                     "Myrtle Warbler","Northern Parula",
                                                     "Palm Warbler","Pine Warbler",                                      
                                                     "Prairie Warbler","Unidentified Blackbird",
                                                     "Unidentified Chickadee","Unidentified Vireo",                                
                                                     "Unidentified Warbler","Wilson's Warbler",                                  
                                                     "Yellow-rumped Warbler","Yellow Warbler",
                                                     "Unidentified Passerine (perching birds, songbirds)",
                                                     "Unidentified Vermivora","Unidentified Thrush",
                                                     "Unidentified Tanager","Unidentified junco",
                                                     "Unidentified sparrow","Unidentified Swallow"),
                          "Passeriformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Buteo","Unidentified small Accipiter",
                                                     "Unidentified Raptor/ bird of prey"),
                          "Accipitriformes"),
         order2 = replace(order2, common_name %in% c("Unidentified falcon","Unidentified hawk"),
                          "Falconiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Nighthawk"),
                          "Caprimulgiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Owl","Unidentified small owl"),
                          "Strigiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Hummingbird"),
                          "Apodiformes"),
         grouping = NA,
         grouping = replace(grouping, order2 %in% "Accipitriformes","Eagles & Vultures (Accipitriformes)"),  
         grouping = replace(grouping, order2 %in% "Anseriformes","Waterfowl (Anseriformes)"),      
         grouping = replace(grouping, order2 %in% "Apodiformes","Hummingbirds & Swifts (Apodiformes)"),       
         grouping = replace(grouping, order2 %in% "Caprimulgiformes","Nightjars & Nighthawks (Caprimulgiformes)"),  
         grouping = replace(grouping, order2 %in% "Cathartiformes","New World Vutures (Cathartiformes)"),    
         grouping = replace(grouping, order2 %in% "Columbiformes","Pigeons & Doves (Columbiformes)"),     
         grouping = replace(grouping, order2 %in% "Coraciiformes","Kingfishers (Coraciiformes)"),    
         grouping = replace(grouping, order2 %in% "Cuculiformes","Cuckoos (Cuculiformes)"),      
         grouping = replace(grouping, order2 %in% "Falconiformes","Falcons & Caracaras (Falconiformes)"),     
         grouping = replace(grouping, order2 %in% "Galliformes","Landfowl (Galliformes)"),       
         grouping = replace(grouping, order2 %in% "Passeriformes","Perching Birds (Passeriformes)"),     
         grouping = replace(grouping, order2 %in% "Piciformes","Woodpeckers (Piciformes)"),        
         grouping = replace(grouping, order2 %in% "Strigiformes","Owls (Strigiformes)")) %>% 
  group_by(grouping) %>% summarise(n=n()) 
  
  p = ggplot(sum.lb, aes(x = reorder(grouping, n), y = n, 
                         fill=grouping, col=grouping))+
    geom_bar(stat="identity")+
    geom_text(data=sum.lb,aes(x=reorder(grouping,n),y=n,label=n),hjust=-0.1,size=10)+
    theme_bw()+
    coord_flip()+
    theme(legend.position = "none",
          text = element_text(size=20))+
    ylab("Number of Records")+
    xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,5500))
  p
  ggsave(paste(dir.out, "landbirds.png",sep=""), p)
  
  # mutate(common_name = replace(common_name, common_name %in% c("American Tree Sparrow","Chipping Sparrow","Field Sparrow",
  #                                                              "Fox Sparrow","Grasshopper Sparrow","House Sparrow",
  #                                                              "Lincoln's Sparrow","Nelson's Sharp-tailed Sparrow",
  #                                                              "Savannah Sparrow","Song Sparrow","Swamp Sparrow",
  #                                                              "Unidentified sparrow","Vesper Sparrow",
  #                                                              "White-crowned Sparrow","White-throated Sparrow",
  #                                                              "Unidentified Seaside or Sharptailed Sparrow"),
  #                              "Sparrows"),
  #        common_name = replace(common_name, common_name %in% c("Bank Swallow","Barn Swallow","Cliff Swallow",
  #                                                              "Northern Rough-winged Swallow","Rough-Winged Swallow",
  #                                                              "Tree Swallow","Unidentified Swallow"),
  #                              "Swallows"),
  #        common_name = replace(common_name, common_name %in% c("Black-and-white Warbler","Black-throated Blue Warbler","Black-throated Green Warbler",
  #                                                              "Blackburnian Warbler","Blackpoll Warbler","Blue-winged Warbler",
  #                                                              "Canada Warbler","Cape May Warbler","Hooded Warbler",
  #                                                              "Magnolia Warbler","Mourning Warbler","Myrtle Warbler",
  #                                                              "Nashville Warbler","Orange-crowned Warbler","Palm Warbler",
  #                                                              "Pine Warbler","Prairie Warbler","Prothonotary Warbler",
  #                                                              "Tennessee Warbler","Unidentified Warbler",
  #                                                              "Wilson's Warbler","Yellow-rumped Warbler","Yellow Warbler"),
  #                              "Warblers"),
  #        common_name = replace(common_name, common_name %in% c("Barn Owl","Barred Owl","Eastern Screech-Owl","Great Horned Owl",
  #                                                              "Long-eared Owl","Northern Hawk Owl","Northern Saw-whet Owl",
  #                                                              "Short-eared Owl","Snowy Owl","Unidentified Owl",
  #                                                              "Unidentified small owl"),
  #                              "Owls"),
  #        common_name = replace(common_name, common_name %in% c("Cooper's Hawk","Red-shouldered Hawk","Red-tailed Hawk",
  #                                                              "Rough-legged Hawk","Sharp-shinned Hawk","Unidentified Accipiter Hawk",
  #                                                              "Unidentified hawk","Unidentified small Accipiter",
  #                                                              "Northern Goshawk","Northern Harrier"),
  #                              "Hawks"),
  #        common_name = replace(common_name, common_name %in% c("Carolina Wren","House Wren","Marsh Wren","Sedge Wren",
  #                                                              "Winter Wren"),
  #                              "Wrens"),
  #        common_name = replace(common_name, common_name %in% c("Black-backed Woodpecker","Downy Woodpecker","Hairy Woodpecker",
  #                                                              "Pileated Woodpecker","Red-headed Woodpecker","Red-bellied Woodpecker"),"Woodpeckers"),
  #        common_name = replace(common_name, common_name %in% c("Black-capped Chickadee","Boreal Chickadee","Carolina Chickadee",
  #                                                              "Unidentified Chickadee"),
  #                              "Chickadees"),
  #        common_name = replace(common_name, common_name %in% c("Common or Hoary Redpoll","Common Redpoll","Hoary Redpoll"), 
  #                              "Redpoll"),
  #        common_name = replace(common_name, common_name %in% c("Loggerhead Shrike","Northern Shrike"), 
  #                              "Shrikes"),
  #        common_name = replace(common_name, common_name %in% c("Baltimore Oriole","Orchard Oriole","Unidentified Oriole"), 
  #                              "Orioles"),
  #        common_name = replace(common_name, common_name %in% c("Ruby-throated Hummingbird","Unidentified Hummingbird"), 
  #                              "Hummingbirds"),
  #        common_name = replace(common_name, common_name %in% c("Black-billed Cuckoo","Yellow-billed Cuckoo"), 
  #                              "Cuckoos"),
  #        common_name = replace(common_name, common_name %in% c("Yellow-bellied Flycatcher","Unidentified Flycatcher",
  #                                                              "Great Crested Flycatcher"),
  #                              "Flycatchers"),
  #        common_name = replace(common_name, common_name %in% c("Bohemian Waxwing","Cedar Waxwing"),
  #                              "Waxwings"),
  #        common_name = replace(common_name, common_name %in% c("Unidentified Blackbird","Yellow-headed Blackbird","Rusty Blackbird",
  #                                                                "Red-winged Blackbird","Brewer's Blackbird"),
  #                              "Blackbirds"),
  #        common_name = replace(common_name, common_name %in% c("Boat-tailed Grackle","Common Grackle"),
  #                              "Grackles"),
  #        common_name = replace(common_name, common_name %in% c("Ruby-crowned Kinglet","Golden-crowned Kinglet"),
  #                              "Kinglet"),
  #        common_name = replace(common_name, common_name %in% c("Spruce Grouse","Ruffed Grouse"),
  #                              "Grouse"),
  #        common_name = replace(common_name, common_name %in% c("Unidentified Crow","American Crow","Fish Crow"),
  #                              "Crows"),
  #        common_name = replace(common_name, common_name %in% c("White-eyed Vireo","Unidentified Vireo","Red-eyed Vireo","Philadelphia Vireo"),
  #                              "Vireos"),
  #        common_name = replace(common_name, common_name %in% c("House Finch","Unidentified Finch","Purple Finch"),
  #                              "Finches"),
  #        common_name = replace(common_name, common_name %in% c("Common Nighthawk","Unidentified Nighthawk"),
  #                              "Nighthawks"),
  #        common_name = replace(common_name, common_name %in% c("Unidentified falcon","Peregrine Falcon","American Kestrel"),
  #                              "Falcons"),
  #        common_name = replace(common_name, common_name %in% c("White-winged Dove","Mourning Dove","Eurasian Collared-Dove","Ringed Turtle-Dove"),
  #                              "Doves"),
  #        common_name = replace(common_name, common_name %in% c("Red-breasted Nuthatch","White-breasted Nuthatch"),
  #                              "Nuthatches"),
  #        common_name = replace(common_name, common_name %in% c("Eastern Kingbird","Gray Kingbird"),
  #                              "Kingbirds"),
  #        common_name = replace(common_name, common_name %in% c("Dark-eyed Junco","Unidentified junco"),
  #                              "Juncos"),
  #        common_name = replace(common_name, common_name %in% c("Evening Grosbeak","Pine Grosbeak","Rose-breasted Grosbeak"),
  #                              "Grosbeaks"),
  #        common_name = replace(common_name, common_name %in% c("Black Vulture","Turkey Vulture"),
  #                              "Vultures"),
  #        common_name = replace(common_name, common_name %in% c("Eastern Meadowlark","Unidentified Meadowlark"),
  #                              "Meadowlarks"),
  #        common_name = replace(common_name, common_name %in% c("Lapland Longspur","Unidentified Longspur"),
  #                              "Longspurs"),
  #        common_name = replace(common_name, common_name %in% c("Hermit Thrush","Unidentified Thrush"),
  #                              "Thrushes"),
  #        common_name = replace(common_name, common_name %in% c("Indigo Bunting","Snow Bunting"),
  #                              "Buntings"),
  #        common_name = replace(common_name, common_name %in% c("Scarlet Tanager","Unidentified Tanager"),
  #                              "Tanagers"),
  #        common_name = replace(common_name, common_name %in% c("Sprague's Pipit","American Pipit","Water Pipit"),
  #                              "Pipits"),
  #        common_name = replace(common_name, common_name %in% c("Red Crossbill", "White-winged Crossbill"),
  #                              "Crossbills")) %>%
  # group_by(common_name) %>% summarise(n=sum(n)) 
#-------#



# ----- # 
# BOATS
# ----- #
sum.boats = filter(all.dat, species_type_id %in% 7) %>% 
  mutate(common_name = replace(common_name, spp_cd %in% c("BOAT"),"Unidentified Boat"),
         common_name = replace(common_name, spp_cd %in% c("BOCR","BOPL","BOSA","BOWW","BOYA"),"Pleasure Boat"),
         common_name = replace(common_name, spp_cd %in% c("BOCF","BOFI","BOLO","BOPS","BORF",
                                                          "BOTD"),"Fishing Boat"),
         common_name = replace(common_name, spp_cd %in% c("BOBA","BOCA","BOCG","BOCS","BOFE",
                                                          "BOME","BONA","BORV","BOTA","BOTU",
                                                          "BOAC"),"Working Boat"),
         common_name = replace(common_name, spp_cd %in% c("BOSU"),"Submarine")) %>%
  group_by(common_name) %>% summarise(n=n()) 

p = ggplot(sum.boats, aes(x = reorder(common_name, n), y = n, 
                       fill=common_name, col=common_name))+
  geom_bar(stat="identity")+
  geom_text(data=sum.boats,aes(x=reorder(common_name,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=25))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
  scale_y_continuous(limits=c(0,1700))
p
ggsave(paste(dir.out, "boats.png",sep=""), p)
# ----- # 



# ----- # 
sum.birds = filter(all.dat, species_type_id %in% 1) %>% 
  mutate(order2 = replace(order2, common_name %in% c("Unidentified Tern","Unidentified shorebird",
                                                     "Unidentified Gull","Unidentified small Tern",                       
                                                     "Unidentified large Tern","Unidentified Common or Roseate Tern",
                                                     "Unidentified small shorebird","Unidentified large shorebird",
                                                     "Unidentified Large Gull","Willet",
                                                     "Unidentified Noddy Tern","Bridled or Sooty Tern",                         
                                                     "Common or Arctic Tern","Unidentified Sandpiper",                        
                                                     "Unidentified Great or Lesser Black-backed Gull",
                                                     "Glaucous Gull X Herring Gull (hybrid)",
                                                     "Unidentified Small Gull/Tern","Unidentified medium tern",
                                                     "Unidentified Charadriiform","Unidentified small gull",
                                                     "Unidentified Great Black-backed/Herring Gull",
                                                     "Unidentified large alcid (Razorbill or Murre)",
                                                     "Unidentified Alcid","Unidentified Goldeneye or Merganser",           
                                                     "Unidentified small alcid (Puffin/Dovekie)"), 
                          "Charadriiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Storm-petrel","Unidentified Petrel",
                                                     "Unidentified tubenose","Unidentified Albatross",
                                                     "Unidentified Shearwater","Unidentified Large Shearwater"),
                          "Procellariiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Duck","Unidentified Duck",
                                                     "Unidentified Duck, Goose, or Swan","Unidentified Goose",
                                                     "Snow Goose","Unidentified Scaup","Unidentified Swan",
                                                     "Unidentified Teal","Unidentified Dark scoter - black or surf",
                                                     "Unidentified Merganser"),
                          "Anseriformes"),
         order2 = replace(order2, common_name %in% "Unidentified Sulid",
                          "Suliformes"),
         order2 = replace(order2, common_name %in% c("Arctic Loon/Pacific Loon"),
                          "Gaviiformes"),
         order2 = replace(order2, common_name %in% c("Unidentified Night Heron","Unidentified Heron",
                                                     "Unidentified Egret"),
                          "Pelecaniformes"),
         order2 = replace(order2, common_name %in% c("Unidentified large rail"),
                          "Gruiformes"),
         grouping = "Unidentified Bird",
         grouping = replace(grouping, order2 %in% "Charadriiformes", "Shorebirds (Charadriiformes)"),
         grouping = replace(grouping, order2 %in% "Anseriformes", "Waterfowl (Anseriformes)"),
         grouping = replace(grouping, order2 %in% "Suliformes", "Gannets (Suliformes)"),
         grouping = replace(grouping, order2 %in% "Procellariiformes", "Petrels (Procellariiformes)"),
         grouping = replace(grouping, order2 %in% "Gaviiformes", "Loons (Gaviiformes)"),
         grouping = replace(grouping, order2 %in% "Pelecaniformes", "Pelicans & Herons (Pelecaniformes)"),
         grouping = replace(grouping, order2 %in% "Podicipediformes", "Grebes (Podicipediformes)"),
         grouping = replace(grouping, order2 %in% "Phaethontiformes", "Tropicbirds (Phaethontiformes)"),
         grouping = replace(grouping, order2 %in% "Gruiformes", "Cranes & Rails (Gruiformes)")) %>%
  group_by(grouping) %>% summarise(n=n())


# mutate(grouping = Name,
#        grouping = replace(grouping, grouping %in% c("Large Gulls","Small Gulls"), "Gulls"),
#        grouping = replace(grouping, grouping %in% c("Dark-Winged Scoters"), "Scoters"),
#        grouping = replace(grouping, grouping %in% c("scaup"), "Scaup"),
#        grouping = replace(grouping, grouping %in% c("Sea ducks","Diving Ducks","Dabbling Ducks"), "Ducks"),
#        grouping = replace(grouping, grouping %in% c("Herons","Egrets"), "Herons and Egrets"),
#        grouping = replace(grouping, grouping %in% c("Storm Petrels","Petrels"), "Petrels and Storm Petrels"),
#        grouping = replace(grouping, grouping %in% c("Mergansers","Goldeneyes"), "Goldeneyes & Mergansers"),
#        grouping = replace(grouping, grouping %in% c("Large Terns","Small Terns","Medium Terns"),"Terns")) %>%
  
  # #group_by(common_name) %>% summarise(n=n()) %>%
  # mutate(grouping = sapply(strsplit(sum.birds$common_name, " "), tail, 1),
  #        grouping = toupper(grouping),
  #        grouping = as.character(grouping),
  #        grouping = replace(grouping, grouping %in% "MURRE)","MURRE"),
  #        grouping = replace(grouping, grouping %in% "GULL)","GULL"),
  #        grouping = replace(grouping, grouping %in% "KNOT)","KNOT"),
  #        grouping = replace(grouping, grouping %in% "PETREL)","PETREL"),
  #        grouping = replace(grouping, grouping %in% "Glaucous Gull X Herring Gull (hybrid)","GULL"),
  #        grouping = replace(grouping, grouping %in% c("PUFFIN/DOVKIE","LITTE","SPP."),"BIRD")) %>% 
  # arrange(grouping) %>% 

p = ggplot(sum.birds, aes(x = reorder(grouping, n), y = n,
                          fill=grouping, col=grouping))+
  geom_bar(stat="identity")+
  geom_text(data=sum.birds,aes(x=reorder(grouping,n),y=n,label=n),hjust=-0.1,size=10)+
  theme_bw()+
  coord_flip()+
  theme(legend.position = "none",
        text = element_text(size=20))+
  ylab("Number of Records")+
  xlab("Species or Grouping")+ 
scale_y_continuous(limits=c(0,250000))
p
ggsave(paste(dir.out, "birds.png",sep=""), p)

  
  # mutate(common_name = replace(common_name, common_name %in% c("Black-tailed Gull","Bonaparte's Gull","Common Black-headed Gull",
  #                                                              "Franklin's Gull","Great Black-backed Gull","Herring Gull",
  #                                                              "Iceland Gull","Ivory Gull","Kumlien's Gull","Laughing Gull",
  #                                                              "Lesser Black-backed Gull","Little Gull","Ring-billed Gull",
  #                                                              "Sabine's Gull","Unidentified Large Gull","Unidentified small gull",
  #                                                              "Glaucous Gull","Glaucous Gull X Herring Gull (hybrid)",
  #                                                              "Thayer's Gull","Unidentified Great Black-backed/Herring Gull",
  #                                                              "Unidentified Great or Lesser Black-backed Gull","California Gull",
  #                                                              "Unidentified white winged gull (Ross's Gull, Ivory Gull, Iceland Gull, Glaucous-winged Gull and Glaucous Gull)"),
  #                              "Gulls"),
  #        common_name = replace(common_name, common_name %in% c("Audubon's Shearwater","Cape Verde Shearwater","Greater Shearwater",
  #                                                              "Little Shearwater","Manx Shearwater","Sooty Shearwater",
  #                                                              "Unidentified Large Shearwater","Unidentified Shearwater",
  #                                                              "Unidentified Small Shearwater (Audubon's, Manx, or Little"),
  #                              "Shearwaters"),
  #        common_name = replace(common_name, common_name %in% c("Arctic Tern","Black Tern","Bridled or Sooty Tern","Bridled Tern",
  #                                                              "Caspian Tern","Gull-billed Tern","Least Tern","Little Tern",
  #                                                              "Roseate Tern","Royal Tern","Sandwich Tern","Sooty Tern",
  #                                                              "Unidentified large Tern","Unidentified Noddy Tern",
  #                                                              "Unidentified medium tern","Unidentified small Tern",
  #                                                              "Forster's Tern","Unidentified Common or Roseate Tern"),
  #                              "Terns"),
  #        common_name = replace(common_name, common_name %in% c("Band-rumped Storm-petrel","Black-bellied Storm-petrel",
  #                                                              "Black Storm-petrel","European Storm-petrel","Leach's Storm-petrel",
  #                                                              "Least Storm-petrel","Swinhoe's Storm-petrel","Tristram's Storm-Petrel",
  #                                                              "Unidentified Storm-petrel","White-faced Storm-petrel",
  #                                                              "Wilson's Storm-petrel"),
  #                              "Storm-petrels"),
  #        common_name = replace(common_name, common_name %in% c("Baird's Sandpiper","Least Sandpiper","Pectoral Sandpiper",
  #                                                              "Purple Sandpiper","Semipalmated Sandpiper","Solitary Sandpiper",
  #                                                              "Spotted Sandpiper","Stilt Sandpiper","Unidentified Sandpiper",
  #                                                              "Western Sandpiper"),
  #                              "Sandpipers"),
  #        common_name = replace(common_name, common_name %in% c("Bermuda Petrel","Black-capped Petrel","Bulwer's Petrel",
  #                                                              "Fea's Petrel (aka Cape Verde Petrel)","Herald/Trinidad Petrel",
  #                                                              "Unidentified Petrel"),
  #                              "Petrels")) %>%
  # group_by(common_name) %>% summarise(n=sum(n)) 

# p = ggplot(sum.birds, aes(x = reorder(common_name, n), y = n, 
#                           fill=common_name, col=common_name))+
#   geom_bar(stat="identity")+
#   geom_text(data=sum.birds,aes(x=reorder(common_name,n),y=n,label=n),hjust=-0.1,size=5)+
#   theme_bw()+
#   coord_flip()+
#   theme(legend.position = "none",
#         text = element_text(size=15))+
#   ylab("Number of Records")+
#   xlab("Species or Grouping")#+ 
# #scale_y_continuous(limits=c(0,18000))
# p
# ggsave(paste(dir.out, "birdss.png",sep=""), p)
# ----- # 



