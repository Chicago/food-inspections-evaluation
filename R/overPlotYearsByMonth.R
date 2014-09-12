# TITLE: Sanitarians.R
# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-17

# last digit of year as plot character
yearPlotCharacter <- function(year) {
	return(strtoi(charToRaw("0"), 16L) + as.integer(year) - 2010)
}

plotYearByMonth <- function(year, df) {
	yearName = as.character(year)
	lines(1:12, df[yearName , ])
	points(1:12, df[yearName , ], pch=yearPlotCharacter(year))
}

addMonthAxisAndYearsLegend <- function(location='bottomright', years) {
	axis(side=1, at=1:12, labels=month(1:12 , label=TRUE, abbr=TRUE))
	legend(location, legend=years, pch=yearPlotCharacter(years), title="Years")
}

overPlotYearsByMonth <- function(...) {
	plot(1:12, type="n", xlab="Month", xaxt="n", ...)
}
