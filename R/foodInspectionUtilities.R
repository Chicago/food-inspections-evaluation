# Food inspection utilities
# 
# Author: 368982
###############################################################################

# split on vertical bar, then on period after the violation code number, keep the code numbers
parseViolationCodes <- function(violations) {
	lapply(lapply(strsplit(violations, "| ", fixed=TRUE), strsplit, ". ", fixed=TRUE), function(x) as.integer(lapply(x, FUN='[', 1)))
}

# critical=1, serious=2, minor=3, other=0
classifyViolations <- function(violations) {
	lapply(parseViolationCodes(violations), function(x) ifelse(x %in% 1:14, 1, ifelse(x %in% 15:29, 2, ifelse(x %in% 30:44, 3, 0))))
}

# counts by criticality
# tabulate ignores zeroes
# returns an integer matrix with a row for each inspection, and 3 columns for critical, serious, and minor counts
violationCounts <- function(violations) {
	result <- do.call(rbind, lapply(classifyViolations(violations), function(x) tabulate(as.integer(x), nbins=3)))
	colnames(result) <- c("critical", "serious", "minor")
	result
}

# add violation counts to inspections data frame
countViolations <- function(inspections) {
	result <- inspections
	violationCounts <- violationCounts(inspections$Violations)
	
	result$criticalCount <- violationCounts[ , "critical"]
	result$seriousCount <-  violationCounts[ , "serious"] 
	result$minorCount <-  violationCounts[ , "minor"] 
	
	result$serious <- (result$seriousCount > 0)
	result$critical <- (result$criticalCount > 0)
	result$minor <- (result$minorCount > 0)
	
	result
}

