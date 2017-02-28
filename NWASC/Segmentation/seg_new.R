# Function to segment continuous survey data in NWASC database
# Returns wide-form dataframe with segmented data

# Requires observation table with lat/long for each sighting, transect table with single row for each transect id,
# and spatial lines shapefile containing survey effort

# seg.length sets target segment length (seg.length > 0)

# seg.tol sets threshold for creation of a new segment from extra transect distance (0 <= extra < seg.length)
# as a proportion of target segment length (0 <= seg.tol < 1)

# Calculates species counts by default; set occurences = TRUE for number of flock sightings
# maxDist sets maximum allowable distance (approx. meters) between an observation and its nearest segment line
# Segment midpoints fall on track line by default; set centroids = TRUE to use geographic centroid
# seg.min sets minimum allowable segment length (>= 0)

# Distances are in nautical miles

# Kyle Dettloff
# Modified 07-25-16 after dplyr 0.5.0 update

suppressMessages(library(maptools))
suppressMessages(library(rgeos))
suppressMessages(library(geosphere))
suppressMessages(library(dplyr))
suppressMessages(library(tibble))
suppressMessages(library(tidyr))
suppressMessages(library(zoo))

options(dplyr.show_progress = FALSE)

segmentCTS = function(observations, tracks, transects, seg.length = 4, seg.tol = 0.5, seg.min = seg.length * seg.tol,
                      centroids = FALSE, maxDist = NA, occurences = FALSE) {
  
  if(seg.length <= 0) stop("seg.length > 0 is FALSE")
  if(seg.tol < 0 | seg.tol >= 1) stop("0 <= seg.tol < 1 is FALSE")
  if(seg.min < 0) stop("seg.min >= 0 is FALSE")

  # -------- segment track data ---------------------------------------------------------------------------------------------------
  seg = tracks %>% distinct(long, lat, piece, transect_id, .keep_all = TRUE) %>% group_by(transect_id, piece) %>%
    mutate(long_i = lag(long, default = first(long), order_by = order),
           lat_i = lag(lat, default = first(lat), order_by = order)) %>%
    rowwise %>% mutate(dist = distVincentySphere(c(long_i, lat_i), c(long, lat)) / 1000) %>%
    select(-c(long_i, lat_i, order)) %>% ungroup %>% group_by(transect_id, piece) %>%
    # calculate cumulative distance traveled between waypoints
    mutate(dist_cuml = cumsum(dist), dist_total = max(dist_cuml)) %>% select(-dist) %>%
    # calculate number of segments for each transect
    mutate(nseg = ifelse(dist_total <= seg.length, 1,
                         ifelse(dist_total / seg.length - floor(dist_total / seg.length) >= seg.tol,
                                floor(dist_total / seg.length) + 1, floor(dist_total / seg.length))),
           # calculate length of odd segment
           dist_extra = dist_total - seg.length * floor(dist_total / seg.length),
           dist_odd = ifelse(nseg == 1, 0, ifelse(dist_extra < seg.length * seg.tol,
                                                  dist_extra + seg.length, dist_extra)),
           # randomly determine which segment will be assigned odd length
           seg_odd = ifelse(dist_odd == 0, 0, ceiling(runif(1, 0, nseg))),
           # number segments with waypoints
           seg_num = ifelse(nseg == 1 | dist_cuml == 0, 1,
                            ifelse(dist_cuml <= seg.length * (seg_odd - 1), ceiling(dist_cuml / seg.length),
                                   ifelse(dist_cuml > seg.length * (seg_odd - 1) + dist_odd,
                                          ceiling(1 + round((dist_cuml - dist_odd) / seg.length, 10)), seg_odd))),
           # number of segments without waypoints
           tot_empty = as.integer(nseg - n_distinct(seg_num))) %>% select(-dist_extra)
  
  # create rows for segments without waypoints  
  seg.empty = seg %>% ungroup %>% select(piece, dataset_id, transect_id, dist_total, nseg, dist_odd, seg_odd, tot_empty) %>%
    distinct %>%  filter(tot_empty > 0) %>% slice(rep(row_number(), tot_empty)) %>% select(-tot_empty) %>%
    mutate(empty_seg = 1)
  
  # combine segments with and without waypoints
  seg.all = seg %>% select(-tot_empty) %>% bind_rows(., seg.empty) %>% group_by(transect_id, piece) %>%
    # number segments without waypoints
    mutate(seg_num = replace(seg_num, is.na(seg_num), setdiff(1:first(nseg), seg_num)),
           # calculate segment lengths
           seg_dist = ifelse(nseg == 1, dist_total, ifelse(seg_num == seg_odd, dist_odd, seg.length)),
           # calculate cumulative segment distance
           seg_dist_cuml = ifelse(nseg == 1, seg_dist,
                                  ifelse(seg_num >= seg_odd, seg.length * (seg_num - 1) + dist_odd, seg.length * seg_num))) %>%
    select(-c(dist_total, dist_odd, seg_odd)) %>%
    ungroup %>% arrange(dataset_id, transect_id, piece, seg_num, dist_cuml) %>%
    group_by(transect_id, piece) %>% mutate(dist_cuml = na.locf(dist_cuml)) %>%
    group_by(transect_id, piece, seg_num) %>%
    mutate(seg_brk = as.integer(ifelse(row_number() == n() & seg_num != nseg, 1, 0))) %>%
    select(-nseg) %>% group_by(transect_id, piece) %>%
    mutate(long = na.locf(long), lat = na.locf(lat),
           long_lead = na.locf(lead(long), na.rm = FALSE, fromLast = TRUE),
           lat_lead = na.locf(lead(lat), na.rm = FALSE, fromLast = TRUE)) %>%
    rowwise %>%
    # calculate heading between last waypoint and segment endpoint
    mutate(heading = as.numeric(ifelse(seg_brk == 0, NA, bearing(c(long, lat), c(long_lead, lat_lead), f = 0)))) %>%
    select(-c(seg_brk, long_lead, lat_lead)) %>% ungroup %>%
    group_by(transect_id, piece, dist_cuml) %>% mutate(heading = last(heading)) %>%
    group_by(transect_id, piece, seg_num) %>%
    # calculate distance between last waypoint and segment endpoint
    mutate(dist_shy = as.numeric(ifelse(is.na(heading), NA, seg_dist_cuml - dist_cuml))) %>%
    rowwise %>%
    # calculate coordinates of segment endpoints
    mutate(coords_end = ifelse(is.na(heading), list(NA), list(destPoint(c(long, lat), heading, dist_shy * 1000, f = 0)))) %>%
    select(-c(heading, dist_shy)) %>% ungroup
  
  # create rows for segment endpoints
  end.pts = seg.all %>% select(-empty_seg) %>% filter(!is.na(coords_end)) %>%
    mutate(long = unlist(lapply(coords_end, `[[`, 1)), lat = unlist(lapply(coords_end, `[[`, 2)), dist_cuml = seg_dist_cuml) %>%
    select(-c(coords_end, seg_dist_cuml))
  # create rows for segment start points and combine with segment endpoints
  seg.ends = end.pts %>% select(-seg_dist) %>% mutate(seg_num = seg_num + 1) %>% bind_rows(end.pts, .)
  
  # combine segment start points and endpoints with other waypoints
  seg.all.new = seg.all %>% filter(is.na(empty_seg)) %>% select(-c(empty_seg, seg_dist_cuml, coords_end)) %>%
    bind_rows(., seg.ends) %>% arrange(dataset_id, transect_id, piece, seg_num, dist_cuml) %>% select(-dist_cuml) %>%
    group_by(transect_id, piece, seg_num) %>%
    mutate(seg_dist = round(max(seg_dist, na.rm = TRUE), 3),
           id = paste(sprintf("%02d", transect_id), sprintf("%02d", piece), sprintf("%02d", seg_num), sep = "-")) %>%
    ungroup %>% select(-piece) %>% filter(seg_dist >= seg.min, seg_dist > 0)
  
  if(nrow(seg.all.new) == 0) stop("all segments shorter than seg.min")
  
  # -------- calculate segment midpoints ------------------------------------------------------------------------------------------
  # create dataframe suitable to become spatial lines object 
  listLines = function(df) {
    df %>% select(long, lat) %>% as.data.frame %>% Line %>% list
  }
  
  linelist = seg.all.new %>% group_by(transect_id, id) %>% do(coords = listLines(.))
  
  # define Hotine Oblique Mercator projection
  projHOM = "+proj=omerc +lonc=-75 +lat_0=35 +alpha=40 +k_0=0.9996 +ellps=GRS80 +datum=NAD83"
  
  # create spatial lines dataframe from segment waypoints and assign ID to each segment
  lineframe = mapply(x = linelist$coords, ids = linelist$id, function(x, ids) Lines(x, ids)) %>%
    SpatialLines(proj4string = CRS("+proj=longlat")) %>%
    SpatialLinesDataFrame(., as.data.frame(select(linelist, transect_id)), match.ID = FALSE) %>%
    # apply projection
    spTransform(CRS(projHOM))
  
    if (centroids) {
      # calculate geographic centroids of projected segments and convert back to lat/long
      midpoints = gCentroid(lineframe, byid = TRUE) %>% spTransform(CRS("+proj=longlat")) %>%
        as.data.frame %>% rename(mid_long = x, mid_lat = y) %>% rownames_to_column("id")
    }
    if (!centroids) {
    # calculate midpoints of projected segments and convert back to lat/long
    midpoints = SpatialLinesMidPoints(lineframe) %>% spTransform(CRS("+proj=longlat")) %>%
      as.data.frame %>% select(coords.x1, coords.x2) %>% rename(mid_long = coords.x1, mid_lat = coords.x2) %>%
      mutate(id = sapply(slot(lineframe, "lines"), function(x) slot(x, "ID")))
  }
  
  # merge segment midpoints with transect information
  seg.mids = seg.all.new %>% select(-c(long, lat)) %>% distinct %>% group_by(transect_id) %>% mutate(seg_num = seq.int(n())) %>%
    ungroup %>% left_join(., midpoints, by = "id") %>% select(-id) %>%
    left_join(., select(transects, transect_id, start_dt, transect_width_nb, survey_type_cd, survey_method_cd), by = "transect_id")
  
  # -------- assign segments to points --------------------------------------------------------------------------------------------
  # function modified from maptools::snapPointsToLines
  assignPointsToLines = function(points, lines, maxDist = NA) {
    
    # remove observations farther than maxDist from segment
    if (!is.na(maxDist)) {
      w = gWithinDistance(points, lines, dist = maxDist, byid = TRUE)
      validPoints = apply(w, 2, any)
      points = points[validPoints, ]
    }
    
    d = gDistance(points, lines, byid = TRUE) # distance matrix of each point to each segment
    seg_num = apply(d, 2, which.min) # position of each nearest segment in lines object
    
    # create data frame
    cbind(points@data, seg_num)
  }
  
  # wrapper function to restrict point to line pairing by transect ID
  obs2Lines = function(df, lineframe) {
    
    points = df %>% as.data.frame
    # apply HOM projection
    coordinates(points) = c("long", "lat")
    proj4string(points) = CRS("+proj=longlat")
    points = spTransform(points, CRS(projHOM))
    
    lines = lineframe[lineframe@data$transect_id == df$transect_id[1], ]
    
    assignPointsToLines(points, lines, maxDist)
  }
  
  # for each transect, find nearest segment to each point
  seg.obs = observations %>% filter(transect_id %in% seg.mids$transect_id) %>%
    group_by(transect_id) %>% do(obs2Lines(., lineframe)) %>% ungroup
  
  # join segment midpoints and observations
  segmented = full_join(seg.mids, seg.obs, by = c("transect_id", "seg_num")) %>%
    mutate(spp_cd = replace(spp_cd, is.na(spp_cd), "NONE")) %>%
    group_by(dataset_id, transect_id, seg_num, start_dt, seg_dist, transect_width_nb,
             mid_long, mid_lat, survey_type_cd, survey_method_cd, spp_cd)
  
  # -------- summarize species data by segment and convert to wide form -----------------------------------------------------------
    if (!occurences) {
      # total species count
      segmented = segmented %>% summarise(count = sum(count)) %>%
        spread(spp_cd, count, fill = 0) %>% select(everything(), -matches("NONE")) %>% ungroup
    }
    if (occurences) {
      # number of species occurences
      segmented = segmented %>% select(-count) %>% summarise(noccur = n()) %>%
        spread(spp_cd, noccur, fill = 0) %>% select(everything(), -matches("NONE")) %>% ungroup
    }
  
  # add descriptive dataset and transect IDs
  segmented = transects %>% select(transect_id, source_dataset_id, segmented_transect_id) %>% distinct %>%
    left_join(segmented, ., by = "transect_id") %>%
    select(source_dataset_id, segmented_transect_id, everything(), -dataset_id) %>%
    arrange(transect_id, seg_num) %>% mutate(transect_id = factor(transect_id))

}

### example run ###
source("Q:/Kyle_Working_Folder/Segmentation/pre_seg_new.R")
seg.dat.cts = segmentCTS(obs.pre, shp.pre, cts.dat, seg.min = 0)
