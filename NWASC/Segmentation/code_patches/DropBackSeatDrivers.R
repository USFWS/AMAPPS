
library(readr)
library(dplyr)
Transect_seat_Information <- read_csv("~/boem_noaa/Phase II Data and Code/Transect_seat_Information.csv")
# View(Transect_seat_Information)
Seat_info = Transect_seat_Information %>%
  filter(SurveyNbr == 10) %>%
  select(old_transect_num = Transect , Replicate,Seat,intials = Obs)

drop_rear_observer = function(.df) {
  droplines = .df %>%
    filter( dataset_id == 147)
    seperate(segmented_transect_id,c('survey', 'old_transect_num', 'yr', 'Replicate', 'intials'))
}

drop_rear_observer(cts.dat)
