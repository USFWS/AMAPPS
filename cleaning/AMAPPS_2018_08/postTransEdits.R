obstrack$transect[obstrack$transect %in% 0] = NA

#------------#
# test plot
#------------#
s = "rf"
t = 433600
x = filter(obstrack, seat %in% s, transect %in% t)
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

# Crew3521_lf_2018_8_22 302100       3 ######## STILL ISSUES WITH REST OF TRACKS #####
# dup. END
obstrack$type[obstrack$type %in% "ENDCNT" & obstrack$transect %in% 302100 & obstrack$seat %in% "lf"][2] = "delete"

# Crew3521_rf_2018_8_16 350600       5 ######## STILL ISSUES WITH REST OF TRACKS #####
# Changed TRANSECT from 352101 (doesn't make sense with this transect either)
obstrack$type[obstrack$type %in% "BEGCNT" & obstrack$transect %in% 350600 & obstrack$seat %in% "rf" & obstrack$sec %in% 40240.68] = "COMMENT"

# Crew3521_rf_2018_8_22 302100       1 ######## STILL ISSUES WITH REST OF TRACKS #####
# missing end
HELP

# Crew3521_rf_2018_8_23 293100       1
help

# Crew3521_rf_2018_8_23 295600       1
help

# Crew4126_rf_2018_8_18 372601       3
# changed from 372602 due to distance - will change back to 372602 with track points after 
obstrack$transect[obstrack$transect %in% 372601 & obstrack$seat %in% "rf" & obstrack$sec >= 44986.59 & !obstrack$type  %in% "ENDCNT"] = 372602
# Crew4126_rf_2018_8_18 372602       1 -> the solution above resolves this

# Crew4126_rf_2018_8_22 411100       7
# this is an observation, not a BEGCNT, its a typo that needs to be checked on WAV file
obstrack$type[obstrack$type %in% "BEGCNT" & obstrack$transect %in% 411100 & obstrack$seat %in% "rf" & obstrack$sec %in% 51161.61] = "COSH"


#--------#
#THE REST ARE ALL TIM WHITE

