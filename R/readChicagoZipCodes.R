# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-24

readChicagoZipCodes <- function(file="../data/ChicagoZipCodes.csv") {
	result <- read.csv(file, stringsAsFactors=FALSE, na.strings='')
	result
}
