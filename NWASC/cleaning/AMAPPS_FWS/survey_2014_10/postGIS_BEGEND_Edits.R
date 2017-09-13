#----------#
# remove BEG/END counts that were added but are not legitimate
#----------#

#IDs to remove, invalid BEG/END added 
to.remove = c(4698.99,4704.01,
  6730.99,6736.01,
  9361.99,9368.01,
  9401.99,9406.01,9651.99,9655.01,
  30159.99,30162.01,
  30385.99,30388.01, 
  5157.99:5176.01,
  6206,6207,6208,
  30160:30162, 30386:30388,
  30562.99, 30563:30566, 30566.01,
  30716.99, 30717:30719.00, 30719.01,
  30997.01, 30993.99, 30994:30997, 31108.99,31109,31110,31110.01, 31104.01, 31106.99,
  31380.99, 31383.01, 31381:31383,
  3211.99, 32619.01, 32615.99, 32616:32619,
  32854.99, 32857.01, 32855:32857, 33064.99, 33065:33066, 33066.01,
  33344.99, 33348.01, 33345:33348,32341.01, 32338.99, 32339:32341,
  36069,36070,36071,
  37314.01, 37312:37314, 37311.99, 39037.01, 39033.99, 39034:39037,
  39252.99, 39256.01, 39253:39256, 39538.99, 39541.01, 39539:39541,
  42209,42210,42211,47127,47129,47130,49901,49902,49903,
  53369,53370,53371,
  58162,58163,58164,
  51451.99, 51455.01, 51452:51455, 50694.99, 50698.01, 50695:50698,
  5158:5176, 5176.01,  
  51784.99, 51788.01, 51785:51788, 51823.99, 51827.01, 51824:51827, 
  52217.99, 52221.01, 52218:52221,
  52646.99, 52650.01, 52647:52650,
  53089.99, 53093.01, 53090:53093, 53454.01, 53458.99, 53515.99, 53519.01, 53516:53519,
  53520, 53932.99, 53933:53937, 53937.01,
  56777.99, 56778:56781, 56781.01, 56922.99, 56923:56926, 56926.01,
  57156.99, 57157:57160, 57160.01,
  57464.99, 57465:57468, 57468.01,
  57794.99, 57798.01, 57795:57798,
  57799, 58111.99, 58115.01, 58112:58115,
  58725.99, 58729.01, 58726:58729,
  59286.99, 59290.01, 59287:59290,
  93574,93575,93576,
  94012.99, 94018.01, 94013:94018,
  94240.99, 94255.01, 94241:94255, 94359.99, 94365.01, 94360:94365,
  95110.99, 95117.01, 95111:95117, 95301.99, 95307.01, 95302:95307, 95325.99, 95331.01, 95326:95331,
  97695.99, 97701.01, 97696:97701,
  97926.99, 97932.01, 97927:97932,
  99025.99, 99026:99031, 99031.01,
  100135.99, 100136:100141, 100141.01,
  100551.99, 100552:100557, 100557.01,
  100760.99, 100761:100767, 100767.01,
  102614.99, 102615:102621, 102621.01,
  102851.99, 102852:102857, 102857.01,
  104453.01,
  105425:105432, 
  105433:105435,
  105412.01, 105412.99, 105249.99, 105741.01, 105741.99, 105250, 105251, 
  106468.01, 106089.99, 106468.99, 106089.01, 
  109262.99, 109263:109265, 109265.01, 109353.99, 109354:109360, 109360.01,
  120380.99, 120381:120382, 120382.01,
  120982.99, 120983:120984, 120984.01,
  122226.99, 122227:122228, 122228.01,
  12320,12321,12322,
  127812.99, 127813:127815, 127815.01, 127817.99, 127818:127821, 127821.01,
  133429.99,133430:133499,133499.01,
  17229,17230,17231,19992,19993,19994,23427,23428,23429,
  28212,28213,28214,
  62033,62034,62035,67020,67021,67022,
  71879,71881,71882,74671,74672,
  74673,79519,79520,79521,
  89433,89434,89435, 
  125403.99, 125404:125409, 125409.01, 125414.99, 
  125415:125420, 125420.01, 125425.99, 125426:125430, 125430.01,
  125430.99, 125431:125433, 125433.01,
  131265:131267, 139671, 139672, 139674, 
  134123.99, 134124:134125, 134125.01,
  145672.99, 145673:145678, 145678.01, 145683.99, 145684:145689, 145689.01, 
  145694.99, 145695:145699, 145699.01, 145699.99, 145700:145702, 145702.01, 151435:151437, 159770:159772,
  145715.99, 145716, 
  145717:145720,145720.01,
  154016.99, 154017:154019, 154019.01,
  154727.99, 154728:154729, 154729.01
)

