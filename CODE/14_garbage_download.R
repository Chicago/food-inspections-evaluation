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
url <- "https://data.cityofchicago.org/resource/9ksk-na4q.csv"

## READ DATA
garbageCarts <- read.socrata(url, stringsAsFactors = FALSE)
# str(garbageCarts)

## CONVERT TO DATA TABLE
garbageCarts <- as.data.table(garbageCarts)

## Replace .'s in column names
setnames(garbageCarts, gsub("\\.","_",colnames(garbageCarts)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(garbageCarts)
geneorama::convert_datatable_DateIDate(garbageCarts)

## SAVE RESULT
saveRDS(garbageCarts , "DATA/garbage_carts.Rds")
