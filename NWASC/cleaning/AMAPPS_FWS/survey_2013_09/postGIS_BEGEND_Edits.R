# postGIS_BEGEND_Edits

track.final$dataChange = as.character(track.final$dataChange)

# add BEG/END for fhr 321100
to.add = filter(track.final, type %in% c("BEGSEG","ENDSEG") & obs %in% "mtj" & transect %in% 321100) %>%
  mutate(obs = replace(obs,obs %in% "mtj","fhr"),
         key = replace(key, key %in% "Crew3316-321100-2013-9-18-rf", "Crew3316-321100-2013-9-18-lf"),
         seat = replace(seat, seat %in% "rf", "lf"),
         dataChange = "added points from Crew3316-321100-2013-9-18-rf mtj",
         ID = replace(ID, ID %in% 18225, 4033.01),
         ID = replace(ID, ID %in% 18360, 4033.99))
track.final = bind_rows(track.final, to.add)
rm(to.add)

# add BEG/END for jsw 364101
to.add = filter(track.final, type %in% c("BEGSEG","ENDSEG") & obs %in% "phl" & transect %in% 364101) %>%
  mutate(obs = replace(obs,obs %in% "phl","jsw"),
         key = replace(key, key %in% "Crew3651-364101-2013-9-18-rf", "Crew3651-364101-2013-9-18-lf"),
         seat = replace(seat, seat %in% "rf", "lf"),
         dataChange = "added points from Crew3651-364101-2013-9-18-rf phl",
         ID = replace(ID, ID %in% 41220, 28763.01),
         ID = replace(ID, ID %in% 41270, 28763.99))
track.final = bind_rows(track.final, to.add)
rm(to.add)

track.final = track.final %>% arrange(key, sec)

#
track.final$sec[track.final$ID %in% 87698] = 49536.0
track.final$sec[track.final$ID %in% 87662] = 49361.04
