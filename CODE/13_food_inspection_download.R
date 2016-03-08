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
url <- "https://data.cityofchicago.org/resource/4ijn-s7e5.csv"

## READ DATA
foodInspect <- read.socrata(url, stringsAsFactors = FALSE)
str(foodInspect)

## CONVERT TO DATA TABLE
foodInspect <- as.data.table(foodInspect)

## Replace .'s in column names, and extra underscores
setnames(foodInspect, gsub("\\.","_",colnames(foodInspect)))
setnames(foodInspect, gsub("_+$","",colnames(foodInspect)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(foodInspect)
geneorama::convert_datatable_DateIDate(foodInspect)

## SAVE ANSWER
saveRDS(foodInspect , "DATA/food_inspections.Rds")
