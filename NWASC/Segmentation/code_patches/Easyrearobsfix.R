library(readr)
MidAtlanticDetection2012_rear_observers <- read_csv("~/boem_noaa/Phase II Data and Code/MidAtlanticDetection2012_rear_observers.csv")
rearobs_trans_id = MidAtlanticDetection2012_rear_observers$transect_id
rearobsdrop <- function(.df) {
  new_data = .df %>% filter(!(transect_id %in% rearobs_trans_id))
  new_data
}
