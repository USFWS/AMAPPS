#### Sub- Functions for AAMMAPs Arial and ___ ####
##
#Used after 'transect' csv is read in as df
require(dplyr)
require(stringi)
require(tidyverse)
require(tidyr)
#create a three col. lookup table with
#### Creat a lookup table indexed by transect_id, with new rev transect_id and Source_name
#### added a drop track flag for clarity
####
#### AMAPPS combine transects

Create.transect.revision.lookup = function(
                                    .df = cts.dat,
                                    .target_id = target_id,
                                    source_name = 'segmented_transect_id',
                                    orginal_id = 'transect_id'){ #missing transect_dist = 'transect_distance_nb'
  #Organize arguments
  #Make .df a dataframe so it plays nice.
  #.df = data.frame(.df)

  #Select row and columns !!!!!!transect dist subsituted for number of secs.
  Target_rows = .df %>%
    filter(., dataset_id %in% .target_id) %>%
    select(dataset_id, start_dt, segmented_transect_id, transect_id, time_from_midnight_start,time_from_midnight_stop) %>%
    mutate(transect_dist = time_from_midnight_stop - time_from_midnight_start) %>%
    select(dataset_id, start_dt, source_name = segmented_transect_id, orginal_id = transect_id, transect_dist )


  #Create combined transect Name
  lookup_table = Target_rows %>%
    mutate(rev_names = substring(source_name, 0, nchar(source_name)-4)) %>%

    #comute and choose lngest segment
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
                      .df = cts.dat,
                      lookup = lookup_table) {
  new_df = .df %>%
    left_join(., lookup, by = 'transect_id')  %>% #Join the lookup to transect file
    mutate(
      drop_track = ifelse(is.na(drop_track),FALSE,drop_track),
      transect_id = ifelse(!is.na(rev_ids),rev_ids,transect_id), #is the !is.na needed?
      segmented_transect_id = ifelse(!is.na(rev_names),rev_names,segmented_transect_id)
    ) %>%
    filter(drop_track != TRUE) %>%
    select(-c(rev_ids, rev_names, drop_track))


 new_df
}

# transect2 = roll_up_transect(transect, lookup_table)

#### Function to edit track file (similiar to above)
roll_up_track = function(
                  .df = shp.pre,
                  lookup = lookup_table) {
  new_df = .df %>%
    left_join(., lookup, by = 'transect_id')  %>% #Join the lookup to transect file
    mutate(
      drop_track = ifelse(is.na(drop_track),FALSE,drop_track),
      transect_id = ifelse(!is.na(rev_ids),rev_ids,transect_id)) %>%
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
                        .df = obs.pre,
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


# Example Run
AMAPPS.target.ids = c(113,118,137,138,140,141,146,147)
target_id = AMAPPS.target.ids
lookup_table = Create.transect.revision.lookup()
cts.dat = roll_up_transect(cts.dat, lookup_table)
shp.pre = roll_up_track(shp.pre, lookup_table)
obs.pre = roll_up_observation(obs.pre, lookup_table)


