obstrack$transect[obstrack$transect %in% 0] = NA


#------------#
# test plot
#------------#
s = "rf"
t = 295600
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
ggplot()+
  geom_line(data = design[design$latidext %in% t,], aes(x=long, y=lat), col="grey",lwd=2) +
  geom_point(data = x,aes(x = long, y = lat, col = as.character(transect))) + theme_bw()+
  geom_point(data = filter(x, type %in% "BEGCNT"), aes(x=long, y=lat), col="green", pch = 24, size = 3) +
  geom_point(data = filter(x, type %in% "ENDCNT"), aes(x=long, y=lat), col="red", pch = 25, size = 3)
#------------#


#------------#
# corrections based on visuals
#------------#

# Crew3521_lf_2018_8_22 302100       3
# dup. END
obstrack$type[obstrack$type %in% "ENDCNT" & obstrack$transect %in% 302100 & obstrack$seat %in% "lf"][2] = "delete"

# Crew3521_rf_2018_8_16 350600       5
# Changed TRANSECT from 352101 (doesn't make sense with this transect either)
obstrack$type[obstrack$type %in% "BEGCNT" & obstrack$transect %in% 350600 & obstrack$seat %in% "rf" & obstrack$sec %in% 40240.68] = "COMMENT"
obstrack$offline[obstrack$transect %in% 350600 & obstrack$seat %in% "rf" & obstrack$sec <54502.79] = 1
obstrack$transect[obstrack$transect %in% 350600 & obstrack$seat %in% "rf" & obstrack$sec <54502.79] = NA

# Crew3521_rf_2018_8_22 302100       1 
# missing end, just pulling from last point, not track
to.add = obstrack[obstrack$transect %in% 302100 & obstrack$sec %in% 54376.95 & obstrack$seat %in% "rf",]
to.add = mutate(to.add, type = "ENDCNT",
                original.spp.codes = NA,
                dataChange = "ENDCNT added from last observation",
                index = index+0.1)
obstrack = rbind(obstrack, to.add)
rm(to.add)

# Crew3521_rf_2018_8_23 293100       1
#add end
to.add = obstrack[obstrack$transect %in% 293100 & obstrack$sec %in% 45520.38 & obstrack$seat %in% "rf",]
to.add = mutate(to.add, type = "ENDCNT",
                original.spp.codes = NA,
                dataChange = "ENDCNT added from last observation",
                index = index+0.1)
obstrack = rbind(obstrack, to.add)
rm(to.add)

# Crew3521_rf_2018_8_23 295600       1
to.add = obstrack[obstrack$transect %in% 295600 & obstrack$sec %in% 38480.73 & obstrack$seat %in% "rf",]
to.add = mutate(to.add, type = "ENDCNT",
                original.spp.codes = NA,
                dataChange = "ENDCNT added from last observation",
                index = index+0.1)
obstrack = rbind(obstrack, to.add)
rm(to.add)

# Crew4126_rf_2018_8_18 372601       3
# changed from 372602 due to distance - will change back to 372602 with track points after 
obstrack$transect[obstrack$transect %in% 372601 & obstrack$seat %in% "rf" & obstrack$sec >= 44986.59 & !obstrack$type  %in% "ENDCNT"] = 372602
# Crew4126_rf_2018_8_18 372602       1 -> the solution above resolves this

# Crew4126_rf_2018_8_22 411100       7
# this is an observation, not a BEGCNT, its a typo that needs to be checked on WAV file
obstrack$type[obstrack$type %in% "BEGCNT" & obstrack$transect %in% 411100 & obstrack$seat %in% "rf" & obstrack$sec %in% 51161.61] = "COSH"

# Crew4446_rf_2018_8_16 442101       5
# COCH was offline, before start
obstrack$offline[obstrack$transect %in% 442101 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"] = 1
obstrack$transect[obstrack$transect %in% 442101 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"] = NA
# duplicate end point
obstrack$type[obstrack$type %in% "ENDCNT" & obstrack$transect %in% 442101 & obstrack$seat %in% "rf"][3] = "delete"

# Crew4446_rf_2018_8_17 440600      25
obstrack$dataChange[obstrack$transect %in% 440600 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 41704.96] = "type changed from ENDCNT"
obstrack$type[obstrack$transect %in% 440600 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 41704.96] = "COMMENT"

# Crew4446_rf_2018_8_17 441600      19
# offline, extra end after end point
obstrack$type[obstrack$transect %in%  441600 & obstrack$seat %in% "rf" & obstrack$sec > 37892.39] = "delete"

# Crew4446_rf_2018_8_17 442100       5
# offline, extra end after end point
obstrack$type[obstrack$transect %in%  441600 & obstrack$seat %in% "rf" & obstrack$sec > 33620.83] = "delete"

#Crew4446_rf_2018_8_16 443600      19
# duplicate beg
obstrack$type[obstrack$transect %in% 443600 & obstrack$seat %in% "rf" & obstrack$sec %in% 50308.7][2] = "delete"
# cut offline points
obstrack$transect[obstrack$transect %in% 443600 & obstrack$seat %in% "rf" & obstrack$lat<44] = NA

#Crew4446_rf_2018_8_17 433100       3
obstrack$offline[obstrack$transect %in% 433100 & obstrack$seat %in% "rf" & obstrack$sec >57972.25] = 1
obstrack$transect[obstrack$transect %in% 433100 & obstrack$seat %in% "rf" & obstrack$sec >57972.25] = NA
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_17" & obstrack$sec >57972.25] = "COMMENT"


# remove delete records
obstrack = filter(obstrack, !type %in% "delete")


