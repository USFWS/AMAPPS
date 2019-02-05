# ----------------------- #
# fix Mixed ("MIXD" codes using the comments
# in order for this to work the observers have to follow protocol
# if the format is not the same as instructed 
# (number using a % listed before the code and separated by a ';')
# there will be errors 
# ----------------------- #

fixMixed <- function(data) {
  if (any(data$type %in% "MIXD")) {
    mixes = filter(data, type %in% "MIXD") # copy the information from the row with the Mixed observation
    output = mixes[0,]
    
    for (ind in 1:dim(mixes)[1]) {
      add = mixes[ind,]
      b = strsplit(add$comment,c(";","; "))
      out = add[0,]
      
      for (ind2 in 1:length(unlist(b))){
        d = strsplit(paste(b[[1]][ind2], sep=""),c("%","% "))
        adds = add
        adds$type = sub("^\\s+", "", d[[1]][2])  # trim space before
        adds$count = sub("^\\s+", "", gsub("[[:alpha:]]", "", d[[1]][1]))  # trim space before and letters
        adds$dataChange = paste(add$dataChange, "; multiple species: added row based on OBS.COMMENT")
        out = rbind(out,adds)
      }
      output = rbind(output, out)
    }
    if(any(is.na(output$count) | is.na(output$type))){
      output = filter(output,!is.na(count), !is.na(type))
      message("There were some MIXD codes that were not formated properly and will have to be done manually")
    }
  }
    
    data = filter(data, !data$type %in% "MIXD") # delete the row with 'MIXD' which is why we redine 'a' each time
    data = rbind(data, output)
    message("MIXED row separated and the original row was deleted")
    return(data)
  }