deletedPoints = bind_rows(deletedPoints, track.final[track.final$ID %in% to.remove,]) %>% arrange(ID)
track.final = track.final[!track.final$ID %in% to.remove,]  
#----------#


#----------#
# change based on time/distance travels between points - doesn't make sense
#----------#
track.final$type[track.final$ID %in% c(53521, 57800, 105443, 105252, 3212, 32858, 98658, 105722, 105443)] = "BEGSEG"
track.final$type[track.final$ID %in% c(33020.01, 98657, 104453, 105721, 105424)] = "ENDSEG"
#----------#


#----------#
# change offline
#----------#
track.final$offline[track.final$ID == 53459.00] = 0
#----------#


#----------#
# change BEG/ENDCNT to BEG/ENDSEG
#----------#
# CHANGE BEGSEG/ENDSEG TO BEGCNT/ENDCNT WHEN NECESSARY (AND VICE VERSA)
track.final = track.final %>% as.data.frame %>%
  dplyr::mutate(key = paste(crew, seat, month, day, transect, sep="_")) 
track.final = track.final %>% group_by(key) %>% 
  dplyr::mutate(type = replace(type, row_number()==1 & type=="BEGCNT","BEGSEG"),
                type = replace(type, row_number()==n() & type=="ENDCNT","ENDSEG"),
                type = replace(type, row_number()!=1 & type=="BEGSEG","BEGCNT"),
                type = replace(type, row_number()!=n() & type=="ENDSEG","ENDCNT")) %>% 
  arrange(ID)
#----------#


#----------#
# test points
#----------#
#t = c(442601)
#s = "rf"
#x = track.final[track.final$transect %in% t & track.final$seat == s,]
#x = select(x, sec, long, lat, transect, count, month, day, seat, type, key, ID, dataChange)
#plot(x$long,x$lat,col="grey")
#points(x$long[x$type %in% c("BEGSEG")], x$lat[x$type %in% c("BEGSEG")], col="darkgreen",pch=11)
#points(x$long[x$type %in% c("ENDSEG")], x$lat[x$type %in% c("ENDSEG")], col="darkred",pch=11)
#points(x$long[x$type %in% c("BEGCNT")], x$lat[x$type %in% c("BEGCNT")], col="green",pch=15)
#points(x$long[x$type %in% c("ENDCNT")], x$lat[x$type %in% c("ENDCNT")], col="red",pch=16)

#ind = c(30514.01)
#points(x$long[x$ID %in% ind], x$lat[x$ID %in% ind],col="purple",pch=0)

#----------#
# observer errors, waypoints and some BEG/END segments that were added dont have observer codes
#----------#
track.final$obs = as.character(track.final$obs)
track.final$obs[track.final$seat=="lf" & track.final$crew=="Crew3521"] = "jsw"
track.final$obs[track.final$seat=="rf" & track.final$crew=="Crew3521" & 
                  track.final$day %in% c(8,9,10,11,13,15,16)] = "fr"
track.final$obs[track.final$seat=="rf" & track.final$crew=="Crew3521" & 
                  track.final$day %in% c(21,22)] = "mtj"

track.final$obs[track.final$seat=="lf" & track.final$crew=="Crew4446"] = "mdk"
track.final$obs[track.final$seat=="rf" & track.final$crew=="Crew4446"] = "sfy"

track.final$obs[track.final$seat=="lf" & track.final$crew=="Crew4126"] = "sde"
track.final$obs[track.final$seat=="rf" & track.final$crew=="Crew4126"] = "mtj"

