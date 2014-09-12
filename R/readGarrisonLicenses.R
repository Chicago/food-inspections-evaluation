# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-07

options(warn=1)

library(stringr)

source("utilities.R")

readGarrisonLicenses <- function(file) {
	
	# Garrison export has un-escaped double-quotes within double-quotes and commas within double-quotes, so...
	result <- readLines(file)
	result <- result[-length(result)] # remove last (blank) line
	result <- str_trim(result) # remove leading and trailing white space from lines
	result <- substr(result, 2, nchar(result) - 1) # remove leading and trailing quote
	result <- strsplit(result, "\",\"", fixed = TRUE) # split on quote-comma-quote
	result <- lapply(result, str_trim) # remove leading and trailing white space from values
	result <- matrix(unlist(result), ncol=12, byrow=TRUE)
	
	names <- result[1 , ]
	result <- data.frame(result[-1 , ], row.names=NULL, stringsAsFactors=FALSE)	
	names(result) <- names	
	names(result)[names(result)=="License Number"] <- "License"
	names(result)[names(result)=="DBA Name"] <- "DBA"
	names(result)[names(result)=="AKA Name"] <- "AKA"
	names(result)[names(result)=="Facility Address"] <- "Address"
	names(result)[names(result)=="Facility City"] <- "City"
	names(result)[names(result)=="Facility State"] <- "State"
	names(result)[names(result)=="Facility Zip"] <- "Zip"
	names(result)[names(result)=="Risk Category"] <- "Risk"
#	names(result)[names(result)=="Status"] <- "Status"
	names(result)[names(result)=="License Code"] <- "Code"
	names(result)[names(result)=="Assigned Sanitarian"] <- "Sanitarian"
	names(result)[names(result)=="Last Inspection Date"] <- "LastInspectionDate"
	
	result <- naColumns(result) # blanks to na
	result <- posixifyColumns(result, "LastInspectionDate")
	
	result
}

