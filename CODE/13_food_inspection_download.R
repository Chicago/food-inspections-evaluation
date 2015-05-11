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
foodInspect <- read.socrata(
    hostname="https://data.cityofchicago.org",
    apptoken = mytoken,
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
