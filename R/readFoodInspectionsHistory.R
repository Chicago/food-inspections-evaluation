# TITLE: foodInspectionsEvaluation.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-17

options(warn=1)

source("utilities.R")

readFoodInspectionsHistory <- function(file) {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	names(result)[names(result)=="License.."] <- "License" # rename column
	result$Inspection.Date <- as.POSIXct(result$Inspection.Date, format="%m/%d/%Y")
	result <- factorizeColumns(result, c("Facility.Type", "Inspection.Type", "City", "State", "Risk", "Results"))
	result
}
