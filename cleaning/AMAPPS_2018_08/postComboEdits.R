#------------#
# test plot
#------------#
# s = "rf"
# t = 363600
# x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
# y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot <- function(t,s,x,y){
  ggplot()+
  geom_line(data = design[design$latidext %in% t,], aes(x=long, y=lat), col="grey",lwd=2) +
  geom_point(data = x,aes(x = long, y = lat, col = as.character(transect))) + theme_bw()+
  geom_point(data = filter(x, type %in% "BEGCNT"), aes(x=long, y=lat), col="green", pch = 24, size = 3) +
  geom_point(data = filter(x, type %in% "ENDCNT"), aes(x=long, y=lat), col="red", pch = 25, size = 3)
}
#------------#

# 410100
obstrack$transect[obstrack$seat %in% "rf" & obstrack$transect %in% 410100 & obstrack$sec > 41363.95 & obstrack$sec < 45801.86] = NA
obstrack$offline[obstrack$seat %in% "rf" & obstrack$transect %in% 410100 & obstrack$sec> 41363.95 & obstrack$sec < 45801.86] = 1
obstrack$transect[obstrack$seat %in% "lf" & obstrack$transect %in% 410100 & obstrack$sec > 41340.67 & obstrack$sec < 45779.77] = NA
obstrack$offline[obstrack$seat %in% "lf" & obstrack$transect %in% 410100 & obstrack$sec> 41340.67 & obstrack$sec < 45779.77] = 1

# 395100
obstrack$transect[obstrack$seat %in% "lf" & obstrack$transect %in% 395100 & obstrack$sec > 33498.24 & obstrack$sec < 33635.48] = NA
obstrack$offline[obstrack$seat %in% "lf" & obstrack$transect %in% 395100 & obstrack$sec> 33498.24 & obstrack$sec < 33635.48] = 1
obstrack$transect[obstrack$seat %in% "rf" & obstrack$transect %in% 395100 & obstrack$sec > 33522.66 & obstrack$sec < 33660.20] = NA
obstrack$offline[obstrack$seat %in% "rf" & obstrack$transect %in% 395100 & obstrack$sec> 33522.66 & obstrack$sec < 33660.20] = 1

# 402100
obstrack$transect[obstrack$seat %in% "rf" & obstrack$transect %in% 402100 & obstrack$sec > 38468.80 & obstrack$sec < 38636.16] = NA
obstrack$offline[obstrack$seat %in% "rf" & obstrack$transect %in% 402100 & obstrack$sec> 38468.80 & obstrack$sec < 38636.16] = 1
obstrack$transect[obstrack$seat %in% "lf" & obstrack$transect %in% 402100 & obstrack$sec > 38434.25 & obstrack$sec < 38612.82] = NA
obstrack$offline[obstrack$seat %in% "lf" & obstrack$transect %in% 402100 & obstrack$sec> 38434.25 & obstrack$sec < 38612.82] = 1

# 380601
obstrack$transect[obstrack$seat %in% "lf" & obstrack$transect %in% 380601 & obstrack$sec > 51921.85 & obstrack$sec < 52231.29] = NA
obstrack$offline[obstrack$seat %in% "lf" & obstrack$transect %in% 380601 & obstrack$sec> 51921.85 & obstrack$sec < 52231.29] = 1
obstrack$transect[obstrack$seat %in% "rf" & obstrack$transect %in% 380601 & obstrack$sec > 51947.05 & obstrack$sec < 52255.50] = NA
obstrack$offline[obstrack$seat %in% "rf" & obstrack$transect %in% 380601 & obstrack$sec> 51947.05 & obstrack$sec < 52255.50] = 1

# 363600
t = 363600
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = y$sec[2]
s2 = y$sec[3]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1 & obstrack$sec < s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec> s1 & obstrack$sec < s2] = 1

s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = y$sec[2]
s2 = y$sec[3]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1 & obstrack$sec < s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec> s1 & obstrack$sec < s2] = 1

# 442601
t = 442601
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.25] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.25] = 1

s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = y$sec[2]
s2 = y$sec[3]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1 & obstrack$sec < s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec> s1 & obstrack$sec < s2] = 1

# 444100
t = 444100
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.5] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.5] = 1

# 443600
t = 443600
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.4] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.4] = 1
# may be on another transect - need to check

# 444600
t = 444600
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.6] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$lat < 44.6] = 1
# may be on another transect - need to check

# 432100
t = 432100
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# not even sure what happened here... 
obstrack$type[obstrack$transect %in% t & obstrack$seat %in% s] = obstrack$original.spp.codes[obstrack$transect %in% t & obstrack$seat %in% s]
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
s2 = y$sec[2]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = 1

# 432600
t = 432600
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# again, not sure what happened here... 
obstrack$type[obstrack$transect %in% t & obstrack$seat %in% s] = obstrack$original.spp.codes[obstrack$transect %in% t & obstrack$seat %in% s]
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
s2 = y$sec[2]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = 1

# 420600
t = 420600
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# not sure why END is missing...
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% 51178.68]="added ENDCNT"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% 51178.68]="ENDCNT"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
s2 = y$sec[2]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s2] = 1

# 314100
t = 314100
s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)

# 334100
t = 334100
s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# moving end up closer to transect

# 35101 rf
t = 351101
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# rf missing for 351101
