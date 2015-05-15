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
crime <- read.socrata(
    hostname="https://data.cityofchicago.org",
    resourcePath="ijzp-q8t2",
    query = "primary_type='BURGLARY'",
    keyfield = "id")
crime <- as.data.table(crime)
setnames(crime, gsub("\\.","_",colnames(crime)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(crime)
geneorama::convert_datatable_DateIDate(crime)
crime[ , Arrest := as.logical(Arrest)]
crime[ , Domestic := as.logical(Domestic)]

## SAVE ANSWER
saveRDS(crime , "DATA/crime.Rds")
