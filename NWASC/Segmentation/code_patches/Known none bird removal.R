library(readr)
lu_species <- read_csv("~/boem_noaa/Phase II Data and Code/lu_species.csv")
# View(lu_species)

lu_species <- lu_species %>%
   mutate(
    knwn_no_bird = (lu_species$species_type_cd != 1),
    yes_bird = (lu_species$species_type_cd == 1),
    HEGU = (lu_species$species_type_cd == 'HEGU'),
    opps = is.na(knwn_no_bird) & is.na(yes_bird)
   ) %>%
   select(spp_cd, knwn_no_bird, yes_bird, opps, HEGU)

 keep_only_known_birds = function(dirty_obs){
  clean_obs = dirty_obs %>%
    left_join(lu_species, by = "spp_cd") %>%
    filter( yes_bird == TRUE) %>% #yes_bird == TRUE |
    select(-c(knwn_no_bird, yes_bird, opps))
  return(clean_obs)
 }

