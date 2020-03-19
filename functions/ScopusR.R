my_wd <- "/Users/filippochiarello/Desktop/ScopusAitem"

setwd(my_wd)

# Rscopus #

library("httr","XML")

source("scopusAPI.R")



myQuery <- "TITLE-ABS-KEY(\"marketing\" AND \"iot\")"

theXML <- searchByString(string = myQuery, outfile = "testdata.xml") 

theData <- extractXML(theXML)

nrow(theData)

