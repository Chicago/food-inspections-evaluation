# TITLE: foodInspections.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-08

options(warn=1)
options(error=utils::recover)
options(max.print=15000)
options(width=200)

source("utilities.R")

readInspections <- function(file="../data/Food_Inspections.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	names(result)[names(result)=="License.."] <- "License" # "License #" on the portal
	result$Inspection.Date <- as.POSIXct(result$Inspection.Date, format="%m/%d/%Y")
	result
}

# last digit of year as plot character
yearPlotCharacter <- function(year) {
	return(strtoi(charToRaw("0"), 16L) + as.integer(year) - 2010)
}

plotYearByMonth <- function(year, df) {
	yearName = as.character(year)
	lines(1:12, df[yearName , ])
	points(1:12, df[yearName , ], pch=yearPlotCharacter(year))
}

addMonthAxisAndYearsLegend <- function(location='bottomright', years=2010:2013) {
	axis(side=1, at=1:12, labels=month(1:12 , label=TRUE, abbr=TRUE))
	legend(location, legend=years, pch=yearPlotCharacter(years), title="Years")
}

overPlotYearsByMonth <- function(...) {
	plot(1:12, type="n", xlab="Month", xaxt="n", ...)
}

# Matching inspections data
analyzeInspections <- function(inspections) {
	RESULT_COLORS <- c("white", "red", "grey", "black", "green", "yellow")
	
	invalidZip <- (inspections$Zip == 60627)
	logMsg(paste('Removing invalid zip 60627; invalid rows =', sum(invalidZip, na.rm=TRUE)))
	inspections <- inspections[!invalidZip , ]

	# decorate data frame
	inspections$year <- year(inspections$Inspection.Date)
	inspections$month <- month(inspections$Inspection.Date)
	summarize(inspections)
	
	logMsg(paste('Unique license numbers in food inspections =', length(unique(inspections$License))))
	logMsg(paste('Unique zip codes in food inspections =', length(unique(inspections$Zip))))
	
	logMsg('Chicago food inspections by zip code and result:')
	inspectionsChicago <- inspections[60600 < inspections$Zip & inspections$Zip < 60700 , ]
	inspectionsChicago$Zip <- factor(inspectionsChicago$Zip - 60600)
	byZipAndResult <- table(inspectionsChicago$Zip, inspectionsChicago$Results)
	print(byZipAndResult)
	dev.new()
	barplot(t(byZipAndResult),
			main="Chicago food inspections by zip code and result (2010-present)",
			xlab="Zip code 606xx",
			ylab="Chicago food inspections",
			legend.text=colnames(byZipAndResult),
			args.legend=list(x="topright", title="Result"),
			col=RESULT_COLORS
	)
	dev.copy(svg, filename="../out/ChicagoFoodInspectionsByZipCodeAndResult.svg")
	dev.off()
	
	logMsg('Food inspections by year and result:')
	byYearAndResult <- table(inspections$Results, inspections$year)
	print(byYearAndResult)
	dev.new()
	barplot(byYearAndResult,
			main="Food inspections by year and result", 
			xlab="Year", 
			ylab="Food inspections",
			legend.text=rownames(byYearAndResult),
			args.legend=list(x="right", title="Result"),
			col=RESULT_COLORS
	)
	dev.copy(svg, filename="../out/FoodInspectionsByYearAndResult.svg")
	dev.off()
	
	logMsg('Food inspections by year and month:')
	byYearMonth <- table(inspections$year, inspections$month)
	print(byYearMonth)
	dev.new()
	overPlotYearsByMonth(
			main="Food inspections by year and month",
			ylab="Food inspections",
			ylim=range(byYearMonth)
	)
	lapply(2010:2013, plotYearByMonth, byYearMonth)
	addMonthAxisAndYearsLegend()
	dev.copy(svg, filename="../out/FoodInspectionsByYearAndMonth.svg")
	dev.off()
	
	logMsg('Food inspection failures by year and month:')
	fails <- inspections[inspections$Results == 'Fail' , ]
	failsByYearMonth <- table(fails$year, fails$month)
	print(failsByYearMonth)
	dev.new()
	overPlotYearsByMonth(
			main="Food inspection failures by year and month",
			ylab="Food inspection failures",
			ylim=range(failsByYearMonth)
	)
	lapply(2010:2013, plotYearByMonth, failsByYearMonth)
	addMonthAxisAndYearsLegend()
	dev.copy(svg, filename="../out/FoodInspectionsFailuresByYearAndMonth.svg")
	dev.off()
	
	logMsg('Food inspection failure rate by year and month:')
	failureRateByYearMonth <- failsByYearMonth / byYearMonth
	print(failureRateByYearMonth)
	dev.new()
	overPlotYearsByMonth(
			main="Food inspection failure rate by year and month",
			ylab="Food inspection failure rate",
			ylim=c(0, 0.4)
	)
	lapply(2010:2013, plotYearByMonth, failureRateByYearMonth)
	addMonthAxisAndYearsLegend('topright')
	dev.copy(svg, filename="../out/FoodInspectionsFailureRateByYearAndMonth.svg")
	dev.off()
	
	logMsg('Chicago food inspection failures by zip code and year:')
	failsChicago  <- inspectionsChicago[inspectionsChicago$Results == 'Fail' , ]
	failsChicagoByZipAndYear <- table(failsChicago$Zip, failsChicago$year)
	print(failsChicagoByZipAndYear)
	dev.new()
	par(las=1) # horizontal axis labels
	stripchart(values ~ ind,
			data=stack(as.data.frame.matrix(failsChicagoByZipAndYear)),
			pch=20,
			main="Chicago food inspection failures by zip and year",
			xlab="Year",
			ylab="Food inspection failures",
			vertical=TRUE,
			col="blue"
	)
	apply(failsChicagoByZipAndYear, 1, lines, col="blue") 
	dev.copy(svg, filename="../out/ChicagoFoodInspectionsFailuresByZipAndYear.svg")
	dev.off()
	
	logMsg('Chicago food inspection failure counts correlation by zip code from year-to-year:')
	print(cor(failsChicagoByZipAndYear))
	logMsg('Chicago food inspection failure counts by zip code correlation 2012 to 2013 with confidence interval and p-value:')
	print(cor.test(failsChicagoByZipAndYear[ , "2013"], failsChicagoByZipAndYear[ , "2014"]))
	
	logMsg('Chicago food inspection failure rates by zip code and year:')
	inspectionsChicagoByZipAndYear <- table(inspectionsChicago$Zip, inspectionsChicago$year)
	failureRateChicagoByZipAndYear <- failsChicagoByZipAndYear / inspectionsChicagoByZipAndYear
	print(failureRateChicagoByZipAndYear)
	dev.new()
	par(las=1) # horizontal axis labels
	stripchart(values ~ ind,
			data=stack(as.data.frame.matrix(failureRateChicagoByZipAndYear)),
			pch=20,
			main="Chicago food inspection failure rates by zip and year",
			xlab="Year",
			ylab="Food inspection failure rate",
			vertical=TRUE,
			col="blue"
	)
	apply(failureRateChicagoByZipAndYear, 1, lines, col="blue") 
	dev.copy(svg, filename="../out/ChicagoFoodInspectionsFailureRatesByZipAndYear.svg")
	dev.off()	
	
	logMsg('Chicago food inspection failure rate correlation by zip code from year-to-year:')
	print(cor(failureRateChicagoByZipAndYear))
	logMsg('Chicago food inspection failure rate by zip code correlation 2013 to 2014 with confidence interval and p-value:')
	print(cor.test(failureRateChicagoByZipAndYear[ , "2013"], failureRateChicagoByZipAndYear[ , "2014"], use="complete.obs"))
	
	logMsg('Done.')
} 

run <- function() {
	logMsg('Reading food inspections')
	fi <- readInspections()
	logMsg(paste('Food inspections:', nrow(fi)))
	analyzeInspections(fi)
}