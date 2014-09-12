# AUTHOR: Hugh J. Devlin, Ph. D.
# CREATED: 2014-04-07

source("utilities.R")

readLicenses <- function(file) {
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
