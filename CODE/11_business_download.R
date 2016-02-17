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
## DOWNLOAD FILES FROM DATA PORTAL
##==============================================================================
business <- read.socrata("https://data.cityofchicago.org/resource/r5kz-chrr.csv")
# saveRDS(business, "DATA/bus_license_RAW_BACKUP.Rds")
# business <- readRDS("DATA/bus_license_RAW_BACKUP.Rds")
# str(business)

business$APPLICATION.CREATED.DATE <- as.IDate(business$APPLICATION.CREATED.DATE)
business$APPLICATION.REQUIREMENTS.COMPLETE <- as.IDate(business$APPLICATION.REQUIREMENTS.COMPLETE)
business$PAYMENT.DATE <- as.IDate(business$PAYMENT.DATE)
business$LICENSE.APPROVED.FOR.ISSUANCE <- as.IDate(business$LICENSE.APPROVED.FOR.ISSUANCE)
business$DATE.ISSUED <- as.IDate(business$DATE.ISSUED)
business$LICENSE.STATUS.CHANGE.DATE <- as.IDate(business$LICENSE.STATUS.CHANGE.DATE)

business$LICENSE.TERM.START.DATE <- as.IDate(business$LICENSE.TERM.START.DATE, "%m/%d/%Y")
business$LICENSE.TERM.EXPIRATION.DATE <- as.IDate(business$LICENSE.TERM.EXPIRATION.DATE, "%m/%d/%Y")

business$ID <- as.character(business$ID)
business$LEGAL.NAME <- as.character(business$LEGAL.NAME)
business$DOING.BUSINESS.AS.NAME <- as.character(business$DOING.BUSINESS.AS.NAME)
business$ADDRESS <- as.character(business$ADDRESS)
business$CITY <- as.character(business$CITY)
business$STATE <- as.character(business$STATE)
business$LICENSE.DESCRIPTION <- as.character(business$LICENSE.DESCRIPTION)
business$APPLICATION.TYPE <- as.character(business$APPLICATION.TYPE)
business$CONDITIONAL.APPROVAL <- as.character(business$CONDITIONAL.APPROVAL)
business$LICENSE.STATUS <- as.character(business$LICENSE.STATUS)
business$LOCATION <- as.character(business$LOCATION)

business <- as.data.table(business)

setnames(business, gsub("\\.","_",colnames(business)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(business)
# geneorama::convert_datatable_DateIDate(business)


# orig <- readRDS("DATA - Copy/bus_license.Rds")
# str(orig)
# str(business)


## SAVE ANSWER
saveRDS(business, "DATA/bus_license.Rds")


