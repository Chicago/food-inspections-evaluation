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

## DEFINE URL
url <- "https://data.cityofchicago.org/resource/r5kz-chrr.csv"

## READ DATA
business <- read.socrata(url, stringsAsFactors = FALSE)
# str(business)

## CONVERT TO DATA TABLE
business <- as.data.table(business)

## Replace .'s in column names
setnames(business, gsub("\\.","_",colnames(business)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(business)
geneorama::convert_datatable_DateIDate(business)

## FIX TWO DATE COLUMNS THAT MAY NOT DOWNLOAD PROPERLY
business[ , LICENSE_TERM_START_DATE := as.IDate(LICENSE_TERM_START_DATE, "%m/%d/%Y")]
business[ , LICENSE_TERM_EXPIRATION_DATE := as.IDate(LICENSE_TERM_EXPIRATION_DATE, "%m/%d/%Y")]

## SAVE RESULT
saveRDS(business, "DATA/bus_license.Rds")
