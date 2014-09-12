
source("utilities.R")
source("readGarrison.R")

run <- function(file="../out/AnonymizedInspectionsGarrisonExport20112014.csv") {
	logMsg('Reading Garrison food inspection history')
	garrison <- readGarrison()
	logMsg(paste('Garrison food inspection history records:', nrow(garrison)))
	logMsg('Anonymizing Garrison food inspection history records...')
	garrison <- anonymizeColumns(garrison, c("Inspector"))
	logMsg('Writing Garrison food inspection history')
	write.table(garrison, file=file, sep=',', row.names=FALSE)
	logMsg('Done.')
}