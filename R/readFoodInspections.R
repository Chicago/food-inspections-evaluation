# TITLE: foodInspectionsEvaluation.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-17

options(warn=1)

source("utilities.R")

readFoodInspections <- function(file) {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	names(result)[names(result)=="Inspection.ID"] <- "ID" # rename column
	names(result)[names(result)=="License.."] <- "License" # rename column
	names(result)[names(result)=="Facility.Type"] <- "FacilityType" # rename column
	names(result)[names(result)=="DBA.Name"] <- "DBA" # rename column
	names(result)[names(result)=="AKA.Name"] <- "AKA" # rename column
	names(result)[names(result)=="Inspection.Date"] <- "Date" # rename column
	names(result)[names(result)=="Inspection.Type"] <- "Type" # rename column

	result$Date <- as.POSIXct(result$Date, format="%m/%d/%Y")
	result
}

cleanFoodInspections <- function(df, validZips, missingRiskFile="../out/MissingRisk.csv") {
	result <- df
	
	# License
	licenseNa <- is.na(result$License)
	logMsg(paste("Removing facilities with missing license number:", sum(licenseNa)))
	print(result[licenseNa , c("License", "DBA", "Address", "City", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result <- result[!licenseNa , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	licenseZero <- (result$License == 0)
	logMsg(paste("Removing facilities with license number zero:", sum(licenseZero)))
	print(result[licenseZero , c("License", "DBA", "Address", "City", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result <- result[!licenseZero , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	# City
	logMsg("Upper casing city name")
	result$City <- toupper(result$City)
	# Acceptable values for Chicago
	chicagoSpellingError <-	result$City %in% c(
			"CHICAGOCHICAGO",
			"CHICAGOH",
			"CHICAGOI",
			"CCHICAGO",
			"CHCICAGO",
			"CHCHICAGO"
	)
	logMsg(paste("Fixing spelling errors in city name:", sum(chicagoSpellingError)))
	print(result[chicagoSpellingError , c("License", "DBA", "Address", "City", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result$City[chicagoSpellingError] <- "CHICAGO"
	
	cityNa <- is.na(result$City)
	logMsg(paste("Imputing missing city to CHICAGO:", sum(cityNa)))
	print(result[cityNa , c("License", "DBA", "Address", "City", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result$City[cityNa] <- "CHICAGO"
	
	notChicago <- (result$City != "CHICAGO")
	logMsg(paste("Removing facilities outside Chicago:", sum(notChicago)))
	print(result[notChicago , c("License", "DBA", "Address", "City", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result <- result[!notChicago , ] # subset by city
	result$City <- NULL # done with city
	logMsg(paste('Rows:', nrow(result)))
	
	# State
	stateNa <- is.na(result$State)
	logMsg(paste("Imputing missing state to IL:", sum(stateNa)))
	print(result[stateNa , c("License", "DBA", "Address", "State", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result$State[stateNa] <- "IL"
	
	notIllinois <- (result$State != "IL")
	logMsg(paste("Facilities outside Illinois:", sum(notIllinois)))
	result$State <- NULL # done with state
	
	# Zip
	zipNa <- is.na(result$Zip)
	logMsg(paste("Facilities missing zip:", sum(zipNa)))
	print(result[zipNa , c("License", "DBA", "Address", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	
	zipNonChicago <- !is.na(result$Zip) & !(result$Zip %in% validZips)
	logMsg(paste("Setting zip codes of facilities with zip outside Chicago to NA:", sum(zipNonChicago)))
	print(result[zipNonChicago , c("License", "DBA", "Address", "Zip", "FacilityType", "Risk", "Type", "Date", "Results")], row.names=FALSE)
	result$Zip[zipNonChicago] <- NA
		
	result <- factorizeColumns(result, c("FacilityType", "Type", "Risk", "Results"))
	
	logMsg(paste('Rows:', nrow(result)))
	logMsg(paste('Unique license numbers:', length(unique(result$License))))
	
	result
}	