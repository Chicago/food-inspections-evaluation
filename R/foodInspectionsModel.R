# Food Inspections prediciton Model, Mark II
# 
# Author: 368982 Hugh 4/22/14
###############################################################################

options(warn=1)
options(error=utils::recover)
options(max.print=15000)
options(width=300)

source("utilities.R")
source("foodInspectionUtilities.R")
source("readChicagoZipCodes.R")
source("readGarrisonLicenses.R")
source("readFoodInspections.R")

run <- function() {
	
	logMsg('Reading Chicago ZIP codes')
	validZips <- readChicagoZipCodes("../data/ChicagoZipCodes.csv")
	logMsg(paste('Chicago ZIP codes:', nrow(validZips)))
	
	logMsg('Reading Garrison licenses')
	licenses <- readGarrisonLicenses("../data/GarrisonLicenses.csv")
	logMsg(paste('Garrison licenses records:', nrow(licenses)))
	
	logMsg('Cleaning Garrison licenses')
	licenses <- cleanGarrisonLicenses(licenses, validZips$Zip)
	logMsg(paste('Garrison licenses records:', nrow(licenses)))
	
	logMsg('Removing special cases from Garrison licenses')
	licenses <- specialCaseEliminations(licenses)
	logMsg(paste('Garrison licenses records:', nrow(licenses)))
	
	logMsg('Reading food inspection records')
	inspections <- readFoodInspections("../data/Food_Inspections.csv")
	logMsg(paste('Food inspection records:', nrow(inspections)))
	
	logMsg('Cleaning food inspection records')
	inspections <- cleanFoodInspections(inspections, validZips$Zip)
	logMsg(paste('Food inspection records:', nrow(inspections)))
	
	logMsg('Subset inspections by date')
	inspections <- inspections[as.POSIXct("2011-01-01") < inspections$Date & inspections$Date < as.POSIXct("2014-01-01") , ]
	logMsg(paste('Food inspection records:', nrow(inspections)))
	
	# Parse and categorize inspections by criticality level
	logMsg("Adding counts for critical, serious, and minor violations to inspections")
	inspections <- countViolations(inspections)	
	logMsg("Finished adding counts for critical, serious, and minor violations to inspections")
	
	# Decorate licenses with fail counts and violation counts from inspections
	logMsg("Adding counts for critical, serious, and minor violations to licenses")
	# remove uninformative inspections
	inspections <- inspections[!(inspections$Result %in% c("Business Not Located", "No Entry", "Out of Business")) , ]
	inspections$Fail <- (inspections$Results == "Fail")
#	failCount <- aggregate(Results ~ License, inspections, function(x) sum(x=="Fail"))
	failCount <- aggregate(Fail ~ License, inspections, sum)
	colnames(failCount)[colnames(failCount) == 'Fail'] <- 'failCount'
	licenses <- merge(licenses, failCount, all.x=TRUE)
	licenses <- merge(licenses, aggregate(criticalCount ~ License, inspections, sum), all.x=TRUE)
	licenses <- merge(licenses, aggregate(seriousCount ~ License, inspections, sum), all.x=TRUE)
	licenses <- merge(licenses, aggregate(minorCount ~ License, inspections, sum), all.x=TRUE)
	licenses$violationCount <- licenses$criticalCount + licenses$seriousCount + licenses$minorCount
	logMsg("Finished adding counts for critical, serious, and minor violations to licenses")
	print(cor(licenses[ , c("failCount", "criticalCount", "seriousCount", "minorCount", "violationCount")], use="pairwise.complete.obs"))
	plot(licenses$minorCount, licenses$violationCount)
	
	# Fit model
	ds <- inspections[, c("License", "Fail")]
	# Decorate inspections with licensee attributes
	ds <- merge(ds, licenses[ , c("License", "failCount", "criticalCount", "seriousCount", "minorCount", "violationCount")])
	summarize(ds)
	foodInspectionFailureModel <- glm(Fail ~ failCount + criticalCount + seriousCount + minorCount, ds, family=binomial)
	print(summary(foodInspectionFailureModel))
	print(summary(confint(foodInspectionFailureModel)))
	ds <<- ds # copy to global for interactive use
	plot(foodInspectionFailureModel)
	
	logMsg('Saving inspection data')
	write.table(inspections, file="../out/FoodInspections.csv", sep=',', row.names=FALSE)
	inspections <<- inspections # copy to global for interactive use
	
	logMsg('Saving license data')
	write.table(licenses, file="../out/GarrisonLicenses.csv", sep=',', row.names=FALSE)
	licenses <<- licenses # copy to global for interactive use
	
 }