# TITLE: foodInspectionsEvaluation.R
# AUTHOR: Tom Schenk Jr. and Hugh J. Devlin, Ph. D.
# CREATED: 2014-02-24
# MODIFIED: 2014-02-27, 2014-04-01
# NOTES: To execute, run 'Rscript foodInspectionsEvaluation.R' from terminal or command prompt.

options(warn=1)
options(error=utils::recover)
options(max.print=2000)
options(width=150)

library(stringr)

source("utilities.R")
source("foodInspectionUtilities.R")

readFoodInspections <- function(file="http://data.cityofchicago.org/api/views/4ijn-s7e5/rows.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	names(result)[names(result)=="License.."] <- "License" # rename column
	result$Inspection.Date <- as.POSIXct(result$Inspection.Date, format="%m/%d/%Y")
	result <- factorizeColumns(result, c("Facility.Type", "Inspection.Type", "City", "State", "Risk", "Results"))
	result
}

readPredictions <- function(file="../data/InspectionList.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE)
	names(result)[names(result)=="license_number"] <- "License" # rename merge column
	result <- factorizeColumns(result, c("risk", "type", "supervisor", "sanitarian"))
	result
}

zDifferenceOfProportions = function(x1, x2, n1, n2) {
	numerator = (x1/n1) - (x2/n2)
	p.common = (x1 + x2) / (n1 + n2)
	denominator = sqrt(p.common * (1 - p.common) * (1/n1 + 1/n2))
	return(numerator / denominator)
}

testPredictions <- function(critical, groups) {
	# Create tables of outcomes (2x3 non-critical/critical, both/control/test)
	critical.outcomes <- table(critical, groups)
	logMsg("Critical outcomes for treatment and control group:")
	print(critical.outcomes)
	logMsg("Critical outcomes for treatment and control group (percentages)")
	critical.outcomes.prop <- prop.table(critical.outcomes, 2)
	print(critical.outcomes.prop)
	
	nBoth <- sum(critical.outcomes[ , "both"])
	nControl <- nBoth + sum(critical.outcomes[ , "control"])
	nTest <- nBoth + sum(critical.outcomes[ , "test"])
	
	# The row name for critical violations is "TRUE"
	xBoth <- critical.outcomes["TRUE", "both"]
	xControl <- xBoth + critical.outcomes["TRUE", "control"]
	xTest <- xBoth + critical.outcomes["TRUE", "test"]
	
	pControl <- xControl / nControl
	pTest <- xTest / nTest
	
	logMsg(paste("Proportion criticals in test (test + both) group =", pTest))
	logMsg(paste("Proportion criticals in control (control + both) group =", pControl))
	logMsg(paste("difference in proportions =", (pTest - pControl)))
	result <- zDifferenceOfProportions(xTest, xControl, nTest, nControl)
	logMsg(paste("z score for test of proportions =", result))
	
	contingencyTable <- matrix(c((nControl-xControl), (nTest-xTest), xControl, xTest), nrow=2, byrow=TRUE, 
			dimnames=list(c("Non-critical", "Critical"), c("Control", "Test")))
	logMsg('Contingency table:')
	print(contingencyTable)
	print(chisq.test(contingencyTable))
	print(prop.test(contingencyTable["Critical",], colSums(contingencyTable)))
	print(fisher.test(contingencyTable))
	NULL
}

