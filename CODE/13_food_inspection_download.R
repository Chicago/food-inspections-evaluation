if(interactive()){
    ##==========================================================================
    ## INITIALIZE
    ##==========================================================================
    ## Remove all objects; perform garbage collection
    rm(list=ls())
    gc(reset=TRUE)
    ## Detach any non-standard libraries
    geneorama::detach_nonstandard_packages()
}
## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table", "RSocrata"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## DOWNLOAD FILES FROM DATA PORTAL
##==============================================================================
foodInspect <- read.socrata("https://data.cityofchicago.org/resource/4ijn-s7e5.csv")
foodInspect <- as.data.table(foodInspect)

foodInspect[ , DBA.Name := as.character(DBA.Name)]
foodInspect[ , AKA.Name := as.character(AKA.Name)]
foodInspect[ , Facility.Type := as.character(Facility.Type)]
foodInspect[ , Risk := as.character(Risk)]
foodInspect[ , Address := as.character(Address)]
foodInspect[ , City := as.character(City)]
foodInspect[ , State := as.character(State)]
foodInspect[ , Inspection.Type := as.character(Inspection.Type)]
foodInspect[ , Results := as.character(Results)]
foodInspect[ , Violations := as.character(Violations)]
foodInspect[ , Location := as.character(Location)]

foodInspect[ , Inspection.Date := as.POSIXct(Inspection.Date)]

setnames(foodInspect, gsub("\\.","_",colnames(foodInspect)))
setnames(foodInspect, gsub("_+$","",colnames(foodInspect)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(foodInspect)
geneorama::convert_datatable_DateIDate(foodInspect)

## SAVE ANSWER
saveRDS(foodInspect , "DATA/food_inspections.Rds")
