# ------------------------------------------------------------------------- #
# This program fixes COCH errors
#
# modified then rewritten from J. Lierness' old conditionCodeErrorChecks function
# Feb. 2017, K. Coleman
# ------------------------------------------------------------------------- #

conditionCodeErrorChecks = function(data) {
  
  test.data = data %>% mutate(condition = replace(condition, condition==0, NA)) %>% 
    filter(offline == 0, band<3)
  
  # add COCH
  more.than.one.condition = test.data %>% group_by(key) %>% 
    summarise(n = length(unique(condition[!is.na(condition)]))) %>% filter(n>1)
  to.add = test.data %>% filter(key %in% more.than.one.condition$key & !is.na(type)) %>% 
    mutate(diff1 = c(0,abs(condition[1:length(condition)-1]-condition[2:length(condition)])),
           diff2 = c(abs(condition[1:length(condition)-1]-condition[2:length(condition)]),0)) %>% 
    filter(diff1==1 | diff2==1) %>% group_by(key) %>% mutate(coch.seq=seq(1:n())) %>% 
    ungroup %>% filter(!type %in% "COCH") %>% 
    mutate(type = "COCH", count=NA, dataChange = "added COCH", 
           ID = ifelse(coch.seq %% 2 == 0, ID-0.01, ID+0.01))
  if(dim(to.add)[1]>1) {
    data = bind_rows(data, to.add) %>% arrange(ID)
    cat("Added ",dim(to.add)[1]," COCH records where condition changed between points")
    }
  
  # remove false COCH (COCH with no difference in condition)
  to.remove = test.data %>% filter(key %in% more.than.one.condition$key & !is.na(type)) %>% 
    mutate(diff1 = c(0,abs(condition[1:length(condition)-1]-condition[2:length(condition)])),
           diff2 = c(abs(condition[1:length(condition)-1]-condition[2:length(condition)]),0)) %>% 
    filter(type == "COCH" & diff1!=1 & diff2!=1)
  if(dim(to.remove)[1]>1) {
    data = data[!data$ID %in% to.remove$ID,]
    cat("Removed ",dim(to.remove)[1]," COCH records where condition did not change between points")
  } 
  
  # check that coch is not >5
  if(max(data$condition, na.rm=TRUE)>5) {print("CONDITION code error, condition greater than 5")}

  # return data with added COCH records and/or removed COCH errors
  data = select(data, -diff1, -diff2, -coch.seq)
  return(data)
}
