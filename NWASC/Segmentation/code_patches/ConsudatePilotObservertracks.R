#### Sub- Functions for AAMMAPs Arial and ___ ####
## For phase 2
#Used after 'transect' csv is read in as df
require(dplyr)
require(stringi)
require(tidyverse)
require(tidyr)
#create a three col. lookup table with
#### Creat a lookup table indexed by transect_id, with new rev transect_id and Source_name
#### added a drop track flag for clarity
####


Create.transect.revision.lookup = function(
                                    .df = transect,
                                    .target_id = target_id,
                                    source_name = 'source_transect_id',
                                    orginal_id = 'transect_id',
                                    transect_dist = 'transect_distance_nb'){
  #Organize arguments
  #Make .df a dataframe so it plays nice.
  .df = data.frame(.df)
  #identify col numbers
  myCols <- c(source_name, orginal_id, transect_dist) %>%
    match(names(.df))
  #Select row and columns
  Target_rows = .df %>%
    filter(dataset_id %in% .target_id) %>%
    select(dataset_id, start_dt, source_transect_id, transect_id, transect_distance_nb) %>%
    select(dataset_id, start_dt, source_name = source_transect_id, orginal_id = transect_id, transect_dist = transect_distance_nb)


  #Create combined transect Name
  lookup_table = Target_rows %>%
    separate(source_name, c('tran_name','intials','suffix'), '_', fill = 'right') %>%
    mutate(suffix = ifelse(is.na(suffix),'',suffix)) %>%
    unite(rev_names,tran_name,suffix,sep = '_', remove = FALSE) %>%
    mutate( rev_names = ifelse(suffix == '' , tran_name, rev_names) ,
            rev_names = paste(rev_names,year(start_dt),month(start_dt),sep = '_') ) %>%
    select(rev_names, orginal_id, transect_dist) %>%
    arrange(rev_names,orginal_id,transect_dist) %>%
    group_by(rev_names) %>%
    mutate( max_dist = max(transect_dist),
            drop_track = max_dist != transect_dist,
            rev_ids = orginal_id[1]) %>% ungroup %>%
    select(orginal_id, rev_ids, rev_names, drop_track) %>%
    rename(transect_id = orginal_id)

 lookup_table
}

#lookup_table = Create.transect.revision.lookup()

#### Function to edit the transect file
roll_up_transect = function(
                      .df = transect,
                      lookup = lookup_table) {
  new_df = .df %>%
    left_join(., lookup, by = 'transect_id')  %>% #Join the lookup to transect file
    mutate(
      drop_track = ifelse(is.na(drop_track),FALSE,drop_track),
      transect_id = ifelse(!is.na(rev_ids),rev_ids,transect_id), #is the !is.na needed?
      source_transect_id = ifelse(!is.na(rev_names),rev_names,source_transect_id)
    ) %>%
    filter(drop_track != TRUE) %>%
    select(-c(rev_ids, rev_names, drop_track))


 new_df
}

# transect2 = roll_up_transect(transect, lookup_table)

#### Function to edit track file (similiar to above)
roll_up_track = function(
                  .df = track,
                  lookup = lookup_table) {
  new_df = .df %>%
    left_join(., lookup, by = 'transect_id')  %>% #Join the lookup to transect file
    mutate(
      drop_track = ifelse(is.na(drop_track),FALSE,drop_track),
      transect_id = ifelse(!is.na(rev_ids),rev_ids,transect_id), #is the !is.na needed?
      source_transect_id = ifelse(!is.na(rev_names),rev_names,source_transect_id)) %>%
    filter(drop_track != TRUE) %>%
    select(-c(rev_ids, rev_names, drop_track))


  #
  #
  new_df
}

# track2 = roll_up_track(track, lookup_table)

#### Function to edit observation table same as aove two except we do not drop rows
# kept. Observations simply reassigned .
roll_up_observation = function(
                        .df = observation,
                        lookup = lookup_table) {
  new_df = .df %>%
    left_join(., lookup, by = 'transect_id')  %>% #Join the lookup to transect file
    mutate(
      transect_id = ifelse(!is.na(rev_ids),rev_ids,transect_id) #is the !is.na needed?
      ) %>%
    select(-c(rev_ids, rev_names, drop_track))


  new_df
}

# observation2 = roll_up_observation(observation, lookup_table)

