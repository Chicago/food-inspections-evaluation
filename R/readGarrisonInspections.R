# TITLE: readGarrisonInspections.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-23

readGarrisonInspections <- function(file) {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	result$License.Type <- NULL # always Food
	names(result)[names(result)=="License.Number"] <- "License"
	names(result)[names(result)=="Inspector.Assigned"] <- "Sanitarian"
	names(result)[names(result)=="Inspection.Date"] <- "Date"
	names(result)[names(result)=="Inspection.Purpose"] <- "Purpose"
	result$Date <- as.POSIXct(result$Date, format="%m/%d/%Y")
	result
}

cleanGarrisonInspections <- function(df, validZips) {
	result <- df
	
	# License
	licenseMissing <- is.na(result$License)
	logMsg(paste("Removing inspections with license number missing:", sum(licenseMissing)))
	result <- result[!licenseMissing , ]
	
	licenseZero <- (result$License == 0)
	logMsg(paste("Removing inspections with license number zero:", sum(licenseZero)))
	result <- result[!licenseZero , ]
	
	licenseZeroDashZero <- (result$License == "0-0")
	logMsg(paste("Removing inspections with license number zero dash zero:", sum(licenseZeroDashZero)))
	result <- result[!licenseZeroDashZero , ]
	
	sanitarianBlank <- (result$Sanitarian == " ")
	logMsg(paste("Inspections with blank inspector:", sum(sanitarianBlank)))
	print(result[sanitarianBlank , ], row.names=FALSE)
#	result <- result[!sanitarianBlank , ]
	
	addressMissing <- is.na(result$Address)
	logMsg(paste("Inspections with address missing:", sum(addressMissing)))
	print(result[addressMissing , ], row.names=FALSE)
#	result <- result[!addressMissing , ]
	
	result$Zip <- sapply(strsplit(result$Address, split=" ", fixed=TRUE), tail, n=1)
	result$Zip <- sapply(strsplit(result$Zip, split="-", fixed=TRUE), head, n=1) # for zip+4
	result$Zip[result$Zip == 'IL'] <- NA	
	result$Zip <- as.integer(result$Zip)
	zipMissing <- is.na(result$Zip)
	logMsg(paste("Inspections with zip missing:", sum(zipMissing)))
	print(result[zipMissing , ], row.names=FALSE)
#	result <- result[!zipMissing , ]
	
	invalidZip <- !is.na(result$Zip) & !(result$Zip %in% validZips)
	logMsg(paste('Inspections with invalid zip:', sum(invalidZip, na.rm=TRUE)))
	print(result[invalidZip , ], row.names=FALSE)
#	result <- result[!invalidZip , ]
	
	incompleteCases <- !complete.cases(result)
	logMsg(paste("Inspections with incomplete cases:", sum(incompleteCases)))
	print(result[incompleteCases , ], row.names=FALSE)
#	result <- result[!incompleteCases , ]
	
	result <- factorizeColumns(result, c("Sanitarian", "Purpose"))
	
	logMsg(paste('Rows:', nrow(result)))
	logMsg(paste('Unique license numbers:', length(unique(result$License))))
	
	result
}
