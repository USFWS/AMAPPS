# ---------------- #
# post GIS edits 
# ---------------- #

# wrong transect but distance error was not thrown 
shapefileDataframe$transect[shapefileDataframe$ID %in% c(98655:98657)] = 403100

#right on the edge of land/ could be either since no start/stops
shapefileDataframe$offline[shapefileDataframe$index == 126298] = 0 

# wrong transect not fixed in check 
shapefileDataframe$transect[shapefileDataframe$ID %in% c(3212:3343, 33065,33066)] = 350100
shapefileDataframe$type[shapefileDataframe$ID %in% 3212] = "BEGSEG"

shapefileDataframe$transect[shapefileDataframe$ID %in% c(30160:30162)] = 352100
