
##IMPORT FROM EXCEL
insp <- geneorama::clipped()
library(data.table)
insp$inspectiondate <- as.IDate(insp$inspectiondate, "%m/%d/%Y")
insp$inspectiondate <- as.POSIXct(as.character(insp$inspectiondate))
str(insp)
saveRDS(insp, "DATA/InspectionsGarrisonExport20141105.Rds")
