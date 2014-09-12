# TODO: Add comment
# 
# Author: 368982
###############################################################################

library('RUnit')

source("utilities.R")

df <- data.frame(name=c("foo", "bar", "foo", "bas"), attribute=c(1, 2, 3, 4))

test.anonymizeColumns <- function() {
	actual <- anonymizeColumns(df, c("name"))
	checkEquals(actual$name, c(3, 1, 3, 2), "name identifiers")
	checkEquals(actual$attribute, c(1, 2, 3, 4), "attributes the same")
}
