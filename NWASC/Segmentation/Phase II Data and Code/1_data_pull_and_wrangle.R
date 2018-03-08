library(dplyr)

library(readr)
#obseervation read csv
observation <- read_csv("~/boem_noaa/Phase II Data and Code/observation.csv",
                        col_types = cols(admin_notes = col_skip(),
                                         angle_from_observer_nb = col_skip(),
                                         animal_age_tx = col_skip(), animal_sex_tx = col_skip(),
                                         association_tx = col_skip(), behavior_tx = col_skip(),
                                         cloud_cover_tx = col_skip(), comments_tx = col_skip(),
                                         datafile = col_skip(), dataset_id = col_integer(),
                                         date_created = col_skip(), date_imported = col_skip(),
                                         distance_to_animal_tx = col_skip(),
                                         flight_height_tx = col_skip(), glare_tx = col_skip(),
                                         heading_tx = col_character(), local_obs_id = col_skip(),
                                         local_transect_id = col_skip(), obs_count_general_nb = col_skip(),
                                         obs_count_intrans_nb = col_double(),
                                         obs_dt = col_skip(),
                                         obs_end_tm = col_skip(),
                                         obs_position = col_skip(), obs_start_tm = col_skip(),
                                         observation_id = col_skip(), observer_confidence_tx = col_skip(),
                                         observer_tx = col_skip(),  original_species_tx = col_character(),
                                         platform_tx = col_skip(), plumage_tx = col_skip(),
                                         reel = col_skip(), salinity_ppt_nb = col_skip(),
                                         seastate_beaufort_nb = col_skip(),
                                         seasurface_tempc_nb = col_skip(),
                                         seconds_from_midnight_nb = col_skip(),
                                         source_dataset_id = col_skip(), source_obs_id = col_skip(),
                                         source_transect_id = col_skip(),
                                         spp_cd = col_character(),
                                         station_tx = col_skip(), survey_type = col_skip(),
                                         seconds_from_midnight_nb = col_number(),
                                         transect_id = col_number(), travel_direction_tx = col_skip(),
                                         visibility_tx = col_skip(), visit = col_skip(),
                                         wave_height_tx = col_skip(), weather_tx = col_skip(),
                                         whitecaps_tx = col_skip(), who_created = col_skip(),
                                         who_created_tx = col_skip(), who_imported = col_skip(),
                                         wind_dir_tx = col_skip(), wind_speed_tx = col_skip()))
observation$transect_id = as.integer(observation$transect_id)
observation = SppCp_Fix(observation)


#View(observation)


#track read csv
track <- read_csv("~/boem_noaa/Phase II Data and Code/track.csv",
                  col_types = cols(comment = col_skip(),
                                   datafile = col_skip(), dataset_id = col_integer(),
                                   observer = col_skip(), observer_position = col_skip(),
                                   offline = col_skip(), piece = col_integer(),
                                   point_type = col_skip(), seastate = col_skip(),
                                   seconds_from_midnight_nb = col_skip(),
                                   source_survey_id = col_skip(), source_track_id = col_skip(),
                                   source_transect_id = col_character(),
                                   track_dt = col_skip(), track_gs = col_skip(),
                                   track_id = col_skip(), track_tm = col_skip(),
                                   transect_id = col_number()))
track$transect_id = as.integer(track$transect_id)

#View(track)


#transect read csv
transect <- read_csv("~/boem_noaa/Phase II Data and Code/transect.csv",
                     col_types = cols(altitude_nb_m = col_skip(),
                                      comments_tx = col_skip(), conveyance_name_tx = col_skip(),
                                      datafile = col_skip(), dataset_id = col_integer(),
                                      date_created = col_skip(), date_imported = col_skip(),
                                      end_dt = col_character(),
                                      end_tm = col_character(),
                                      heading_tx = col_skip(), local_survey_id = col_skip(),
                                      local_transect_id = col_skip(), local_transect_id2 = col_skip(),
                                      obs_position = col_skip(), observers_tx = col_skip(),
                                      seastate_beaufort_nb = col_skip(),
                                      seasurface_tempc_nb = col_skip(),
                                      source_dataset_id = col_character(),
                                      source_transect_id = col_character(),
                                      spatial_type_tx = col_skip(), start_dt = col_character(),# date(format = "%m/%d/%Y"),
                                      start_tm = col_character(),
                                      survey_type = col_skip(),
                                      transect_width_nb = col_number(),
                                      time_from_midnight_start = col_number(),
                                      time_from_midnight_stop = col_number(),
                                      temp_start_lat = col_skip(),
                                      temp_start_lon = col_skip(), temp_stop_lat = col_skip(),
                                      temp_stop_lon = col_skip(), track_gs = col_skip(),
                                      transect_distance_nb = col_double(),
                                      transect_id = col_number(), transect_time_min_nb = col_number(),
                                      traversal_speed_nb = col_number(),
                                      utm_zone = col_skip(), visability_tx = col_skip(),
                                      visit = col_skip(), wave_height_tx = col_skip(),
                                      weather_tx = col_skip(), who_created = col_skip(),
                                      who_imported = col_skip(), whole_transect = col_skip(),
                                      wind_dir_tx = col_skip(), wind_speed_tx = col_skip()))