cleanGarrisonLicenses <- function(df, validZips, missingRiskFile="../out/MissingRisk.csv") {
	result <- df
	logMsg(paste('Rows:', nrow(result)))
	
	# License
	licenseNa <- is.na(result$License)
	logMsg(paste("Removing facilities with missing license number:", sum(licenseNa)))
	print(result[licenseNa , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	result <- result[!licenseNa , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	licenseZero <- (result$License == 0)
	logMsg(paste("Removing facilities with license number zero:", sum(licenseZero)))
	print(result[licenseZero , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk", "LastInspectionDate")], row.names=FALSE)
	result <- result[!licenseZero , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	licenseZeroDashZero <- (result$License == "0-0")
	logMsg(paste("Removing facilities with license number zero dash zero:", sum(licenseZeroDashZero)))
	print(result[licenseZeroDashZero , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	result <- result[!licenseZeroDashZero , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	# Address
	addressNa <- is.na(result$Address)
	logMsg(paste("Removing facilities with missing address:", sum(addressNa)))
	print(result[addressNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	result <- result[!addressNa , ] # subset by license
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
	print(result[chicagoSpellingError , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk")], row.names=FALSE)
	result$City[chicagoSpellingError] <- "CHICAGO"

	cityNa <- is.na(result$City)
	logMsg(paste("Imputing missing city to CHICAGO:", sum(cityNa)))
	print(result[cityNa , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk")], row.names=FALSE)
	result$City[cityNa] <- "CHICAGO"
	
	notChicago <- (result$City != "CHICAGO")
	logMsg(paste("Removing facilities outside Chicago:", sum(notChicago)))
	print(result[notChicago , c("License", "DBA", "Address", "City", "State", "Zip", "Status", "Risk", "LastInspectionDate")], row.names=FALSE)
	result <- result[!notChicago , ] # subset by city
	result$City <- NULL # done with city
	logMsg(paste('Rows:', nrow(result)))
	
	# State
	stateNa <- is.na(result$State)
	logMsg(paste("Imputing missing state to IL:", sum(stateNa)))
	print(result[stateNa , c("License", "DBA", "Address", "State", "Zip", "Status", "Risk", "LastInspectionDate")], row.names=FALSE)
	result$State[stateNa] <- "IL"
	
	notIllinois <- (result$State != "IL")
	logMsg(paste("Facilities outside Illinois:", sum(notIllinois)))
	result$State <- NULL # done with state
	
	# Zip
	result$Zip[result$Zip == "60618 6136"] <- "60618" # trim one zip+4

	zipNa <- is.na(result$Zip)
	logMsg(paste("Facilities missing zip:", sum(zipNa)))
	print(result[zipNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code")], row.names=FALSE)
	
	zipNonChicago <- !is.na(result$Zip) & !(result$Zip %in% validZips)
	logMsg(paste("Setting zip codes of facilities with zip outside Chicago to NA:", sum(zipNonChicago)))
	print(result[zipNonChicago , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code")], row.names=FALSE)
	result$Zip[zipNonChicago] <- NA
	
	# Risk
	riskNa <- is.na(result$Risk)
	logMsg(paste("Facilities missing risk:", sum(riskNa)))
#	print(result[riskNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code")], row.names=FALSE)
	write.table(result[riskNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code")], file=missingRiskFile, sep=',', row.names=FALSE)
	
	riskAll <- (!riskNa & result$Risk == "All")
	logMsg(paste('Setting risk of facilities with a risk of "All" (unclassified) to NA:', sum(riskAll)))
	print(result[riskAll , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code")], row.names=FALSE)
	result$Risk[riskAll] <- NA
	result$Risk <- as.integer(factor(result$Risk))
	
	ambiguousRiskLicenses <- ambiguousRiskActiveLicenses(result)
	logMsg(paste('Active licenses with an ambiguous risk:', length(ambiguousRiskLicenses)))
	ambiguousRiskLicenses <- result[result$License %in% ambiguousRiskLicenses , ]
	print(ambiguousRiskLicenses[order(ambiguousRiskLicenses$License, ambiguousRiskLicenses$LastInspectionDate), c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	
	# Status
	statusNa <- is.na(result$Status)
	logMsg(paste('Facilities missing status:', sum(statusNa)))
	print(result[statusNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	
	# License Code
	codeNa <- is.na(result$Code)
	logMsg(paste('Facilities missing license code:', sum(codeNa)))
	print(result[codeNa , c("License", "DBA", "Address", "Zip", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	
	logMsg('Sorting by license number and date of last inspection (ascending)')
	result <- result[order(result$License, result$LastInspectionDate) , ]
	dups <- duplicated(result$License, fromLast=TRUE)
	logMsg(paste('Removing all but most recent of duplicate license numbers:', length(dups)))
	print(result[dups , c("License", "DBA", "Address", "Status", "Risk", "Code", "LastInspectionDate")], row.names=FALSE)
	result <- result[!dups , ]
	
	result <- factorizeColumns(result, c("Status", "Sanitarian"))
	
	logMsg(paste('Rows:', nrow(result)))
	logMsg(paste('Unique license numbers:', length(unique(result$License))))
	
	result
}

#' @return a list of active license numbers of facilities with more than one risk category
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
ambiguousRiskActiveLicenses <- function(df) {
	df <- df[df$Status=="Active" , ]
	tbl <- table(df$License, df$Risk)
	df1 <- data.frame(risk1=tbl[ , 1], risk2=tbl[ , 2], risk3=tbl[ , 3], row.names=rownames(tbl))
	# integer counts to logical
	df1$risk1 <- (df1$risk1 > 0)
	df1$risk2 <- (df1$risk2 > 0)
	df1$risk3 <- (df1$risk3 > 0)
	rownames(df1[(df1$risk1 + df1$risk2 + df1$risk3) > 1 , ])
}

specialCaseEliminations <- function(df) {
	result <- df
	logMsg(paste('Rows:', nrow(result)))
	
	licenseUnitedCenter <- (result$Address %in% c(
		"1901 W MADISON  ST",
		"1901 W MADISON"
	))
	logMsg(paste("Removing United Center:", sum(licenseUnitedCenter)))
	print(result[licenseUnitedCenter , c("License", "DBA", "Address", "Zip", "Status", "Code")], row.names=FALSE)
	result <- result[!licenseUnitedCenter , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	licenseWrigleyField <- (result$Address %in% c(
		"1060 W ADDISON  ST"
	))
	logMsg(paste("Removing Wrigley Filed:", sum(licenseWrigleyField)))
	print(result[licenseWrigleyField , c("License", "DBA", "Address", "Zip", "Status", "Code")], row.names=FALSE)
	result <- result[!licenseWrigleyField , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	licenseCellularField <- (result$Address %in% c(
		"333 W 35TH  ST"
	))
	logMsg(paste("Removing Cellular Field:", sum(licenseCellularField)))
	print(result[licenseCellularField , c("License", "DBA", "Address", "Zip", "Status", "Code")], row.names=FALSE)
	result <- result[!licenseCellularField , ] # subset by license
	logMsg(paste('Rows:', nrow(result)))
	
	result
}