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
## Application Tokens for Socrata API:
## Note: only the first line is used , Note: whitespace and comments will be stripped
if(!file.exists("CODE/socrata_token.txt")){
    stop(paste0("You need a file called 'socrata_token.txt' containing a token"))
} else{
    mytoken <- gsub(" |\\#.+", "", readLines("CODE/socrata_token.txt", n=1))
}

##==============================================================================
## DOWNLOAD FILES FROM DATA PORTAL
##==============================================================================
garbageCarts <- read.socrata(
    hostname="https://data.cityofchicago.org",
    apptoken = mytoken,
    resourcePath="9ksk-na4q",
    keyfield = "service_request_number")
garbageCarts <- as.data.table(garbageCarts)
setnames(garbageCarts, gsub("\\.","_",colnames(garbageCarts)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(garbageCarts)
geneorama::convert_datatable_DateIDate(garbageCarts)

## SAVE ANSWER
saveRDS(garbageCarts , "DATA/garbage_carts.Rds")