# Matching inspections data
evaluateInspections <- function(inspections, predictions, startDate="2014-01-01") {
	
	# food inspections history from portal
	logMsg(paste('Food inspections:', nrow(inspections)))
	
	#subset
	inspections <- subset(inspections, Inspection.Date >= as.POSIXct(startDate, format="%Y-%m-%d"))
	logMsg(paste('Food inspections after', startDate, ':', nrow(inspections)))
	logMsg('Keep just the first of multiple inspections')
	inspections <- inspections[with(inspections, order(License, Inspection.Date)) , ] # sort by license number and day 
	inspections <- inspections[!duplicated(inspections$License) , ] # remove 2nd and subsequent occurrances of a license number
	logMsg(paste('Unique licenses in inspections', length(unique(inspections$License))))
	summarize(inspections)
	
	# predictions from model
	logMsg(paste('Predictions', nrow(predictions)))
	logMsg(paste('Unique licenses in predictions', length(unique(predictions$License))))
	logMsg('Predictions by group:')
	print(table(predictions$type))
	logMsg('Predictions by zip code:')
	print(sort(table(predictions$zip_code), decreasing=TRUE))
	summarize(predictions)
	
	# merge predictions and history
	inspections <- merge(predictions, inspections)
	logMsg(paste('Rows after merge of predicitons and inspections:', nrow(inspections)))
	logMsg(paste('Unique licenses after merge', length(unique(inspections$License))))
	
	# Find unmatched data that is in the predictions list but not in food inspection data
	logMsg('Finding uninspected predictions')
	predictionsNotInspected <- predictions[!(predictions$License %in% inspections$License) , ]
	logMsg(paste("Predictions without inspections:", nrow(predictionsNotInspected)))
	print(predictionsNotInspected[ , c("License", "zip_code", "type", "doing_business_as_name")])
	logMsg('Uninspected predictions by group:')
	print(table(predictionsNotInspected$type))
	
	# Remove non-inspection inspections from experiment
	nonInspections <- inspections[inspections$Result %in% c("No Entry", "Out of Business", "Business Not Located") , ]
	logMsg(paste('No inspection due to No Entry, Out of Business, or Business Not Located =', nrow(nonInspections)))
	print(nonInspections[ , c("License", "Zip", "Inspection.Date", "type", "Results", "doing_business_as_name")])
	logMsg('Non-inspections by group')
	print(table(nonInspections$type))
	logMsg('Removing non-inspections due to No Entry, Out of Business, or Business Not Located')
	inspections <- inspections[!(inspections$License) %in% nonInspections$License , ]
	summarize(inspections)
	
	logMsg('Differences in risk classification (rows are history data, columns are predictions data):')
	print(table(inspections$Risk, inspections$risk))
	
	zipCodeMismatches <- inspections[!is.na(inspections$Zip) & inspections$Zip!=inspections$zip_code , ]	
	logMsg(paste('Differences in zip code (DBA.Name, Zip And Address are from history data, doing_business_as_name, zip_code and address are from predictions data):', nrow(zipCodeMismatches)))
	print(zipCodeMismatches[ , c("License", "DBA.Name", "Address", "Zip", "doing_business_as_name", "address", "zip_code", "type")])
	logMsg('Differences in zip code by group')
	print(table(zipCodeMismatches$type))
	
	logMsg('Inspections by type and group:')
	byType <- table(inspections$Inspection.Type, inspections$type)
	print(byType[byType[ , "both"] > 0 | byType[ , "control"] > 0 | byType[ , "test"] > 0 , ])
	
	logMsg('Inspections by result and group:')
	byResult <- table(inspections$Results, inspections$type)
	print(byResult[byResult[ , "both"] > 0 | byResult[ , "control"] > 0 | byResult[ , "test"] > 0 , ])
	
	# Parse and categorize inspections by criticality level
	logMsg("Adding counts for critical, serious, and minor violations")
	inspections <- countViolations(inspections)	
	logMsg("Finished adding counts for critical, serious, and minor violations")
	
	logMsg("Sanitarians by number of inspections, critical outcomes, and percent critical outcomes")
	bySanitarian <- cbind(inspections=table(inspections$sanitarian), fails=table(inspections$sanitarian[inspections$critical]))
	bySanitarian <- cbind(bySanitarian, failureRate=(bySanitarian[ , "fails"] / bySanitarian[ , "inspections"]))
	bySanitarian <- merge(bySanitarian, aggregate(prediction ~ sanitarian, inspections, sum), by.x="row.names", by.y="sanitarian")
	bySanitarian$prediction <- bySanitarian$prediction / bySanitarian$inspections
	names(bySanitarian)[names(bySanitarian)=="Row.names"] <- "Sanitarian" # rename column
	names(bySanitarian)[names(bySanitarian)=="prediction"] <- "avgPrediction" # rename column
	bySanitarian$conditionalFailureRate <- bySanitarian$failureRate * bySanitarian$avgPrediction
	bySanitarian <- bySanitarian[order(-bySanitarian[ , "failureRate"]) , ] # sort decending failure rate
	print(bySanitarian)
			
	testPredictions(inspections$critical, inspections$type)
	
	NULL
} 

run <- function() {
	fi <- readFoodInspections()
	il <- readPredictions()
	evaluateInspections(fi, il)
}