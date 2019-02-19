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
Jun09 = read_excel(filenames[1])
Oct09 = read_excel(filenames[2])
Sep09 = read_excel(filenames[3])
Aug09A = read_excel(filenames[4])
Aug09B = read_excel(filenames[5])
Aug10 = read_excel(filenames[6], skip = 5, col_names = FALSE) # summary table up top in excel )
Jul10 = read_excel(filenames[7], skip = 6, col_names = FALSE) # summary table up top in excel 
Jun10 = read_excel(filenames[8], skip = 5, col_names = FALSE) # summary table up top in excel 
Oct10 = read_excel(filenames[9])
Sep10 = read_excel(filenames[10])
effort = read_excel(filenames[11])

# add column names
tmp_name = Jun09[0,] %>% 
  rename(date = year) %>% select(-month,-day) %>% 
  mutate(timeB = NA, timeC = NA)
names(Jul10) = names(tmp_name)
names(Jun10) = names(tmp_name)
names(Aug10) = names(tmp_name)
rm(tmp_name)

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
  mutate(date = ifelse(is.na(date), 
                       as.Date(paste(year, month, day, sep ="-"), format = '%Y-%m-%d'),
                       date))

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