transect$transect_id = as.integer(transect$transect_id)
transect$start_dt = DomVirFix(transect$start_dt)
transect = fix_transect_names_160(transect)
#View(transect)

#pull datset table
dataset <- read_csv("~/boem_noaa/Phase II Data and Code/dataset.csv",
                    col_types = cols(abstract = col_skip(),
                                     action_required = col_skip(), action_taken = col_skip(),
                                     admin_notes = col_skip(), area_covered_km2 = col_skip(),
                                     at_usgs = col_skip(), comments = col_skip(),
                                     dataset_id = col_integer(), dataset_type_cd = col_skip(),
                                     date_created = col_skip(), discrete_time_unit = col_skip(),
                                     end_date = col_skip(), funded = col_skip(),
                                     import_notes = col_skip(), in_db = col_skip(),
                                     keywords = col_skip(), meta_std = col_skip(),
                                     noaa_import_priority = col_skip(),
                                     noaa_priority = col_skip(), number_of_records = col_skip(),
                                     parent_project = col_skip(), planned_speed_knots = col_skip(),
                                     progress = col_skip(), purpose = col_skip(),
                                     qual_rpt = col_skip(), resp_party = col_skip(),
                                     share_level = col_skip(), source_dataset_id = col_skip(),
                                     sponsors = col_skip(), start_date = col_skip(),
                                     subject = col_skip(), survey_method_cd = col_character(),
                                     survey_type_cd = col_character(),
                                     survey_width_m = col_skip(), title = col_skip(),
                                     url_program = col_skip(), usgs_priority = col_skip(),
                                     version = col_skip(), who_created = col_skip()))

#roll_up double observation tansects
AMAPPS.target.ids = c(142,164,139)
MassCEC.target.ids = c(135,161,162)
target_id = c(AMAPPS.target.ids,MassCEC.target.ids)
lookup_table = Create.transect.revision.lookup()
transect = roll_up_transect(transect, lookup_table)
track = roll_up_track(track, lookup_table)
observation = roll_up_observation(observation, lookup_table)


# transects
cts.dat1 = transect %>%
  select(start_dt, end_dt, dataset_id,
         source_dataset_id, source_transect_id, transect_id, start_tm, end_tm,
         transect_width_nb, time_from_midnight_start, time_from_midnight_stop) %>%
  rename(segmented_transect_id = source_transect_id)

cts.dat2 = dataset

cts.dat = left_join(cts.dat1,cts.dat2, by ="dataset_id")

# observations
obs.pre = observation %>% select(transect_id, temp_lat, temp_lon, spp_cd, obs_count_intrans_nb) %>% #, source_dataset_id
  rename(lat = temp_lat, long = temp_lon, count = obs_count_intrans_nb) %>%
  mutate(count = ifelse(is.na(count) & !is.na(spp_cd), 1, count)) %>%
  filter(spp_cd != "NONE", count >= 0, !is.na(lat), !is.na(long))

obs.pre = keep_only_known_birds(obs.pre)

# tracks vars created tracks$ : lat, long, transect_id, dataset_id, piece, source_transect_id, order
shp.pre = track %>% select(track_lat, track_lon, transect_id, dataset_id, piece) %>%
  rename(lat = track_lat, long = track_lon) %>%
  mutate(piece = replace(piece, is.na(piece), 1)) %>%
  arrange(transect_id, piece) %>%
  group_by(transect_id, piece) %>%
  #filter(!(transect_id %in% obs.missing$transect_id)) %>%
  filter(!is.na(transect_id)) %>%
  filter(!is.na(lat) & !is.na(long)) %>%
  mutate(order = seq.int(n())) %>%
  #filter(dataset_id == 115) %>%
  ungroup
shp.pre = shp.pre ## %>% drop_na(transect_id)

 #rm(obs.missing)

 # rm(observation)
 # rm(track)
 # rm(transect)
