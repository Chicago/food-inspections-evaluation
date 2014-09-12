# TITLE: readGarrison.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-17

readGarrison <- function(file="../data/InspectionsGarrisonExport20112014.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	result$License.Type <- NULL # always Food
	names(result)[names(result)=="License.Number"] <- "License"
	names(result)[names(result)=="Inspector.Assigned"] <- "Sanitarian"
	names(result)[names(result)=="Inspection.Date"] <- "Date"
	names(result)[names(result)=="Inspection.Purpose"] <- "Purpose"
	result$Date <- as.POSIXct(result$Date, format="%m/%d/%Y")
	result
}

cleanGarrison <- function(df) {
	result <- df
	
	licenseMissing <- is.na(result$License)
	logMsg(paste("Removing inspections with license number missing:", sum(licenseMissing)))
	result <- result[!licenseMissing , ]
	
	licenseZero <- (result$License == 0)
	logMsg(paste("Removing inspections with license number zero:", sum(licenseZero)))
	result <- result[!licenseZero , ]
	
	licenseZeroDashZero <- (result$License == "0-0")
	logMsg(paste("Removing inspections with license number 0-0:", sum(licenseZeroDashZero)))
	result <- result[!licenseZeroDashZero , ]
	
	sanitarianBlank <- (result$Sanitarian == " ")
	logMsg(paste("Removing inspections with blank inspector:", sum(sanitarianBlank)))
	result <- result[!sanitarianBlank , ]
	
	addressMissing <- is.na(result$Address)
	logMsg(paste("Removing inspections with address missing:", sum(addressMissing)))
	result <- result[!addressMissing , ]
	
	result$Zip <- sapply(strsplit(result$Address, split=" ", fixed=TRUE), tail, n=1)
	result$Zip <- sapply(strsplit(result$Zip, split="-", fixed=TRUE), head, n=1) # for zip+4
	zipMissing <- (result$Zip == 'IL')
	logMsg(paste("Removing inspections with zip missing:", sum(zipMissing)))
	result <- result[!zipMissing , ]
	result$Zip <- as.integer(result$Zip)
	
	invalidZip <- (result$Zip == 60627)
	logMsg(paste('Removing inspections with invalid zip 60627:', sum(invalidZip, na.rm=TRUE)))
	result <- result[!invalidZip , ]
	
	incompleteCases <- !complete.cases(result)
	logMsg(paste("Removing inspections with incomplete cases:", sum(incompleteCases)))
	result <- result[!incompleteCases , ]
	
	result <- factorizeColumns(result, c("Sanitarian", "Purpose"))
	result
}