track.final$obs[track.final$obs=="fr"]="fhr"

track.final$obs = toupper(track.final$obs)
#ggplot(track.final[track.final$seat=="lf"& track.final$crew=="Crew4446" & track.final$day==22,], 
#       aes(x=long,y=lat,col=transect)) + geom_point(size=1) + scale_color_brewer(palette="Paired")
#----------#


#----------#
# Condition codes with 0 that throw off the avg. cond.
#----------#
track.final$condition[track.final$ID %in% c(120663.99, 114836.99, 114919.99)] = 3 
track.final$condition[track.final$ID %in% c(113494.99, 100340.99, 100416.99, 100422.01,
                                            99743.99, 99925.99, 99931.01)] = 4
#----------#


#----------#
# whales
#----------#
track.final$comment[track.final$type %in% c("UNWH","HUWH") & track.final$count %in% c(300)] = "Distance: 300; count undefined"
track.final$count[track.final$type %in% c("UNWH","HUWH") & track.final$count %in% c(300)] = 1
track.final$comment[track.final$type %in% c("UNWH") & track.final$count %in% c(400)] = "Distance: 400; count undefined"
track.final$count[track.final$type %in% c("UNWH") & track.final$count %in% c(400)] = 1
#----------#


#----------#
# add data that was rewritten when breaking apart the OBS1401 and OBS1402 datafiles by day
# 10/16 occurred in both so only data from OBS1402 was kept, OBS1401 10/16 file was rewritten
# this has been corrected in the Crew4126rf10162014_birds file but instead of starting over I'm adding the observations here
# If this is re-run from the beginning and new temp shapefiles made this should be deleted
# as well as probably a lot of the editing done up top...
#----------#
library(xlsx)
require(zoo)
to.add = read.xlsx(paste(dir.out, "/data_that_was_rewritten.xlsx", sep=""), sheetIndex=1,
                   stringsAsFactors=FALSE, head = FALSE)
colnames(to.add) = c("year","month","day","seat","obs","x","condition","y","WAVfile",
                     "lat","long","sec","GPSerror","type","count","band","behavior")
to.add = select(to.add,-x,-y) # nulls/na columns
to.add$file = "data_that_was_rewritten.xlsx but corrected in Crew4126rf10162014_birds.csv"
to.add$crew = "Crew4126"
to.add = to.add %>% mutate(transect = count, transect = replace(transect, transect<1000, NA)) %>% 
  mutate(transect = na.locf(transect))

#check codes
#sort(unique(to.add$type[!to.add$type %in% spplist]))
old = to.add$type
to.add$type[to.add$type %in% "BBGU"]="UBBG"
to.add$type[to.add$type %in% "BIRD"]="UNBI"
to.add$type[to.add$type %in% "GULL"]="UNGU" 
to.add$type[to.add$type %in% "HEGU"]="HERG"  
to.add$type[to.add$type %in% "LOON"]="UNLO"  
to.add$type[to.add$type %in% "SCOT"]="UNSC"
tmp = to.add$type != old
to.add$dataChange = ""
to.add$dataChange[tmp] = paste("changed TYPE from ", old[tmp], sep = "")
rm(tmp, old)

# set ID base on whats already there from the track data and inserted BEG/END counts
to.add = mutate(to.add, count = as.character(count), 
                transect = as.factor(transect))
to.add$ID = c(104394.89, 104405.99, 104407.99, 104414.99, 104428.99, 104429.99, 104441.99, 104443.89, 104443.99, 104446.99,
              104473.89, 104473.97, 104473.98, 104473.99, 104494.99, 104498.99, 104503.99, 104510.99, 104517.89, 104517.99, 104523.99, 104546.99, 104548.99, 104562.99, 104579.99, 104618.99, 104623.99,
              104659.99, 104664.99, 104669.99, 104689.99, 104715.99, 104724.99, 104758.99, 104763.99, 104787.99, 104812.99, 
              104851.99, 104891.99, 104969.99,
              105013.99, 105153.99, 105188.99,
              105253.99, 105404.99, 105415.99,
              105435.99, 105438.99, 105438.99, 105438.99, 105438.99, 105451.99, 105454.89, 105454.99, 105456.99, 105485.99, 105488.89, 105488.99, 105491.99, 105494.99, 105496.99, 105542.99,
              105586.99, 105586.99, 105648.99, 105651.99, 105716.99,
              105721.99, 105898.99,
              105949.99, 106099.99, 106103.99, 106123.99, 106138.99, 106140.99, 106146.99,
              106187.99, 106192.99, 106305.99, 106332.99,
              106371.99, 106495.99, 106518.99, 
              106558.99, 106697.99,
              106734.99, 106881.99, 
              107176.99, 107178.99, 107238.99, 107297.99)