# Crew4446_rf_2018_8_16 442101       5
# COCH was offline, before start
obstrack$offline[obstrack$transect %in% 442101 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"] = 1
obstrack$transect[obstrack$transect %in% 442101 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"] = NA
# duplicate end point
obstrack$type[obstrack$type %in% "ENDCNT" & obstrack$transect %in% 442101 & obstrack$seat %in% "rf"][3] = "delete"

# Crew4446_rf_2018_8_16 442602       3
# COCH was offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  442602 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH" & obstrack$sec %in% 54263.88] = 1
obstrack$transect[obstrack$transect %in%  442602 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"& obstrack$sec %in% 54263.88] = NA
obstrack$offline[obstrack$transect %in%  442602 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 54263.88] = 1
obstrack$transect[obstrack$transect %in%  442602 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 54263.88] = NA
# also some weird points that were flagged can be removed -> will filter out this type at end
obstrack$type[obstrack$transect %in%  442602 & obstrack$seat %in% "rf" & obstrack$flag1 %in% 1 & obstrack$flag1b %in% 1] = "delete"

# Crew4446_rf_2018_8_16 443100       7
# BODO was offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  443100 & obstrack$seat %in% "rf" & obstrack$type %in% "BODO" & obstrack$sec %in% 51645.30] = 1
obstrack$transect[obstrack$transect %in%  443100 & obstrack$seat %in% "rf" & obstrack$type %in% "BODO"& obstrack$sec %in% 51645.30] = NA
obstrack$offline[obstrack$transect %in%  443100 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 51679.45] = 1
obstrack$transect[obstrack$transect %in%  443100 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 51679.45] = NA

# Crew4446_rf_2018_8_17 431600       3
# offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  431600  & obstrack$seat %in% "rf" & obstrack$sec < 59411.87] = 1
obstrack$transect[obstrack$transect %in% 431600  & obstrack$seat %in% "rf" &  obstrack$sec < 59411.87] = NA
obstrack$offline[obstrack$transect %in%  431600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 59411.87] = 1
obstrack$transect[obstrack$transect %in%  431600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 59411.87] = NA

# Crew4446_rf_2018_8_17 432600       3
# offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  432600  & obstrack$seat %in% "rf" & obstrack$sec < 58311.09] = 1
obstrack$transect[obstrack$transect %in% 432600  & obstrack$seat %in% "rf" &  obstrack$sec < 58311.09] = NA
obstrack$offline[obstrack$transect %in%  432600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 58311.09] = 1
obstrack$transect[obstrack$transect %in%  432600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 58311.09] = NA

# Crew4446_rf_2018_8_17 433600       3
# offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  433600  & obstrack$seat %in% "rf" & obstrack$sec < 56385.36] = 1
obstrack$transect[obstrack$transect %in% 433600  & obstrack$seat %in% "rf" &  obstrack$sec < 56385.36] = NA
obstrack$offline[obstrack$transect %in%  433600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 56385.36] = 1
obstrack$transect[obstrack$transect %in%  433600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 56385.36] = NA

# Crew4446_rf_2018_8_17 434600      21
# offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  434600 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH" & obstrack$sec %in% 51036.34] = 1
obstrack$transect[obstrack$transect %in%  434600 & obstrack$seat %in% "rf" & obstrack$type %in% "COCH"& obstrack$sec %in% 51036.34] = NA
obstrack$offline[obstrack$transect %in%  434600  & obstrack$seat %in% "rf" & obstrack$sec < 51036.34] = 1
obstrack$transect[obstrack$transect %in% 434600  & obstrack$seat %in% "rf" &  obstrack$sec < 51036.34] = NA
obstrack$offline[obstrack$transect %in% 434600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 51036.34] = 1
obstrack$transect[obstrack$transect %in%  434600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 51036.34] = NA

# Crew4446_rf_2018_8_17 435100       7
# extra Beg at end
obstrack$offline[obstrack$transect %in%  435100  & obstrack$seat %in% "rf" & obstrack$sec < 49452.03] = 1
obstrack$transect[obstrack$transect %in% 435100  & obstrack$seat %in% "rf" &  obstrack$sec < 49452.03] = NA
obstrack$offline[obstrack$transect %in%  435100  & obstrack$seat %in% "rf" & obstrack$sec > 50755.5] = 1
obstrack$transect[obstrack$transect %in% 435100  & obstrack$seat %in% "rf" &  obstrack$sec > 50755.5] = NA

# Crew4446_rf_2018_8_17 435600       3
# offline, before start and so was end point
obstrack$offline[obstrack$transect %in%  435600   & obstrack$seat %in% "rf" & obstrack$sec < 44370.55] = 1
obstrack$transect[obstrack$transect %in% 435600   & obstrack$seat %in% "rf" &  obstrack$sec < 44370.55] = NA
obstrack$offline[obstrack$transect %in% 435600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 44370.55] = 1
obstrack$transect[obstrack$transect %in%  435600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 44370.55] = NA

# Crew4446_rf_2018_8_17 440600      25
obstrack$dataChange[obstrack$transect %in% 440600 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 41704.96] = "type changed from ENDCNT"
obstrack$type[obstrack$transect %in% 440600 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 41704.96] = "COMMENT"

# Crew4446_rf_2018_8_17 441600      19
# offline, extra end after end point
obstrack$type[obstrack$transect %in%  441600 & obstrack$seat %in% "rf" & obstrack$sec > 37892.39] = "delete"

# Crew4446_rf_2018_8_17 442100       5
# offline, extra end after end point
obstrack$type[obstrack$transect %in%  441600 & obstrack$seat %in% "rf" & obstrack$sec > 33620.83] = "delete"

# Crew4446_rf_2018_8_19 413602       3
obstrack$offline[obstrack$transect %in%  413602 & obstrack$seat %in% "rf" & obstrack$sec > 59540.75] = 1
obstrack$transect[obstrack$transect %in% 413602  & obstrack$seat %in% "rf" &  obstrack$sec > 59540.75] = NA

# Crew4446_rf_2018_8_19 414601       3
# offline transect points, and extra end before start
obstrack$offline[obstrack$transect %in% 414601 & obstrack$seat %in% "rf" & obstrack$sec > 55665.77] = 1
obstrack$transect[obstrack$transect %in% 414601  & obstrack$seat %in% "rf" &  obstrack$sec > 55665.77] = NA
obstrack$offline[obstrack$transect %in% 414601  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 55401.77] = 1
obstrack$transect[obstrack$transect %in%  414601  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 55401.77] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 55401.77] = "COMMENT"

# Crew4446_rf_2018_8_19 415601       3
obstrack$offline[obstrack$transect %in% 415601 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 52741.50] = 1
obstrack$transect[obstrack$transect %in% 415601 & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 52741.50] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 52741.50] = "COMMENT"
obstrack$offline[obstrack$transect %in% 415601 & obstrack$seat %in% "rf" & obstrack$sec > 53004.06] = 1
obstrack$transect[obstrack$transect %in% 415601  & obstrack$seat %in% "rf" &  obstrack$sec > 53004.06] = NA
obstrack$offline[obstrack$transect %in% 415601 & obstrack$seat %in% "rf" & obstrack$sec < 52741.5] = 1
obstrack$transect[obstrack$transect %in% 415601  & obstrack$seat %in% "rf" &  obstrack$sec < 52741.5] = NA

# Crew4446_rf_2018_8_19 421100       3
obstrack$offline[obstrack$transect %in% 421100 & obstrack$seat %in% "rf" & obstrack$sec > 49810.78] = 1
obstrack$transect[obstrack$transect %in% 421100 & obstrack$seat %in% "rf" &  obstrack$sec > 49810.78] = NA
obstrack$offline[obstrack$transect %in% 421100  & obstrack$seat %in% "rf" & obstrack$type %in% "BEGCNT" & obstrack$sec %in% 49810.78] = 1
obstrack$transect[obstrack$transect %in%  421100  & obstrack$seat %in% "rf" & obstrack$type %in% "BEGCNT"& obstrack$sec %in% 49810.78] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "BEGCNT"& obstrack$sec %in% 49810.78] = "COMMENT"

