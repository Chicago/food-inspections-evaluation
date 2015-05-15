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
sanitationComplaints <- read.socrata(
    hostname="https://data.cityofchicago.org",
    resourcePath="me59-5fac",
    keyfield = "service_request_number")
sanitationComplaints <- as.data.table(sanitationComplaints)
setnames(sanitationComplaints, gsub("\\.","_",colnames(sanitationComplaints)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(sanitationComplaints)
geneorama::convert_datatable_DateIDate(sanitationComplaints)

## Remove one row where the header is (somewhat) repeated
sanitationComplaints <- sanitationComplaints[Service_Request_Number!="SERVICE REQUEST NUMBER"]

## SAVE ANSWER
saveRDS(sanitationComplaints , "DATA/sanitation_code.Rds")

