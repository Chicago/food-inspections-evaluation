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

## DEFINE URL AND QUERY
url <- "https://data.cityofchicago.org/resource/ijzp-q8t2.csv"
# q <- "?primary_type=BURGLARY&$where=date>'2016-02-01'" # date filter examp
q <- "?primary_type=BURGLARY"

## READ DATA (BURGLARY ONLY)
crime <- read.socrata(paste0(url, q), stringsAsFactors = FALSE)
# str(crime)

## CONVERT TO DATA TABLE
crime <- as.data.table(crime)

## Replace .'s in column names
setnames(crime, gsub("\\.","_",colnames(crime)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(crime)
geneorama::convert_datatable_DateIDate(crime)
crime[ , Arrest := as.logical(Arrest)]
crime[ , Domestic := as.logical(Domestic)]

## SAVE RESULT
saveRDS(crime , "DATA/crime.Rds")
