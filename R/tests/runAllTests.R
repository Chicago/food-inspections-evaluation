# Run RUnit tests
# 
# Author: Hugh 2013-07-15
###############################################################################

options(warn=1)

library('RUnit')

test.suite <- defineTestSuite(
	"all tests",
	dirs = file.path("tests"),
	testFileRegexp = '^test.*\\.R'
)

runAllTests <- function() {
	test.result <- runTestSuite(test.suite)
	printTextProtocol(test.result) 
}
