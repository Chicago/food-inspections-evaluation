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
url <- "https://data.cityofchicago.org/resource/me59-5fac.csv"

## READ DATA
sanitationComplaints <- read.socrata(url, stringsAsFactors = FALSE)
# str(sanitationComplaints)

## CONVERT TO DATA TABLE
sanitationComplaints <- as.data.table(sanitationComplaints)

## Replace .'s in column names
setnames(sanitationComplaints, gsub("\\.","_",colnames(sanitationComplaints)))

## Remove one row where the header is (somewhat) repeated
sanitationComplaints <- sanitationComplaints[Service_Request_Number!="SERVICE REQUEST NUMBER"]

## MODIFY DATA
geneorama::convert_datatable_IntNum(sanitationComplaints)
geneorama::convert_datatable_DateIDate(sanitationComplaints)

## SAVE RESULT
saveRDS(sanitationComplaints , "DATA/15_sanitation_code.Rds")

