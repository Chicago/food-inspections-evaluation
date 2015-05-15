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
## DEFINE GLOBAL VARIABLES
##==============================================================================
## DOWNLOAD FILES FROM DATA PORTAL
##==============================================================================
business <- read.socrata(
    hostname="https://data.cityofchicago.org",
    #apptoken = mytoken,
    resourcePath="r5kz-chrr",
    keyfield = "id")
business <- as.data.table(business)

setnames(business, gsub("\\.","_",colnames(business)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(business)
geneorama::convert_datatable_DateIDate(business)

## SAVE ANSWER
saveRDS(business, "DATA/bus_license.Rds")
