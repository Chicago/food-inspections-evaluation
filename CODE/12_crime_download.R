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

## Example with date filter
# examp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?primary_type=BURGLARY&$where=date>'2016-02-01'"
# str(read.socrata(examp))

crime <- read.socrata("https://data.cityofchicago.org/resource/ijzp-q8t2.csv?primary_type=BURGLARY")
# str(crime)

crime$Date <- as.POSIXct(crime$Date)
crime$Updated.On <- as.POSIXct(crime$Updated.On)

crime$Case.Number <- as.character(crime$Case.Number)
crime$Block <- as.character(crime$Block)
crime$Primary.Type <- as.character(crime$Primary.Type)
crime$Description <- as.character(crime$Description)
crime$Location.Description <- as.character(crime$Location.Description)
crime$Arrest <- as.character(crime$Arrest)
crime$Domestic <- as.character(crime$Domestic)
crime$Location <- as.character(crime$Location)

crime <- as.data.table(crime)
setnames(crime, gsub("\\.","_",colnames(crime)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(crime)
geneorama::convert_datatable_DateIDate(crime)
crime[ , Arrest := as.logical(Arrest)]
crime[ , Domestic := as.logical(Domestic)]


# orig <- readRDS("DATA - Copy/crime.Rds")
# str(orig)
# str(crime)

## SAVE ANSWER
saveRDS(crime , "DATA/crime.Rds")
