# #------------#
# # test plot
# #------------#
# s = "rf"
# t = 372602
# x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
# y = filter(x,type %in% c("BEGCNT","ENDCNT"))
# ggplot()+
#   geom_line(data = design[design$latidext %in% t,], aes(x=long, y=lat), col="grey",lwd=2) +
#   geom_point(data = x,aes(x = long, y = lat, col = as.character(transect))) + theme_bw()+
#   geom_point(data = filter(x, type %in% "BEGCNT"), aes(x=long, y=lat), col="green", pch = 24, size = 3) +
#   geom_point(data = filter(x, type %in% "ENDCNT"), aes(x=long, y=lat), col="red", pch = 25, size = 3)
# #------------#

# Crew4126_rf_2018_10_30 372601       3
# Crew4126_rf_2018_10_30 372602       1
obstrack$transect[obstrack$transect %in% 372601 & obstrack$seat %in% "rf" & obstrack$sec>51034.97] = 372602

