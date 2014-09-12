# TITLE: foodInspectionZipCodes.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-07

options(warn=1)
options(error=utils::recover)
options(max.print=15000)
options(width=200)

source("utilities.R")

posixifyColumns <- function(df, columnNames) {
	result <- df
	for(columnName in columnNames) {
		result[[columnName]] <- as.POSIXct(result[[columnName]], format="%m/%d/%Y")
	}
	result
}

readInspectionHistory <- function(file="../data/Food_Inspections.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	names(result)[names(result)=="License.."] <- "License" # "License #" on the portal, rename merge column
	result$Inspection.Date <- as.POSIXct(result$Inspection.Date, format="%m/%d/%Y")
	result
}

readLicenses <- function(file="../data/Business_Licenses.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	result <- posixifyColumns(result, 
			c(	"APPLICATION.CREATED.DATE", 
				"APPLICATION.REQUIREMENTS.COMPLETE",
				"PAYMENT.DATE",
				"LICENSE.TERM.START.DATE",
				"LICENSE.TERM.EXPIRATION.DATE",
				"LICENSE.APPROVED.FOR.ISSUANCE",
				"DATE.ISSUED",
				"LICENSE.STATUS.CHANGE.DATE"
	))
	result
}

# Matching inspections data
compareZips <- function(inspections, licenses, startDate="2014-01-01", 
		licensesNotFoundPath='../out/licensesNotFound.csv',
		zipCodeDiscrepencyPath='../out/foodInspectionZipCodeDiscrepencies.csv') {
	
	#subset food inspections by start date
	inspections <- subset(inspections, Inspection.Date >= as.POSIXct(startDate, format="%Y-%m-%d"))
	inspections <- inspections[complete.cases(inspections[ , c("License")]) , ]
	logMsg(paste('Food inspections after', startDate, ':', nrow(inspections)))
	summarize(inspections)
	
	inspectionLicenseNumbers <- unique(inspections$License)
	logMsg(paste('Unique license numbers in food inspections =', length(inspectionLicenseNumbers)))
	logMsg(paste('Unique zip codes in food inspections =', length(unique(inspections$Zip))))
	logMsg('Food inspections by zip code:')
	print(sort(table(inspections$Zip), decreasing=TRUE))
	
	# subset to currently active business licenses
	licenses <- licenses[complete.cases(licenses[ , c("ACCOUNT.NUMBER", "LICENSE.NUMBER", "LICENSE.CODE", "LICENSE.TERM.START.DATE", "LICENSE.TERM.EXPIRATION.DATE")]) , ]
	licenses <- licenses[licenses$LICENSE.STATUS == "AAI" , ]
	licenses <- licenses[licenses$LICENSE.TERM.START.DATE <= Sys.time() & Sys.time() <= licenses$LICENSE.TERM.EXPIRATION.DATE , ]
	# Keep only the most recent of duplicates
	licenses <- licenses[with(licenses, order(ACCOUNT.NUMBER, LICENSE.NUMBER, LICENSE.CODE, LICENSE.TERM.START.DATE)) , ] # sort
	licenses <- licenses[!duplicated(licenses$LICENSE.NUMBER, fromLast=TRUE) , ]
	summarize(licenses)
	
	licenseNumbers <- unique(licenses$LICENSE.NUMBER)
	logMsg(paste('Unique license numbers in business licenses =', length(licenseNumbers)))
	logMsg(paste('Unique zip codes in business licenses =', length(unique(licenses$ZIP.CODE))))
	logMsg('Licenses by zip code:')
	byZipCode <- table(licenses$ZIP.CODE)
	print(sort(byZipCode, decreasing=TRUE))
	
	duplicates <- duplicated(licenses$LICENSE.NUMBER, fromLast=FALSE) | duplicated(licenses$LICENSE.NUMBER, fromLast=TRUE)
	logMsg(paste('Duplicate active license numbers in business licenses:', sum(duplicates)))
	
	logMsg(paste('Unique license numbers in business licenses =', length(unique(licenses$LICENSE.NUMBER))))
	
	# inspections not found in business licenses
	inspectionsNotFound <- inspections[!(inspections$License %in% licenseNumbers) , c("License" , "DBA.Name", "Address", "Inspection.Date", "Results")]
	inspectionsNotFound <- inspectionsNotFound[with(inspectionsNotFound, order(License, Inspection.Date)) , ] # sort
	inspectionsNotFound <- inspectionsNotFound[!duplicated(inspectionsNotFound$License, fromLast=TRUE) , ] # keep only most recent
	inspectionsNotFound <- inspectionsNotFound[inspectionsNotFound$Result != "Business Not Located", ]
	inspectionsNotFound <- inspectionsNotFound[inspectionsNotFound$Result != "Out of Business", ]
	logMsg(paste('License numbers in inspections not found in business licenses =', nrow(inspectionsNotFound)))
	write.table(inspectionsNotFound, file=licensesNotFoundPath, sep=',', row.names=FALSE)
	
	# zip code discrepencies between the inspections and the business licenses
	inspections <- inspections[complete.cases(inspections[ , c("Zip")]) , ]
	logMsg(paste('Inspections with zip codes =', nrow(inspections)))
	licenses <- licenses[complete.cases(licenses[ , c("ZIP.CODE")]) , ]
	logMsg(paste('Business licenses with zip codes =', nrow(licenses)))
	inspections <- merge(inspections, licenses, by.x="License", by.y="LICENSE.NUMBER")
	logMsg(paste('Inspections matching business license on license number =', nrow(inspections)))
	inspections <- inspections[(inspections$Zip != inspections$ZIP.CODE) , ]
	logMsg(paste('Inspections with zip codes different from business license =', nrow(inspections)))
	inspections <- inspections[ , c("License", "Inspection.Date", "Results", "DBA.Name", "Address", "Zip", "ZIP.CODE")]
	names(inspections)[names(inspections)=="Zip"] <- "Food Inspection Zip"
	names(inspections)[names(inspections)=="ZIP.CODE"] <- "Business License Zip"
	inspections <- inspections[with(inspections, order(License, Inspection.Date)) , ] # sort
	write.table(inspections, file=zipCodeDiscrepencyPath, sep=',', row.names=FALSE)
	
	logMsg('Done.')
} 

run <- function() {
	logMsg('Reading food inspections')
	fi <- readInspectionHistory()
	logMsg(paste('Food inspections:', nrow(fi)))
	logMsg('Reading licenses')
	li <- readLicenses()
	logMsg(paste('Licenses:', nrow(li)))
	compareZips(fi, li)
}