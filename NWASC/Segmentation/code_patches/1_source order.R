#Requirement for this file
library(dplyr)
library(sp)
library(rgeos)
#Fix for spiece names
source('~/boem_noaa/code_patches/spp_c replacements.R')
#Fix for fate issue
source('~/boem_noaa/code_patches/DominionVirginia date fix.R')
#fix for known unkown removal or...
source('~/boem_noaa/code_patches/Known none bird removal.R')
#roll_up Phase 2 double observer transects
source('~/boem_noaa/code_patches/ConsudatePilotObservertracks.R')

source('~/boem_noaa/code_patches/Dataset160namefix.R')


#### Phase 2 ####
 source('~/boem_noaa/Phase II Data and Code/1_data_pull_and_wrangle.R')

#### Phase 2 Processed ####
source('~/boem_noaa/Phase II Data and Code/2_phase2_segmentation.R')
seg.dat.phase2 = segmentCTS(obs.pre, shp.pre , cts.dat, seg.min = 0.0)
# seg.dat.opps = segmentCTS(obs.opps, shp.opps, cts.opps, seg.min = 0.0)
# seg.dat.phase2 = bind_rows(seg.dat.phase2,seg.dat.opps)
#View(seg.dat.phase2)

rm(cts.dat,cts.dat1,cts.dat2,dataset,obs.pre,shp.pre,segmentCTS,SppCp_Fix, DomVirFix, keep_only_known_birds, lu_species)
rm(lookup_table,observation,track,transect)
rm(AMAPPS.target.ids,MassCEC.target.ids,target_id)
rm(Create.transect.revision.lookup,roll_up_observation,roll_up_track,roll_up_transect)

#### PHASE 1 ####
source('~/boem_noaa/Phase I Data and Code/1_cts_data_wrangle.R')
preSegment(obs.dat, shp, cts.dat)
rm(obs.dat, shp, preSegment)

source('~/boem_noaa/code_patches/Easyrearobsfix.R')
cts.dat <- rearobsdrop(cts.dat)
obs.pre <- rearobsdrop(obs.pre)
shp.pre <- rearobsdrop(shp.pre)

#### Roll up AMAPPS transects
source('~/boem_noaa/code_patches/ConsudatePilotObservertracksPhase1.R')
rm(Create.transect.revision.lookup,roll_up_observation,roll_up_track,roll_up_transect)
rm(AMAPPS.target.ids,target_id, lookup_table)


source('~/boem_noaa/Phase I Data and Code/2_cts_segmentation.R')
seg.dat.phase1.cts = segmentCTS(obs.pre, shp.pre , cts.dat, seg.min = 0.0)
rm(cts.dat,obs.pre,shp.pre,segmentCTS)




source('~/boem_noaa/Phase I Data and Code/3_process_dts_combine.R')
seg.dat.phase1.dts = segmentDTS(obs.dat, dts.dat)
rm(dts.dat,obs.dat, segmentDTS)

#### Combine
  segmented_seabird_catalogs = bind_rows(seg.dat.phase2, seg.dat.phase1.cts, seg.dat.phase1.dts) %>%
  mutate_at(vars(-c(source_dataset_id:survey_method_cd)), funs(replace(., is.na(.), 0))) %>%
  arrange(transect_id, seg_num)
rm(seg.dat.phase2, seg.dat.phase1.cts,seg.dat.phase1.dts)
 ### Save to csv
 datetime = Sys.Date()
 dft = 'combined_transects_3'
 filenm = paste(paste("segmented_seabird_catalog",datetime,dft,sep = "-"),".csv")
 write.csv(segmented_seabird_catalogs,file = filenm, row.names = FALSE)
 rm(datetime,dft,filenm)
 rm(Dataset160_leg_tran_id,MidAtlanticDetection2012_rear_observers,missingtransects)
 rm(rearobs_trans_id,rearobsdrop)
