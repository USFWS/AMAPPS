library(lubridate)
#Change mix of date formate mm/dd/yyyy and yyyy-mm-dd into yyyy-mm-dd
#.data vector which can be coerced to character
DomVirFix = function(.data){
  .data <- as.character(.data)
  mdy <- mdy(.data)
  mdy[is.na(mdy)] <- .data[is.na(mdy)] # some dates are ambiguous, here we give
  good_dates <- as.Date(as.character(mdy))
  return(good_dates)
}
