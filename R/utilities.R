# project-independent utility functions
# 
# Author: Hugh
###############################################################################

library(lubridate)

#' Sun, Mon, etc.
#'
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
WEEKDAY_ABBREVIATIONS = levels(wday(1:7, label=TRUE))

#' Time-stamped message
#'
#' construct a time-stamped, origin-stamped log message
#' 
#' @param s a string
#' @return a string
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
prefixMsg <- function(s, i) {
	paste(format(Sys.time(), "%Y-%m-%d %H:%M:%OS3 "), as.character(sys.call(i))[1], ": ", s, '\n', sep='')
}

#' Time-stamped stop message
#'
#' construct a time-stamped, origin-stamped stop message. 
#' @param s a string
#' @return a string
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
stopMsg <- function(s) {
	prefixMsg(s, -3L)
}

#' Time-stamped console message
#'
#' Issue a time-stamped, origin-stamped log message. 
#' @param s a string
#' @return None (invisible NULL) as per cat
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
logMsg <- function(s) {
	cat(prefixMsg(s, -3L))
}

#' is whole number
#'
#' http://cran.r-project.org/doc/FAQ/R-FAQ.html#Why-doesn_0027t-R-think-these-numbers-are-equal_003f
#' 
#' @param x a numeric
#' @param tolerance defaults to machine discrimination
#' @return Boolean
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
is.wholeNumber <- function(x, tolerance=(.Machine$double.eps ^ 0.5)) {
	return(abs(x - round(x)) < tolerance)
}

#' safe.ifelse
#'
#' Like R base ifelse but preserves class of result
#' After Hadley Wickham from StackOverflow
#' 
#' @return object of same class as yes
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
safe.ifelse <- function(cond, yes, no) structure(ifelse(cond, yes, no), class = class(yes))

#' avoid integer overflow
#' 
#' @param x a numeric object or an object which may be coerced to numeric
#' @return a numeric object
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
sumAsNumeric <- function(x) {
	sum(as.numeric(x))
}

#' construct a file path for a graph based on the input file and a label
#' 
#' @param filePath
#' @param label
#' @return a filePath
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
svgFilePath <- function(filePath, label) {
	file.path('..', 'out', gsub('\\.rds$', paste(label, 'svg', sep="."), basename(filePath)))
}

#' save current plot as svg
#' 
#' @param filePath
#' @return
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
saveAsSvg <- function(filePath) {
	svg(filePath)
	dev.set(which=dev.prev())
	dev.copy(which=dev.prev())
	dev.off()
}

#' overview
#' 
#' @param x an R object
#' @return NULL
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
summarize <- function(x) {
	str(x)
	print(summary(x))
	NULL
}

#' convert named columns in a data frame to factors
#' @param df a data frame
#' @param columnNames a vector of column names
#' @return the data frame
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
factorizeColumns <- function(df, columnNames) {
	result <- df
	for(columnName in columnNames) {
		result[[columnName]] <- factor(result[[columnName]])
	}
	result
}

#' convert named columns in a data frame to factors and then to integers
#' @param df a data frame
#' @param columnNames a vector of column names
#' @return the data frame
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
anonymizeColumns <- function(df, columnNames) {
	result <- df
	for(columnName in columnNames) {
		result[[columnName]] <- as.integer(factor(result[[columnName]]))
	}
	result
}

#' convert named columns in a data frame to POSIX dates
#' @param df a data frame
#' @param columnNames a vector of column names of data columns
#' @return the data frame
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixifyColumns <- function(df, columnNames, format="%m/%d/%Y") {
	result <- df
	for(columnName in columnNames) {
		result[[columnName]] <- as.POSIXct(result[[columnName]], format=format)
	}
	result
}

#' convert blanks in named columns in a data frame to NA
#' @param df a data frame
#' @param columnNames a vector of column names of data columns
#' @return the data frame
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
naColumns <- function(df, columnNames=colnames(df), na="") {
	result <- df
	for(columnName in columnNames) {
		result[[columnName]] <- ifelse(result[[columnName]] == na, NA, result[[columnName]])
	}
	result
}