#x = track.final[track.final$transect==382100 & track.final$seat=="rf",]
#x = bind_rows(x,to.add[to.add$transect==382100,]) %>% arrange(sec)

#test IDS
#x = track.final[track.final$transect %in% c(391600, 391100, 390601, 390100,
#                                            390101, 385602, 385601, 385100,
#                                            385101, 384601, 384100, 383601,
#                                            383100, 382601, 382100) & track.final$seat=="rf",]


# add from deleted points to track.final
track.final = as.data.frame(track.final)
track.final$type[track.final$ID %in% c(105443, 105722)] = NA # were defined as BEG/END points, but now unneccessary and turned to waypoint 
track.final = bind_rows(track.final, deletedPoints[deletedPoints$ID %in% c(104474:104488,
                                                                           104660:104663,
                                                                           104852:104857,
                                                                           105014:105015,
                                                                           105587:105592,
                                                                           105950,
                                                                           106188:106194,
                                                                           106372:106274,
                                                                           106559:106564,
                                                                           106735:106379,
                                                                           107177:107182,
                                                                           105652:105690),])
deletedPoints = deletedPoints[!deletedPoints$ID %in% c(104474:104488,104660:104663,104852:104857,
                                                      105014:105015,105587:105592,105950,106188:106194,
                                                      106372:106274,106559:106564,106735:106379,
                                                      107177:107182,105652:105690),]

# fix transects of delected points
track.final$transect[track.final$ID %in% c(107177, 107178, 107179:107182)] = 382100
track.final$transect[track.final$ID %in% c(106735)] = 382601
track.final$transect[track.final$ID %in% c(106559:106564)] = 383100
track.final$transect[track.final$ID %in% c(106372)] = 383601
track.final$transect[track.final$ID %in% c(106188:106192, 106193, 106194)] = 384100
track.final$transect[track.final$ID %in% c(105950)] = 384601
track.final$transect[track.final$ID %in% c(105587:105592, 105652:105690)] = 385100

# add to track.final
track.final = bind_rows(track.final, to.add)
rm(to.add)

# remove
to.remove = c(104393.99, 104447:104453, 104394,
              104488.99,
              104624:104632, 104632.99, 104632.01,
              104663.99, 104813:104819, 104819.01, 
              104857.99, 104970:104977, 104977.01,
              105015.99,
              105189:105197, 105197.01, 
              105252, 105253, 105416:105424,
              105543:105549, 105549.01,
              105592.99, 105717:105721,
              105649:105651, 105651.01, 105690.99,
              105899:105906, 105906.01,
              105950.99, 106147:106154, 106154.01,
              106194.99,
              106333:106342, 106342.01,
              106374.99, 106519:106526, 106526.01,
              106564.99, 106698:106707, 106707.01,
              106739.99, 106882:106888, 106888.99,
              106882:106888, 106888.01,
              107182.99, 107298:107305, 107305.01,
              106343:106371, 106527:106558, 106708:106734)

deletedPoints = bind_rows(deletedPoints, track.final[track.final$ID %in% to.remove,]) %>% arrange(ID)
track.final = track.final[!track.final$ID %in% to.remove,]
rm(to.remove)
#----------#


#----------#
# fix key for those points added
#----------#
track.final = track.final %>% mutate(key = paste(crew, seat, year, month, day, transect, sep="_"))
#----------#


