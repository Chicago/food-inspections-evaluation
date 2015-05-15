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
foodInspect <- read.socrata(
    hostname="https://data.cityofchicago.org",
    resourcePath="4ijn-s7e5",
    pagesize = 25000,
    keyfield = "inspection_id")
foodInspect <- as.data.table(foodInspect)
setnames(foodInspect, gsub("\\.","_",colnames(foodInspect)))
setnames(foodInspect, gsub("_+$","",colnames(foodInspect)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(foodInspect)
geneorama::convert_datatable_DateIDate(foodInspect)

## SAVE ANSWER
saveRDS(foodInspect , "DATA/food_inspections.Rds")
