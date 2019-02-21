#---------------------#
# format FWS Maine Whale Watch cruise data
# 2008 + 2009
# no effort
#---------------------#


#---------------------#
# load packages
#---------------------#
require(dplyr) # %>% 
library(readxl)
#---------------------#


#---------------------#
# set paths
#---------------------#
dir.in <- "//ifw-hqfs1/MB SeaDuck/seabird_database/datasets_received/FWS/LindaWelch/"
dir.out <-"//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/FWS_ME_0910" 
#---------------------#


#---------------------#
# load data
#---------------------#
filenames = list.files(dir.in, full.names=TRUE)
#lapply(filenames, function(i) {read_excel(i)}) # formats are not the same
Jun09 = read_excel(filenames[1]) %>% mutate(group = "Jun09")
Oct09 = read_excel(filenames[2]) %>% mutate(group = "Oct09")
Sep09 = read_excel(filenames[3]) %>% mutate(group = "Sep09")
Aug09A = read_excel(filenames[4]) %>% mutate(group = "Aug09A")
Aug09B = read_excel(filenames[5]) %>% mutate(group = "Aug09B")
Aug10 = read_excel(filenames[6], skip = 5, col_names = FALSE) %>% mutate(group = "Aug10")# summary table up top in excel )
Jul10 = read_excel(filenames[7], skip = 6, col_names = FALSE) %>% mutate(group = "Jul10")# summary table up top in excel 
Jun10 = read_excel(filenames[8], skip = 5, col_names = FALSE) %>% mutate(group = "Jun10")# summary table up top in excel 
Oct10 = read_excel(filenames[9]) %>% mutate(group = "Oct10")
Sep10 = read_excel(filenames[10]) %>% mutate(group = "Sep10")
effort = read_excel(filenames[11])

# add column names
tmp_name = Jun09[0,] %>% 
  rename(date = year) %>% select(-month,-day,-group) %>% 
  mutate(timeB = NA, timeC = NA, group=NA)
names(Jul10) = names(tmp_name)
names(Jun10) = names(tmp_name)
names(Aug10) = names(tmp_name)
rm(tmp_name)

# change col names
Sep10 = rename(Sep10, date = DATE, timeB = t2, timeC = period)
Oct10 = rename(Oct10, date = DATE, timeB = t2, timeC = period)

# combine data after minor formating
Aug09A = mutate(Aug09A, 
                w_KT = as.character(w_KT),
                cond = as.numeric(cond))
Aug09B = mutate(Aug09B, 
                w_KT = as.character(w_KT),
                act = as.character(act))
Aug10 = mutate(Aug10, 
               act = as.character(act))
Jun09 = mutate(Jun09, 
               trip = as.numeric(trip), 
               type = as.numeric(type))
Jul10 = mutate(Jul10, 
               act = as.character(act))
Oct09 = mutate(Oct09, 
               w_KT = as.character(w_KT),
               act = as.character(act))
Oct10 = mutate(Oct10, 
               act = as.character(act))
Sep10 = mutate(Sep10, 
               act = as.character(act),
               w_KT = as.character(w_KT))
Sep09 = mutate(Sep09, 
               w_KT = as.character(w_KT))

               
data = bind_rows(Aug09A, Aug09B, Aug10, 
                 Jun09, Jun10,
                 Jul10, 
                 Oct09, Oct10, 
                 Sep09, Sep10)

data = data %>% 
  rename(date2 = date,
         unknown_time = time) %>% 
  mutate(date = NA,
         date = ifelse(is.na(date2),
                       as.character(as.POSIXct(paste(year, month, day, sep ="-"), format = '%Y-%m-%d')), 
                       as.character(date2)),
         time = sapply(strsplit(as.character(timeB), " "),tail,1),
         loc = ifelse(ht %in% c("A","J","UK"), loc, age),
         age = ifelse(age %in% c("IN","OUT"), ht, age),
         age = ifelse(age %in% "A", "adult", age),
         age = ifelse(age %in% "J", "juvenile", age),
         age = ifelse(age %in% "UK", "unknown", age),
         age = ifelse(age %in% "S", "subadult", age),
         age = ifelse(age %in% "I", "immature", age),
         age = ifelse(age %in% c("MIX","MIXED"), "mixed", age),
         age = ifelse(age %in% "1822", NA, age)) %>% 
  rename(condition = cond, seastate = sea, wind_dir = w_dir, 
         wind_knots = w_KT, transect = trans, visibility = view, 
         seconds_from_midnight = sec_af_mid, count = num, comments = notes) %>% 
  select(-date2, -year, -month, -day, -timeB, -timeC, -ht, -loc, -act) 

         # not sure what ht, loc, and act are so removing for now
         # loc could be offline?
         # ht = ifelse(act %in% "20 H", "H", ht),


rm(Aug09A, Aug09B, Aug10, Jun09, Jun10, Jul10, Oct09, Oct10, Sep09, Sep10)
#---------------------#


#---------------------#
#---------------------#
#---------------------#


#---------------------#
#---------------------#
#---------------------#


#---------------------#
#---------------------#
#---------------------#