#----------#
# other random errors
#----------#
# fix boat counts
track.final$count = as.numeric(track.final$count)
track.final$distance.from.observer = NA

track.final$comment[track.final$type %in% "BOTD" & track.final$count > 7 & !is.na(track.final$count)] = 
  paste("; distance: ",
        track.final$count[track.final$type %in% "BOTD" & track.final$count > 7 & !is.na(track.final$count)],
        "; count not listed",sep = "")
track.final$distance.from.observer[track.final$type %in% "BOTD" & track.final$count > 7 & !is.na(track.final$count)] = 
  track.final$count[track.final$type %in% "BOTD" & track.final$count > 7 & !is.na(track.final$count)]
track.final$count[track.final$type %in% "BOTD" & track.final$count > 7 & !is.na(track.final$count)] = 1
#
track.final$comment[track.final$type %in% "BOTD" & is.na(track.final$count)] = 
  paste(track.final$comment[track.final$type %in% "BOTD" & is.na(track.final$count)],
        "; count not listed", sep = "")
track.final$count[track.final$type %in% "BOTD" & is.na(track.final$count)] = 1
#
track.final$distance.from.observer[track.final$comment %in% c("; distance: 1.5; count not listed")] = 1.5
track.final$distance.from.observer[track.final$comment %in% c("; distance: .5; count not listed", 
                                                              "; distance: 0.5; count not listed")] = 0.5
track.final$distance.from.observer[track.final$comment %in% c("; distance: .75; count not listed")] = 0.75
track.final$distance.from.observer[track.final$comment %in% c("1")] = 1                                 
track.final$distance.from.observer[track.final$comment %in% c("100")] = 100                                
track.final$distance.from.observer[track.final$comment %in% c("1000")] = 1000                               
track.final$distance.from.observer[track.final$comment %in% c("150")] = 150                               
track.final$distance.from.observer[track.final$comment %in% c("1600")] = 1600                               
track.final$distance.from.observer[track.final$comment %in% c("2")] = 2                                  
track.final$distance.from.observer[track.final$comment %in% c("20")] = 20                                
track.final$distance.from.observer[track.final$comment %in% c("200")] = 200                                
track.final$distance.from.observer[track.final$comment %in% c("3")] = 3                                  
track.final$distance.from.observer[track.final$comment %in% c("300")] = 300                               
track.final$distance.from.observer[track.final$comment %in% c("4")] = 4                                  
track.final$distance.from.observer[track.final$comment %in% c("400")] = 400                                
track.final$distance.from.observer[track.final$comment %in% c("50")] =  50                               
track.final$distance.from.observer[track.final$comment %in% c("500")] = 500                                
track.final$distance.from.observer[track.final$comment %in% c("600")] = 600                                
track.final$distance.from.observer[track.final$comment %in% c("700")] = 700                             
track.final$distance.from.observer[track.final$comment %in% c("800")] = 800   

# fix behaviors that were in momments
track.final$behavior[track.final$comment %in% c("F","f","flying","fly", "F; Transect flown more than one day", "F; Transect flown more than one day ") & is.na(track.final$behavior)] = 
  "flying"
track.final$behavior[track.final$comment %in% c("S","s","sit", "S; Transect flown more than one day", "S; Transect flown more than one day ") & is.na(track.final$behavior)] = 
  "sitting"
track.final$behavior[track.final$behavior %in% c("F","f")] = "flying"
track.final$behavior[track.final$behavior %in% c("S","s")] = "sitting"
#----------#


#----------#
# check that after edits, all transect have equal BEG/END segs & cnts
#----------#
track.final %>% group_by(key) %>% filter(type %in% c("BEGCNT","ENDCNT","BEGSEG","ENDSEG")) %>% 
  summarize(ns = n()) %>% filter(ns %% 2 != 0)

track.final %>% group_by(key) %>% filter(type %in% c("BEGCNT","ENDCNT")) %>% 
  summarize(ns = n()) %>% filter(ns %% 2 != 0)

track.final %>% group_by(key) %>% filter(type %in% c("BEGSEG","ENDSEG")) %>% 
  summarize(ns = n()) %>% filter(ns %% 2 != 0)
#----------#


