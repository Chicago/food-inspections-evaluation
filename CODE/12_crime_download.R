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
crime <- read.socrata(
    hostname="https://data.cityofchicago.org",
    apptoken = mytoken,
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