# Crew4446_rf_2018_8_19 421600       3
obstrack$offline[obstrack$transect %in% 421600 & obstrack$seat %in% "rf" & obstrack$sec < 43118.02] = 1
obstrack$transect[obstrack$transect %in% 421600 & obstrack$seat %in% "rf" &  obstrack$sec < 43118.02] = NA
obstrack$offline[obstrack$transect %in% 421600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 43118.02] = 1
obstrack$transect[obstrack$transect %in%  421600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 43118.02] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 43118.02] = "COMMENT"

# Crew4446_rf_2018_8_19 423600       3
obstrack$offline[obstrack$transect %in% 423600 & obstrack$seat %in% "rf" & obstrack$sec < 38028.10] = 1
obstrack$transect[obstrack$transect %in% 423600 & obstrack$seat %in% "rf" &  obstrack$sec < 38028.10] = NA
obstrack$offline[obstrack$transect %in% 423600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT" & obstrack$sec %in% 38028.10] = 1
obstrack$transect[obstrack$transect %in%  423600  & obstrack$seat %in% "rf" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 38028.10] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "ENDCNT"& obstrack$sec %in% 38028.10] = "COMMENT"
obstrack$offline[obstrack$transect %in% 423600 & obstrack$seat %in% "rf" & obstrack$sec > 38761.66] = 1
obstrack$transect[obstrack$transect %in% 423600 & obstrack$seat %in% "rf" &  obstrack$sec > 38761.66] = NA

# Crew4446_rf_2018_8_19 424100       5
obstrack$offline[obstrack$transect %in% 424100 & obstrack$seat %in% "rf" & obstrack$sec > 37826.08] = 1
obstrack$transect[obstrack$transect %in% 424100 & obstrack$seat %in% "rf" &  obstrack$sec > 37826.08] = NA
obstrack$offline[obstrack$transect %in% 424100  & obstrack$seat %in% "rf" & obstrack$type %in% "BEGCNT" & obstrack$sec %in% 37826.08] = 1
obstrack$transect[obstrack$transect %in%  424100  & obstrack$seat %in% "rf" & obstrack$type %in% "BEGCNT"& obstrack$sec %in% 37826.08] = NA 
obstrack$type[obstrack$key %in% "Crew4446_rf_2018_8_19" & obstrack$type %in% "BEGCNT"& obstrack$sec %in% 37826.08] = "COMMENT"

--- still need to do
10 Crew4446_rf_2018_8_19 424600       3
1 Crew4446_rf_2018_8_19 425100       3
2 Crew4446_rf_2018_8_19 425600       3
3 Crew4446_rf_2018_8_19 430100       3
4 Crew4446_rf_2018_8_19 430600       3
5 Crew4446_rf_2018_8_19 431100       3
7 Crew4446_rf_2018_8_21 404601       3
8 Crew4446_rf_2018_8_21 405101       3
9 Crew4446_rf_2018_8_21 411101       3

# remove delete records
obstrack = filter(obstrack, !type %in% "delete")

#------------#
# test plot
#------------#
s = "rf"
t = 424100
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
ggplot()+
  geom_line(data = design[design$latidext %in% t,], aes(x=long, y=lat), col="grey",lwd=2) + 
  geom_point(data = x,aes(x = long, y = lat, col = as.character(transect))) + theme_bw()+
  geom_point(data = filter(x, type %in% "BEGCNT"), aes(x=long, y=lat), col="green", pch = 24, size = 3) +
  geom_point(data = filter(x, type %in% "ENDCNT"), aes(x=long, y=lat), col="red", pch = 25, size = 3) 
#------------#

