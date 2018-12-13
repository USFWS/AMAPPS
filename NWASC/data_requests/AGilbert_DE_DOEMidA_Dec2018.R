# A. Gilbert, requested 12/10/18
#
# 1) DOE Mid-Atlantic hidef aerial and boat survey data. I know, this is 
# our data, but I want it in all it's glory from the Seabird Catalog.
# 
# 2) All data for all species from 37.3-39.3 N lat. obs and effort.

# ------------------ # 
# load packages
# ------------------ # 
require(dplyr)
require(ggplot2)
require(RODBC)
require(odbc)
library(readr)
library(readxl)
# ------------------ # 


# ------------------ #
# load data
# ------------------ #
db <- dbConnect(odbc::odbc(),driver='SQL Server',server='ifw-dbcsqlcl1',database='NWASC')
datasets = dbGetQuery(db, "select * from dataset")
lit = dbGetQuery(db, "select * from links_and_literature")
spp = dbGetQuery(db, "select * from lu_species")
#obs = dbGetQuery(db, "select * from observations")
DE_effort = dbGetQuery(db, "select * from all_effort where latitude >= 37.3 and latitude <= 39.3")
midA_effort = dbGetQuery(db, "select * from all_effort where dataset_id %in% (114,115,124,125,126,127,128,129,130,148,150,151,152,153,154,155,156,157,168)")
dbDisconnect(db)

# obs data (temp)
obs <- read_csv("Z:/seabird_database/data_sent/TWhite_archive_Oct2018/obs_Oct2018.csv")
obs_bb = obs %>% filter(latitude >= 37.3, latitude <= 39.3)
ind = datasets %>% filter(parent_project %in% c(8,9))
obs_doe_midA = obs %>% filter(dataset_id %in% ind$dataset_id)
# ------------------ #

# ------------------ #
# formatting
# ------------------ #
# filter datasets
datasets = filter(datasets, dataset_id %in% obs_bb$dataset_id, !share_level_id %in% 1)
obs_bb = filter(obs_bb, dataset_id %in% datasets$dataset_id)

# transform datasets
source("Z://seabird_database/Rfunctions/transformDatasets.R")
summaries = read_excel("Z:/seabird_database/documentation/How to and Reference files/NWASC_guidance/dataset_summaries_Aug2018.xlsx")
summaries = summaries[,1:5] %>% dplyr::select(-source_dataset_id) 
names(summaries) = tolower(names(summaries))

datasets = transformDataset(datasets) %>% 
  dplyr::select(-data_url, -report, -data_citation, -publications, 
                -publication_url, -publication_DOI, 
                -dataset_summary, -dataset_processing, -dataset_quality) %>%
  left_join(., lit, by="dataset_id") %>% 
  left_join(., summaries, by="dataset_id")

# export
write.csv(obs_doe_midA,"Z:/seabird_database/data_sent/AGilbert_DE_DOEMidA_Dec2018/DOE_MidA_hidef_observations.csv")
write.csv(obs_bb,"Z:/seabird_database/data_sent/AGilbert_DE_DOEMidA_Dec2018/DE_observations.csv")
write.csv(datasets,"Z:/seabird_database/data_sent/AGilbert_DE_DOEMidA_Dec2018/datasets.csv")
# ------------- #


