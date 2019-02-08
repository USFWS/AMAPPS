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

# 295100 rf
t = 295100
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# more BEG to start of transect
s1 = 43032.31
s2 = 42839.09
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "addend BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "BEGCNT"
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "changed BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "COMMENT"
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = 1

# 293600 rf
t = 293600
s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
# more BEG to start of transect
s1 = 38988.70
s2 = 38856.09
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "addend BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "BEGCNT"
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "changed BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "COMMENT"
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = 1

# 284100 rf
t = 284100
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = 47575.68
s2 = 47510.50
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "addend BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "BEGCNT"
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "changed BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "COMMENT"
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = 1

# 290100 rf
t = 290100
s = "rf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = 51325.82
s2 = 51251.42
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "addend BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "BEGCNT"
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "changed BEG because BEG was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "COMMENT"
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec < s1] = 1
s1 = 52207.15
s2 = 52240.08
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "addend END because END was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s1] = "ENDCNT"
obstrack$dataChange[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "changed END because END was too far from transect"
obstrack$type[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec %in% s2] = "COMMENT"
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1] = 1

# 323100
t = 323100
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

# 343100
t = 343100
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

# 405601
t = 405601
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

# 391601
t = 391601
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

# 383601
t = 383601
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

# 371602
t = 371602
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

# 411601
t = 411601
s = "lf"
x = filter(obstrack, seat %in% s, transect %in% t) %>% arrange(sec)
y = filter(x,type %in% c("BEGCNT","ENDCNT"))
testplot(t,s,x,y)
s1 = y$sec[2]
s2 = y$sec[3]
obstrack$transect[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec > s1 & obstrack$sec < s2] = NA
obstrack$offline[obstrack$seat %in% s & obstrack$transect %in% t & obstrack$sec> s1 & obstrack$sec < s2] = 1
