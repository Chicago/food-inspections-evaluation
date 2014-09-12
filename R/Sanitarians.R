# TITLE: Sanitarians.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-17

options(warn=1)
options(error=utils::recover)
options(max.print=15000)
options(width=200)

source("readGarrison.R")
source("readFoodInspectionsHistory.R")
source("overPlotYearsByMonth.R")

# Matching inspections data
analyzeSanitarians <- function(garrison, portal) {
	
	# decorate Garrison data frame
	garrison$year <- year(garrison$Date)
	garrison$month <- month(garrison$Date)
	
	logMsg(paste('Unique license numbers in Garrison inspections =', length(unique(garrison$License))))
	logMsg(paste('Unique zip codes in Garrison inspections =', length(unique(garrison$Zip))))
	logMsg(paste('Unique sanitarian in Garrison inspections =', length(unique(garrison$Inspector))))
	summarize(garrison)
	
	logMsg(paste('Unique license numbers in portal inspections =', length(unique(portal$License))))
	logMsg(paste('Unique zip codes in portal inspections =', length(unique(portal$Zip))))
	summarize(portal)
	
	logMsg('Garrison inspections by sanitarian:')
	bySanitarian <- as.matrix(table(garrison$Inspector))
	print(bySanitarian)
	print(summary(as.integer(bySanitarian)))

	logMsg('Garrison inspections by year and month:')
	byYearMonth <- table(garrison$year, garrison$month)
	print(byYearMonth)
	dev.new()
	overPlotYearsByMonth(
			main="Garrison inspections by year and month",
			ylab="Inspections",
			ylim=range(byYearMonth)			
	)
	lapply(2011:2014, plotYearByMonth, byYearMonth)
	addMonthAxisAndYearsLegend(years=2011:2014)
	dev.copy(svg, filename="../out/GarrisonInspectionsByYearAndMonth.svg")
	dev.off()
	
	duplicatedGarrison <- duplicated(garrison[ , c("License", "Date")])
	logMsg(paste("Removing duplicate inspections from Garrison:", sum(duplicatedGarrison)))
	garrison <- garrison[!duplicatedGarrison , ]
	
	duplicatedPortal <- duplicated(portal[ , c("License", "Inspection.Date")])
	logMsg(paste("Removing duplicate inspections from portal:", sum(duplicatedPortal)))
	portal <- portal[!duplicatedPortal , ]
	
	df <- merge(
			subset(garrison, select=-c(Address)),
			subset(portal, select=-c(Zip, DBA.Name, AKA.Name, Inspection.Type, City, State, Latitude, Longitude, Location)),
			by.x=c("License", "Date"), by.y=c("License", "Inspection.Date"))
	duplicatedDf <- duplicated(df[ , c("License", "Date")])
	logMsg(paste("Removing duplicate inspections:", sum(duplicatedDf)))
	df <- df[!duplicatedDf , ]
	logMsg(paste('Unique license numbers in inspections =', length(unique(df$License))))
	logMsg(paste('Unique zip codes in inspections =', length(unique(df$Zip))))
	logMsg(paste('Unique sanitarians in inspections =', length(unique(df$Inspector))))
	summarize(df)
	
	logMsg('Inspections by sanitarian and year:')
	bySanitarianAndYear <- table(df$Inspector, df$year)
	print(bySanitarianAndYear)
	dev.new()
	par(las=1) # horizontal axis labels
	stripchart(values ~ ind,
			data=stack(as.data.frame.matrix(bySanitarianAndYear)),
			pch=20,
			main="Inspections by sanitarian and year",
			xlab="Year",
			ylab="Inspections",
			vertical=TRUE,
			col="blue"
	)
	apply(bySanitarianAndYear, 1, lines, col="blue") 
	dev.copy(svg, filename="../out/InspectionsBySanitarianAndYear.svg")
	dev.off()
	
	logMsg('Fails by sanitarian and year:')
	fails  <- df[df$Results == 'Fail' , ]
	failsBySanitarianAndYear <- table(fails$Inspector, fails$year)
	print(failsBySanitarianAndYear)
	dev.new()
	par(las=1) # horizontal axis labels
	stripchart(values ~ ind,
			data=stack(as.data.frame.matrix(failsBySanitarianAndYear)),
			pch=20,
			main="Fails by sanitarian and year",
			xlab="Year",
			ylab="Fails",
			vertical=TRUE,
			col="blue"
	)
	apply(failsBySanitarianAndYear, 1, lines, col="blue") 
	dev.copy(svg, filename="../out/FailsBySanitarianAndYear.svg")
	dev.off()
		
	logMsg('Fail counts correlation by sanitarian from year-to-year:')
	print(cor(failsBySanitarianAndYear, use="pairwise.complete.obs"))
	logMsg('Fail counts by sanitarian correlation 2012 to 2013 with confidence interval and p-value:')
	print(cor.test(failsBySanitarianAndYear[ , "2013"], failsBySanitarianAndYear[ , "2014"], use="pairwise.complete.obs"))
	
	logMsg('Failure rates by sanitarian and year:')
	failureRateBySanitarianAndYear <- failsBySanitarianAndYear / bySanitarianAndYear
	print(failureRateBySanitarianAndYear)
	dev.new()
	par(las=1) # horizontal axis labels
	stripchart(values ~ ind,
			data=stack(as.data.frame.matrix(failureRateBySanitarianAndYear)),
			pch=20,
			main="Failure rates by sanitarian and year",
			xlab="Year",
			ylab="Failure rate",
			vertical=TRUE,
			col="blue"
	)
	apply(failureRateBySanitarianAndYear, 1, lines, col="blue") 
	dev.copy(svg, filename="../out/FailureRatesBySanitarianAndYear.svg")
	dev.off()	
	
	logMsg('Failure rate correlation by sanitarian from year-to-year:')
	print(cor(failureRateBySanitarianAndYear, use="pairwise.complete.obs"))
	logMsg('Failure rate by sanitarian correlation 2013 to 2014 with confidence interval and p-value:')
	print(cor.test(failureRateBySanitarianAndYear[ , "2013"], failureRateBySanitarianAndYear[ , "2014"], use="pairwise.complete.obs"))
	
	sanitarians <- data.frame(
			Inspections2011to2013=rowSums(bySanitarianAndYear[, c("2011", "2012", "2013")]),
			Fails2011to2013=rowSums(failsBySanitarianAndYear[, c("2011", "2012", "2013")]),
			Inspections2014=bySanitarianAndYear[,"2014"],
			Fails2014=failsBySanitarianAndYear[,"2014"]
	)
	sanitarians$Rate2011to2013 <- sanitarians$Fails2011to2013 / sanitarians$Inspections2011to2013
	sanitarians$Rate2014 <- sanitarians$Fails2014 / sanitarians$Inspections2014
	print(sanitarians)
	logMsg('Failure rate by sanitarian correlation 2013 to 2014 with confidence interval and p-value:')
	print(cor.test(sanitarians$Rate2011to2013, sanitarians$Rate2014, use="pairwise.complete.obs"))
	
	logMsg('Done.')
} 

run <- function() {
	logMsg('Reading Garrison food inspection history')
	garrison <- cleanGarrison(readGarrison())
	logMsg(paste('Garrison food inspection history records:', nrow(garrison)))
	
	logMsg('Reading portal food inspection history')
	portal <- readFoodInspectionsHistory()
	logMsg(paste('Portal food inspection history records:', nrow(portal)))
	
	analyzeSanitarians(garrison, portal)
}