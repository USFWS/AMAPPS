# ---------------------------------------------------------------------------- #
# errorCheckObsFiles.R
# Date Created: 2011-09-06
# Author: JBL
# edited by: KColeman
#
# Description: This program checks the pilot and observer observation files 
# for errors and outputs them to a .csv file.
# ---------------------------------------------------------------------------- #

errorCheckObsFiles <- function(dat, dir.out, error.flag = FALSE) {

  # CHECK IF THERE IS AN UNEQUAL NUMBER OF BEGCNT AND ENDCNT ROWS FOR EACH SEGMENT
  checkBegEnd(dat) 
  
  # ---------------#
  # YEAR COLUMN SHOULD MATCH DATE FROM OBSERVATION FILE NAME
  # ---------------#
  year <- substr(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), 
                        byrow = TRUE)[, 2], 5, 8)
  if (any(nchar(year) == 2)) {year[(nchar(year) == 2)] = paste("20", year[nchar(year) == 2], sep = "")} # added for names w.o 20**
  tmp <- as.numeric(dat$year) != as.numeric(year) & !grepl("changed YEAR", dat$dataChange)
  message("Found ", sum(tmp), " errors in YEAR column.")
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; YEAR value does not match date in file name", 
                              sep = "")
  # ---------------#
  
  # ---------------#
  # MONTH COLUMN SHOULD MATCH DATE FROM OBSERVATION FILE NAME
  # ---------------#
  month <- substr(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), 
                         byrow = TRUE)[, 2], 1, 2)
  tmp <- as.numeric(dat$month) != as.numeric(month) & !grepl("changed MONTH", dat$dataChange)
  message("Found ", sum(tmp), " errors in MONTH column.")
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; MONTH value does not match date in file name", 
                              sep = "")
  # ---------------#
  
  # ---------------#
  # DAY COLUMN SHOULD MATCH DATE FROM OBSERVATION FILE NAME
  # ---------------#
  day <- substr(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), 
                       byrow = TRUE)[, 2], 3, 4)
  tmp <- as.numeric(dat$day) != as.numeric(day) & !grepl("changed DAY", dat$dataChange)
  message("Found ", sum(tmp), " errors in DAY column.")
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; DAY value does not match date in file name", 
                              sep = "")
  # ---------------#
  
  # ---------------#
  # SEAT COLUMN SHOULD ONLY BE "lf", "rf", "lr", OR "rr"
  # ---------------#
  seat <- substr(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), byrow = TRUE)[, 1], 
                 nchar(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), byrow = TRUE)[, 1]) - 1, 
                 nchar(matrix(unlist(strsplit(basename(dat$file), "_")), nrow = nrow(dat), byrow = TRUE)[, 1]))
  tmp <- !dat$seat %in% c("lf", "rf", "lr", "rr") #| (dat$seat != seat & !grepl("SEAT", dat$dataChange))
  message("Found ", sum(tmp), " errors in SEAT column.")
  if(sum(tmp)>0){dat[tmp]}
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Incorrectly coded SEAT", sep = "")
  # ---------------#
  
  # ---------------#
  # TRANSECT COLUMN SHOULD ONLY CONTAIN NUMBERS
  # ---------------#
  tmp <- grepl("[[:alpha:], [:punct:]]", dat$transect, ignore.case = TRUE)
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed TRANSECT from ", 
                               dat$transect[tmp], sep = "")
  dat$transect[tmp] <- gsub("[[:alpha:], [:punct:]]", "", dat$transect[tmp], 
                            ignore.case = TRUE)
  # ---------------#
  
  # ---------------#
  # CONDITION COLUMN 
  # ---------------#
  # SHOULD ONLY BE 1, 2, 3, 4, OR 5
  tmp <- !dat$condition %in% c("1", "2", "3", "4", "5") & 
    !grepl("added row for condition analysis", dat$dataChange) & 
    !(dat$condition == "0" & grepl("CONDITION", dat$dataChange))
  message("Found ", sum(tmp), " incorrectly coded in CONDITION values.")
  if(sum(tmp)>0){dat[tmp,]}
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Incorrectly coded CONDITION", 
                              sep = "")
  
 # these are no longer relevant for 2018 surveys since we changed protocol, but may be relevant again if we switch back
  # # COUNT==CONDITION
  # tmp <- dat$type == "COCH" & dat$condition %in% c("1", "2", "3", "4", "5") & 
  #   dat$condition != dat$count
  # message("Found ", sum(tmp[tmp %in% TRUE]), " additional errors in CONDITION column where CONDITION != COUNT.")
  # if(sum(tmp[tmp %in% TRUE])>0){dat[tmp,]}
  # dat$dataError[tmp %in% TRUE] <- paste(dat$dataError[tmp %in% TRUE], "; CONDITION != COUNT", sep = "")
   
  # # ARE THERE TWO COCHs (What the condition was and what it became - this is the protocol)
  # tmp <- dat %>% filter(type %in% 'COCH',!is.na(transect)) %>% group_by(obs,transect) %>% 
  #   summarise(n = n()) %>% filter(n %% 2 != 0)
  # message("Found ", dim(tmp)[1], " additional errors in CONDITION column where there are an odd number of COCHs.")
  # if(dim(tmp)[1]>0){print(tmp)}

  # CONDITION CODE IS ONLY LISTED WHEN THERE WAS AN ACTUAL CHANGE
  tmp <- dat[c(which(dat$type %in% 'COCH'),
               which(dat$type %in% 'COCH')+1,
               which(dat$type %in% 'COCH')-1),] %>% filter(offline %in% 0) %>% 
    select(year,month,day,obs,transect,sec,condition,type,index) %>% 
    arrange(month,day,obs,transect,sec,index) %>% group_by(obs,transect,day) %>% 
    filter(!duplicated(index)) %>% 
    mutate(condition = as.numeric(condition),
           lead.condition = lead(condition)-condition,
           lag.condition = lag(condition)-condition) %>% filter(type %in% 'COCH') %>% 
    summarise(sum.lead.condition = sum(lead.condition),
              sum.lag.condition = sum(lag.condition)) %>% 
    mutate(diff.in.conditions = sum.lead.condition+sum.lag.condition) %>% 
    filter(!diff.in.conditions %in% 0)
  message("Found ", dim(tmp)[1], " additional errors in CONDITION column where COCH doesn't reflect a change in condition.")
  if(dim(tmp)[1]>0){filter(dat,obs %in% tmp$obs, transect %in% tmp$transect, day %in% tmp$day, type %in% 'COCH') %>% 
      arrange(obs,transect,day,sec)}
  # ---------------#
   
  # ---------------#
  # SPECIES/TYPE CODES
  # ---------------#
  # FIX COMMON TYPE VALUE ERRORS 
  tmp <- dat$type %in% c("HEGU", "TRAWL", "BEGSSEG", "BEGSEG", "BEGCOUNT", "BDGCNT", 
                         "START", "ENDSSEG", "ENSEG", "ENDSEG", "ENDCOUNT", "STOP")
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed TYPE from ", 
                               dat$type[tmp], sep = "")
  dat$type[dat$type == "HEGU"] <- "HERG"
  dat$type[dat$type == "TRAWL"] <- "TRAW"
  dat$type[dat$type %in% c("BEGSSEG", "BEGSEG")] <- "BEGSEG"
  dat$type[dat$type %in% c("BEGCOUNT", "BDGCNT", "START")] <- "BEGCNT"
  dat$type[dat$type %in% c("ENDSSEG", "ENSEG", "ENDSEG")] <- "ENDSEG"
  dat$type[dat$type %in% c("ENDCOUNT", "STOP")] <- "ENDCNT"
  
  # COMPARE TYPE VALUES TO DATABASE SPECIES LIST
  db <- odbcConnectAccess2007("//ifw-hqfs1/MB SeaDuck/seabird_database/data_import/in_progress/NWASC_temp.accdb")
  spplist <- sqlFetch(db, "lu_species")
  odbcClose(db)
  
  ammendended.list = c(as.character(spplist$spp_cd),"BEGCNT","ENDCNT","BEGSEG","ENDSEG","COCH","COMMENT")
  tmp <- !obs$type %in% ammendended.list
  message("Found ", sum(tmp), " entries with non-matching AOU codes")
  
  if(sum(tmp)>0){dat[tmp,]}
  if (sum(tmp) > 0) {
    tab <- data.frame(table(dat$type[tmp]))
    names(tab) <- c("alpha_code", "freq")
    write.csv(tab, file.path(dir.out, "AOUErrors.csv"), row.names = FALSE)
  } else if (file.exists(file.path(dir.out, "AOUErrors.csv"))) {
    unlink(file.path(dir.out, "AOUErrors.csv"))
  }
  
  # FLAG TYPE == "MIXD" FOR CHECK
  tmp <- dat$type == "MIXD" & dat$offline != "1"
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Break into multiple lines", sep = "")
  # ---------------#
  
  # ---------------#
  # OFFLINE COLUMN 
  # ---------------#
  #SHOULD ONLY BE "0" OR "1"
  tmp <- tolower(dat$offline) %in% c("na", "no", "n", "", " ")
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed OFFLINE from ", 
                               dat$offline[tmp], sep = "")
  dat$offline[tmp] <- "0"
  tmp <- tolower(dat$offline) %in% c("yes", "y")
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed OFFLINE from ", 
                               dat$offline[tmp], sep = "")
  dat$offline[tmp] <- "1"
  
  # OBSERVATIONS WITH BAND == 3 SHOULD BE CODED AS OFFLINE
  if (!is.null(dat$band)) {
    tmp <- dat$band == 3 #& dat$offline != "1" # the second argument was creating NA's in the T F answer
    dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed OFFLINE from ", 
                                 dat$offline[tmp], sep = "")
    dat$offline[tmp] <- "1"
  }
  # had to add this when took & dat$offline != "1" out
  # IF OFFLINE NOT 0 OR 1, but NA and there is a transect #, change from NA to 0 
  dat$dataChange[is.na(dat$offline)][!is.na(dat$transect[is.na(dat$offline)])] = "changed OFFLINE from NA"
  dat$offline[is.na(dat$offline)][!is.na(dat$transect[is.na(dat$offline)])] = "0"
  
  # IF OFFLINE NOT 0 OR 1, FLAG AS ERROR
  tmp <- !dat$offline %in% c("0", "1")
  message("Found ", sum(tmp), " errors in OFFLINE column.")
  if(sum(tmp)>0){dat[tmp,]}
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Incorrectly coded OFFLINE", sep = "")
  # change from NA to 0 
  dat$dataChange[is.na(dat$offline)][!is.na(dat$transect[is.na(dat$offline)])] = "changed OFFLINE from NA"
  dat$offline[is.na(dat$offline)][!is.na(dat$transect[is.na(dat$offline)])] = "0"
  
  # FOR BEG/END POINTS, OFFLINE COLUMN SHOULD BE "0"
  # since some obs decided to keep track off offline/transit counts, need to also make sure there is a transect
  tmp <- !is.na(dat$transect) & dat$offline != "0" & dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT")
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed OFFLINE from ", 
                               dat$offline[tmp], sep = "")
  dat$offline[tmp] <- "0"
  # ---------------#
  
  # ---------------#
  # DISTANCE COLUMN 
  # ---------------#
  # distance should in in nautical miles
  # so if there are observations above 2, these are most likely in another unit. 
  # flag for investigation
  tmp <- which(dat$distance.to.obs > 2)
  message("Found ", length(tmp), " error(s) in DISTANCE column.")
  if(length(tmp)>0){dat[tmp,]}
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Possibly an incorrectly coded DISTANCE unit", sep = "")
  # ---------------#
   
  # ---------------#
  # COUNT COLUMN 
  # ---------------#
  # FOR TRAWLER OBSERVATIONS: IF COUNT COLUMN CONTAINS LETTERS, MOVE TO COMMENTS
  # added BOTD (boat trawl or dredge)
  tmp <- dat$type %in% c("TRAW","BOTD") & grepl("[[:alpha:], [:punct:]]", dat$count, ignore.case = TRUE)
  dat$comment[tmp] <- paste(dat$comment[tmp], "; distance: ", dat$count[tmp], sep = "")
  dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed COUNT from ", 
                               dat$count[tmp], sep = "")
  dat$count[tmp] <- ""
  
  # SHOULD ONLY CONTAIN POSITIVE NUMBERS
  tmp <- (grepl("[[:alpha:], [:punct:]]", dat$count, ignore.case = TRUE) & 
            !(dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT"))) | 
    (dat$count == "0" & !(dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH"))) & 
    !is.na(dat$count)
  message("Found ", sum(tmp), " errors in COUNT column.")
  if(sum(tmp)>0){dat[tmp,]}
  dat$dataError[tmp] <- paste(dat$dataError[tmp], "; Incorrectly coded COUNT", sep = "")
  
  # IF COUNT COLUMN IS 0, CHANGE TO MISSING
  tmp <- !is.na(dat$count) & dat$count == 0 & 
    !(dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH"))
  dat$count[tmp] <- NA
  
  # PRINT HOW MANY TIMES COUNT IS MISSING
  tmp <- is.na(dat$count) & dat$offline == 0 & 
    !(dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH", "BOTD","COMMENT")) #### added boat (trawler)
  if (sum(tmp) > 0) message("Missing COUNT for ", sum(tmp), " non-offline observations")
  
  # PRINT HOW MANY TIMES COUNT >= 10,000
  tmp <- dat %>% mutate(count = as.numeric(as.factor(count))) %>% 
    filter(!type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH","COMMENT"),
           count >= 10000)
  if (dim(tmp)[1] > 0) message("There are ", dim(tmp)[1], " observations with count >= 10,000")
  # ---------------#
  
  # ---------------#
  # FOR BEG/END/COCH POINTS, BAND COLUMN SHOULD BE 0 AND BEHAVIOR COLUMN SHOULD BE MISSING
  # ---------------#
  if (!is.null(dat$band)) {
    tmp <- dat$band != 0 & dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH")
    dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed BAND from ", 
                                 dat$band[tmp], sep = "")
    dat$band[tmp] <- 0
  }
  if (!is.null(dat$behavior)) {
    tmp <- dat$behavior != "" & dat$type %in% c("BEGSEG", "ENDSEG", "BEGCNT", "ENDCNT", "COCH")
    dat$dataChange[tmp] <- paste(dat$dataChange[tmp], "; changed BEHAVIOR from ", 
                                 dat$behavior[tmp], sep = "")
    dat$behavior[tmp] <- ""
  }
  # ---------------#
  
  # ---------------#
  # REMOVE UNNECESSARY SPACES AND ";" IN dataChange AND dataError COLUMNS
  # ---------------#
  tempFunc <- function(x) {
    x <- gsub("^\\s+|\\s+$", "", x)  # remove leading and trailing spaces
    x <- gsub("^ *|(?<= ) | *$", "", x, perl = TRUE)  # remove multple spaces
    x <- gsub("\\s+;", ";", x)  # remove spaces before semicolons
    x <- gsub("^;|;$", "", x)  # remove leading and trailing semicolons
    x <- gsub("^\\s+|\\s+$", "", x)  # remove leading and trailing spaces
    x
  }
  dat$dataChange <- tempFunc(dat$dataChange)
  dat$dataError <- tempFunc(dat$dataError)
  
  tmp <- dat$dataError != ""
  if (sum(tmp) > 0) {
    error <- dat[tmp, ]
    write.csv(error, file.path(dir.out, "ObsFileErrors.csv"), row.names = FALSE)
    out.err <- 1
  } else {
    if (file.exists(file.path(dir.out, "ObsFileErrors.csv"))) {
      unlink(file.path(dir.out, "ObsFileErrors.csv"))
    }
    
    message("\nNO MORE ERRORS IN OBSERVATION FILES!")
    # ---------------#
    
    # ---------------#
    # CODE CERTAIN COLUMNS AS NUMERIC #
    # ---------------#
    cols <- c("year", "month", "day", "transect", "condition", "offline", "count")
    dat[, cols] <- apply(dat[, cols], 2, function(x) as.numeric(x))
    # ---------------#
    
    out.err <- 0
  }
  
  if (error.flag) return(list(errorStatus = out.err, data = dat)) else return(dat)
  
}
