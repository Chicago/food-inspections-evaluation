
##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Check for dependencies
if(!"geneorama" %in% rownames(installed.packages())){
    if(!"devtools" %in% rownames(installed.packages())){install.packages('devtools')}
    devtools::install_github('geneorama/geneorama')}
## Load libraries
geneorama::detach_nonstandard_packages()
# geneorama::loadinstall_libraries(c("geneorama", "data.table"))
geneorama::loadinstall_libraries(c("data.table"))

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
business <- readRDS("DATA/bus_license.Rds")
crime <-  readRDS("DATA/crime.Rds")
foodInspect <- readRDS("DATA/food_inspections.Rds")
garbageCarts <- readRDS("DATA/garbage_carts.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code.Rds")

##==============================================================================
## BUSINESS
##==============================================================================
business <- business[!is.na(LICENSE_TERM_START_DATE)]
business <- business[!is.na(LICENSE_TERM_EXPIRATION_DATE)]
business <- business[!(APPLICATION_TYPE %in% c("C_CAPA","C_SBA"))]
saveRDS(business, "DATA/bus_license_filtered.Rds")

##==============================================================================
## CRIME
##==============================================================================
crime <- crime[Date>as.IDate('2011-07-01')]
crime <- crime[!(is.na(Latitude) | is.na(Longitude) | is.na(Date))]
crime <- crime[Primary_Type=="BURGLARY"]
saveRDS(crime, "DATA/crime_filtered.Rds")

##==============================================================================
## FOOD INSPECTIONS
##==============================================================================
foodInspect <- foodInspect[!is.na(Inspection_Date) & !is.na(License)]
foodInspect <- foodInspect[!duplicated(Inspection_ID)]
foodInspect <- foodInspect[License != 0]
foodInspect <- foodInspect[Inspection_Date > as.IDate("2011-09-01")]
foodInspect <- foodInspect[Inspection_Type == "Canvass"]
saveRDS(foodInspect, "DATA/food_inspections_filtered.Rds")

##==============================================================================
## garbage subsets
##==============================================================================
garbageCarts <- garbageCarts[!is.na(Latitude) & !is.na(Longitude) & !is.na(Creation_Date)]
garbageCarts <- garbageCarts[Status %in% c("Completed", "Open")]
# garbageCarts$status <- NULL
saveRDS(garbageCarts, "DATA/garbage_carts_filtered.Rds")

##==============================================================================
## sanitation subsets
##==============================================================================
sanitationComplaints <- sanitationComplaints[!is.na(Latitude) & !is.na(Longitude) & !is.na(Creation_Date)]
sanitationComplaints <- sanitationComplaints[Status %in% c("Completed", "Open")]
# sanitationComplaints$status <- NULL
saveRDS(sanitationComplaints, "DATA/sanitation_code_filtered.Rds")


