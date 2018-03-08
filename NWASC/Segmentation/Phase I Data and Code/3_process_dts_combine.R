# Process dts survey data in NWASC database
# Returns wide-form dataframe with processed data

# Requires observation table with lat/long for each sighting and transect table with single row for each transect id

# v.spd sets assumed vessel speed in knots when vessel speed is missing
# Calculates species counts by default; set occurences = TRUE for number of flock sightings

# Distances are in nautical miles

# Kyle Dettloff
# Modified 09-30-16

suppressMessages(library(maptools))
suppressMessages(library(rgeos))
suppressMessages(library(geosphere))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(lubridate))

# read in dts and observation tables
load("~/boem_noaa/Phase I Data and Code/database_extract_dts_obs.RData")

segmentDTS = function(observations, transects, v.spd = 10, occurences = FALSE) {

  if(nrow(transects) == 0) stop("empty transect table")

  # -------- prepare observation table to be paired with dts midpoints --------------------------------------------------
  # narrow all observations to only those on dts transects
  observations = observations %>% filter(transect_id %in% transects$transect_id) %>% select(-st_astext)
  if(nrow(observations) == 0) stop("no observations present for given transects")

  # format times in dts table
  dts.time = transects %>%
    select(transect_id, start_dt, end_dt, start_tm, end_tm, time_from_midnight_start, time_from_midnight_stop) %>%

    mutate(start_tm = as.POSIXct(ymd(start_dt, quiet = TRUE) + hms(start_tm, quiet = TRUE)),
           end_tm = as.POSIXct(ymd(end_dt, quiet = TRUE) + hms(end_tm, quiet = TRUE)),
           time_from_midnight_start = as.POSIXct(ymd(start_dt, quiet = TRUE) + seconds(time_from_midnight_start)),
           time_from_midnight_stop = as.POSIXct(ymd(end_dt, quiet = TRUE) + seconds(time_from_midnight_stop))) %>%
    mutate(start_tm = ifelse(is.na(start_tm) & !is.na(time_from_midnight_start), time_from_midnight_start, start_tm),
           end_tm = ifelse(is.na(end_tm) & !is.na(time_from_midnight_stop), time_from_midnight_stop, end_tm)) %>%
    select(-c(time_from_midnight_start, time_from_midnight_stop))

  # format times in observation table
  obs.time = observations %>%
    select(transect_id, obs_dt, obs_start_tm, spp_cd, obs_count_intrans_nb, time_from_midnight) %>%
    mutate(obs_start_tm = as.POSIXct(ymd(obs_dt, quiet = TRUE) + hms(obs_start_tm, quiet = TRUE)),
           time_from_midnight = as.POSIXct(ymd(obs_dt, quiet = TRUE) + seconds(time_from_midnight))) %>%
    mutate(obs_start_tm = ifelse(is.na(obs_start_tm) & !is.na(time_from_midnight), time_from_midnight, obs_start_tm)) %>%
    select(-time_from_midnight)

  # narrow observations to those on effort using time
  observations = left_join(obs.time, dts.time, by = "transect_id") %>%
    mutate(off_eff = as.integer(ifelse(obs_start_tm < start_tm | obs_start_tm > end_tm, 1, 0))) %>%
    filter(off_eff == 0 | is.na(off_eff)) %>% select(-off_eff) %>% rename(count = obs_count_intrans_nb) %>%
    # assign count of one when species code present but count field missing
    mutate(count = ifelse(is.na(count) & !is.na(spp_cd), 1, count)) %>%
    select(transect_id, spp_cd, count) %>% filter(spp_cd != "NONE", count >= 0)

  if (nrow(observations) == 0) stop("no valid observations")

  # -------- calculate dts survey midpoints -----------------------------------------------------------------------------
  # select only durations of 10 and 15 minutes
  transects = transects %>%
    select(source_dataset_id, segmented_transect_id, transect_id, start_dt, survey_type_cd, survey_method_cd,
           transect_width_nb, transect_time_min_nb, traversal_speed_nb, heading_tx, st_astext) %>%
    filter(transect_time_min_nb %in% c(10, 15)) %>%
    mutate(traversal_speed_nb = replace(traversal_speed_nb, is.na(traversal_speed_nb), v.spd)) %>%
    mutate(traversal_speed_nb = traversal_speed_nb * 1.852, # Speed still in knots here
           seg_dist = round(transect_time_min_nb * (traversal_speed_nb ) / 60, 3)#,

           )

  if (nrow(transects) == 0) stop("no valid transects")

  ### get midpoints of spatial points
  midpoints.point = transects %>% filter(grepl("POINT", st_astext), !is.na(heading_tx))
    if (nrow(midpoints.point) != 0) {
      midpoints.point = midpoints.point %>% bind_cols(., as.data.frame(do.call(rbind, lapply(.$st_astext, readWKT)))) %>%
        select(-st_astext) %>% rename(long = x, lat = y) %>%
        mutate(half_dist_m = transect_time_min_nb * traversal_speed_nb * 1000 / 120) %>%
        rowwise %>% mutate(coords_mid = list(destPoint(c(long, lat), heading_tx, half_dist_m))) %>%
        ungroup %>% mutate(mid_long = unlist(lapply(coords_mid, `[[`, 1)), mid_lat = unlist(lapply(coords_mid, `[[`, 2))) %>%
        select(source_dataset_id, segmented_transect_id, transect_id, start_dt, survey_type_cd, survey_method_cd,
               transect_width_nb, seg_dist, mid_long, mid_lat)
    }

  ### get midpoints of spatial lines
  midpoints.line = transects %>% filter(grepl("LINE", st_astext))
    if (nrow(midpoints.line) != 0) {
      lineframe = lapply(midpoints.line$st_astext, readWKT, p4s = CRS("+proj=longlat"))
      # apply Hotine Oblique Mercator projection
      lineframe = lapply(lineframe, spTransform, CRS("+proj=omerc +lonc=-75 +lat_0=35 +alpha=40 +k_0=0.9996 +ellps=GRS80 +datum=NAD83"))
      # calculate geographic centroids of projected segments and convert back to lat/long
      midpoints.line = do.call(rbind, lapply(lineframe, gCentroid, byid = TRUE)) %>% spTransform(CRS("+proj=longlat")) %>%
        as.data.frame %>% rename(mid_long = x, mid_lat = y) %>%
        bind_cols(select(midpoints.line, source_dataset_id, segmented_transect_id, transect_id, start_dt,
                         survey_type_cd, survey_method_cd, transect_width_nb, seg_dist), .)
    }

  # combine midpoints of points and lines
  midpoints = bind_rows(midpoints.point, midpoints.line)

  # -------- pair observations with midpoints ---------------------------------------------------------------------------
  # keep only observations with matching dts transect IDs
  observations = observations %>% filter(transect_id %in% midpoints$transect_id)
  if(nrow(observations) == 0) stop("no observations present for given transects")

  # join midpoints and observations
  dts.final = full_join(midpoints, observations, by = "transect_id") %>%
    mutate(spp_cd = replace(spp_cd, is.na(spp_cd), "NONE"),
           seg_num = as.integer(1)
           ) %>%
    group_by(source_dataset_id, segmented_transect_id, transect_id, seg_num, start_dt, seg_dist,
             transect_width_nb, mid_long, mid_lat, survey_type_cd, survey_method_cd, spp_cd)

  # -------- summarize species data and convert to wide form ------------------------------------------------------------
    if (!occurences) {
      # total species count
      dts.final = dts.final %>% summarise(count = sum(count)) %>%
        spread(spp_cd, count, fill = 0) %>% select(everything(), -matches("NONE")) %>%
        ungroup %>% arrange(transect_id)
    }
    else if (occurences) {
      # number of species occurences
      dts.final = dts.final %>% select(-count) %>% summarise(noccur = n()) %>%
        spread(spp_cd, noccur, fill = 0) %>% select(everything(), -matches("NONE")) %>%
        ungroup %>% arrange(transect_id)
    }

}


