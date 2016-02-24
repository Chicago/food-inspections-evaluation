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
garbageCarts <- read.socrata("https://data.cityofchicago.org/resource/9ksk-na4q.csv")
# str(garbageCarts)

# garbageCarts <- as.data.table(garbageCarts)
#
# garbageCarts[ , Creation.Date := as.POSIXct(Creation.Date)]
# garbageCarts[ , Completion.Date := as.POSIXct(Completion.Date)]

garbageCarts$Creation.Date <- as.POSIXct(garbageCarts$Creation.Date)
garbageCarts$Completion.Date <- as.POSIXct(garbageCarts$Completion.Date)

# garbageCarts[ , Status := as.character(Status)]
# garbageCarts[ , Service.Request.Number := as.character(Service.Request.Number)]
# garbageCarts[ , Type.of.Service.Request := as.character(Type.of.Service.Request)]
# garbageCarts[ , Current.Activity := as.character(Current.Activity)]
# garbageCarts[ , Most.Recent.Action := as.character(Most.Recent.Action)]
# garbageCarts[ , Street.Address := as.character(Street.Address)]
# garbageCarts[ , Location := as.character(Location)]

garbageCarts$Status <- as.character(garbageCarts$Status)
garbageCarts$Service.Request.Number <- as.character(garbageCarts$Service.Request.Number)
garbageCarts$Type.of.Service.Request <- as.character(garbageCarts$Type.of.Service.Request)
garbageCarts$Current.Activity <- as.character(garbageCarts$Current.Activity)
garbageCarts$Most.Recent.Action <- as.character(garbageCarts$Most.Recent.Action)
garbageCarts$Street.Address <- as.character(garbageCarts$Street.Address)
garbageCarts$Location <- as.character(garbageCarts$Location)

garbageCarts <- as.data.table(garbageCarts)
setnames(garbageCarts, gsub("\\.","_",colnames(garbageCarts)))

## MODIFY DATA
geneorama::convert_datatable_IntNum(garbageCarts)
geneorama::convert_datatable_DateIDate(garbageCarts)

## SAVE ANSWER
saveRDS(garbageCarts , "DATA/garbage_carts.Rds")

