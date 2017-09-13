# ------------------------------------------------------------------------- #
# AddBegEnd_GISeditObsTrack.R
# Date Created: 2011-11-04
# Author: JBL
#
# Description: This program adds necessary 'BEGSEG', 'ENDSEG', 'BEGCNT', 
# 'ENDCNT' rows to the combined observation/track files after they are 
# edited in GIS. The output is an R data frame.
# ------------------------------------------------------------------------- #

addBegEnd_GISeditObsTrack = function(data) {
  require(dplyr)
  data = data %>% as.data.frame() %>% 
    mutate(key = paste(crew, seat, year, month, day, substr(transLat,1,4), transLong, sep = "-"),
           type = gsub(" ", "", type))
  
  allkeys = unique(data$key)
  data = data[order(data$ID), ]
  
  for (i in seq(along = allkeys)) {
    tmp = data$key %in% allkeys[i]
    data.i = data[tmp, ]
    
    #---#
    # check beginning and end of transect
    #---#
    # ADD BEGCNT AT START
    if (!data.i$type[1] %in% "BEGCNT") {
      if (nrow(data.i) == 1 & data.i$type[1] %in% "ENDCNT") {
        add = data.i
        add$lat = NA
        add$long = NA
        add$sec = NA
        add$type = "BEGCNT"
        add$ID = add$ID - .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      } else {
        add = data.i[1, ]
        add$type = "BEGCNT"
        add$ID = add$ID - .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key %in% allkeys[i]
        data.i = data[tmp, ]
      }
    }
    data[tmp, ] = data.i
    
    # ADD ENDCNT AT END
    if (!data.i$type[nrow(data.i)] %in% "ENDCNT") {
      if (nrow(data.i) == 1 & data.i$type[1] %in% "BEGCNT") {
        add = data.i
        add$lat = NA
        add$long = NA
        add$sec = NA
        add$type = "ENDCNT"
        add$ID = add$ID + .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key %in% allkeys[i]
        data.i = data[tmp, ]
      } else {
        add = data.i[nrow(data.i), ]
        add$type = "ENDCNT"
        add$ID = add$ID + .01
        add$dataChange = paste(add$dataChange, "; added row based on GIS track file edits", 
                                sep = "")
        data = rbind(data, add)
        data = data[order(data$ID), ]
        tmp = data$key == allkeys[i]
        data.i = data[tmp, ]
      }
    }
    data[tmp, ] = data.i
    #---#
    
    #---#
    # check for breaks within the transect by looking at ID
    # these would be instances like when there wasn't a start/stop for an island
    # and now one has to be created
    #---#
    for (j in 2:nrow(data.i)) {
      if (data.i$ID[j] - data.i$ID[j-1] > 1) {
        # ADD ENDCNT
        if (!data.i$type[j-1] %in% "ENDCNT") {
          add = data.i[j-1, ]
          add$type = "ENDCNT"
          add$ID = add$ID + .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
        # ADD BEGCNT
        if (!data.i$type[j] %in% "BEGCNT") {
          add = data.i[j, ]
          add$type = "BEGCNT"
          add$ID = add$ID - .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
      }
    }
    data = data[order(data$ID), ]
    tmp = data$key %in% allkeys[i]
    data.i = data[tmp, ]
    #---#
    
    #---#
    # check that there is an end count before every begin count
    # in the middle of the transect
    #---#
    if (nrow(data.i) > 2) {
      for (j in 2:(nrow(data.i)-1)) {
        if (data.i$type[j] %in% "BEGCNT" & !data.i$type[j-1] %in% "ENDCNT") {
          add = data.i[j-1, ]
          add$type = "ENDCNT"
          add$ID = add$ID + .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
        if (data.i$type[j] %in% "ENDCNT" & !data.i$type[j+1] %in% "BEGCNT") {
          add = data.i[j+1, ]
          add$type = "BEGCNT"
          add$ID = add$ID - .01
          add$dataChange = paste(add$dataChange, 
                                  "; added row based on GIS track file edits", sep = "")
          data = rbind(data, add)
        }
      }
    }
    #---#
  }
  data = data[order(data$ID), ]
  #---#
  
  #---#
  # DELETE UNNESSARY BEG/END POINTS
  allkeys = unique(data$key)
  for (i in seq(along = allkeys)) {
    tmp = data$key %in% allkeys[i]
    data.i = data[tmp, ]
    
    b = subset(data.i, type %in% "BEGCNT", select = c("lat", "long", "sec"))
    e = subset(data.i, type %in% "ENDCNT", select = c("lat", "long", "sec"))
    b = merge(b, e)
    b = b[!duplicated(b), ]
    b = b[order(b$sec), ]
    
    if (nrow(b) > 0) {
      for (j in seq(along = b$sec)) {
        b.j = b[j, ]
        b.j$delete = 1
        data.i = merge(data.i, b.j, all = TRUE)
        data.i = data.i[order(data.i$ID), ]
        tmp.del = !is.na(data.i$delete) & data.i$type %in% c("BEGCNT", "ENDCNT")
        if (sum(is.na(data.i$delete)) == 0) {
          data.i = NULL
          next
        }
        if (data.i$type[tmp.del][1] %in% "BEGCNT" & data.i$type[tmp.del][sum(tmp.del)] %in% "ENDCNT") {
          data.i = subset(data.i, is.na(delete))
        } else if (data.i$type[tmp.del][1] %in% "BEGCNT" & data.i$type[tmp.del][sum(tmp.del)] %in% "BEGCNT") {
          data.i = data.i[-which(tmp.del)[-1], ]
        } else if (data.i$type[tmp.del][1] %in% "ENDCNT" & data.i$type[tmp.del][sum(tmp.del)] %in% "BEGCNT") {
          data.i = data.i[-which(tmp.del), ]
        } else if (data.i$type[tmp.del][1] %in% "ENDCNT" & data.i$type[tmp.del][sum(tmp.del)] %in% "ENDCNT") {
          data.i = data.i[-which(tmp.del)[-sum(tmp.del)], ]
        }
        data.i$delete = NULL
      }
    }
    if (nrow(b) > 0) data = rbind(data.i, data[!tmp, ])
  }
  data = data[order(data$ID), ]
  
  # CHANGE BEGSEG/ENDSEG TO BEGCNT/ENDCNT WHEN NECESSARY (AND VICE VERSA)
  data = data %>% group_by(key) %>% 
    dplyr::mutate(type = replace(type, row_number()==1 & type=="BEGCNT","BEGSEG"),
                  type = replace(type, row_number()==n() & type=="ENDCNT","ENDSEG"),
                  type = replace(type, row_number()!=1 & type=="BEGSEG","BEGCNT"),
                  type = replace(type, row_number()!=n() & type=="ENDSEG","ENDCNT")) %>%
    arrange(ID)
  
  # ADD GPS & SEC VALUES FOR ADDED ROWS WHERE MISSING #
  tmp = is.na(data$lat) & grepl("; added row based on GIS track file edits", data$dataChange)
  if (sum(tmp) > 0) {
    for (i in 1:sum(tmp)) {
      temp = data[data$transect %in% data$transect[tmp][i] & 
                    data$replicate %in% data$replicate[tmp][i] & 
                    data$day %in% data$day[tmp][i] & 
                    data$month %in% data$month[tmp][i] & 
                    data$type %in% data$type[tmp][i] & 
                    !data$seat %in% data$seat[tmp][i], ]
      data$lat[tmp][i] = temp$lat
      data$long[tmp][i] = temp$long
      data$sec[tmp][i] = temp$sec
    }
  }
  data[order(data$ID), ]
  
}

