library(dplyr)
library(lubridate)

library(readr)
Dataset160_leg_tran_id <- read_csv("~/boem_noaa/Phase II Data and Code/Dataset160_leg_tran_id.csv")
# View(Dataset160_leg_tran_id)
missingtransects = Dataset160_leg_tran_id

fix_transect_names_160 = function(.df,missingtransects=Dataset160_leg_tran_id){
  missingtransects$leg = as.character(missingtransects$leg)
  save_df = .df %>% filter(dataset_id != 160)
  change_df = .df %>% filter(dataset_id == 160) %>%
    mutate(leg = source_transect_id) %>%
    left_join(missingtransects, by = 'leg') %>%
    mutate(
      datechr = as.numeric(format(start_dt, '%Y%m%d')),
      source_transect_id =
             paste(source_dataset_id,datechr,transect,leg, sep = "-"))

  new_df = bind_rows(save_df, change_df)
}
