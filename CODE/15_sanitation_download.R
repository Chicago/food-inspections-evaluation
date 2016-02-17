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
sanitationComplaints <- read.socrata("https://data.cityofchicago.org/resource/me59-5fac.csv")

# sanitationComplaints <- as.data.table(sanitationComplaints)
#
# sanitationComplaints[ , Creation.Date := as.POSIXct(Creation.Date)]
# sanitationComplaints[ , Completion.Date := as.POSIXct(Completion.Date)]

sanitationComplaints$Creation.Date <- as.POSIXct(sanitationComplaints$Creation.Date)
sanitationComplaints$Completion.Date <- as.POSIXct(sanitationComplaints$Completion.Date)

# sanitationComplaints[ , Status := as.character(Status)]
# sanitationComplaints[ , Service.Request.Number := as.character(Service.Request.Number)]
# sanitationComplaints[ , Type.of.Service.Request := as.character(Type.of.Service.Request)]
# sanitationComplaints[ , What.is.the.Nature.of.this.Code.Violation. := as.character(What.is.the.Nature.of.this.Code.Violation.)]
# sanitationComplaints[ , Street.Address := as.character(Street.Address)]
# sanitationComplaints[ , Location := as.character(Location)]

sanitationComplaints$Status <- as.character(sanitationComplaints$Status)
sanitationComplaints$Service.Request.Number <- as.character(sanitationComplaints$Service.Request.Number)
sanitationComplaints$Type.of.Service.Request <- as.character(sanitationComplaints$Type.of.Service.Request)
sanitationComplaints$What.is.the.Nature.of.this.Code.Violation. <- as.character(sanitationComplaints$What.is.the.Nature.of.this.Code.Violation.)
sanitationComplaints$Street.Address <- as.character(sanitationComplaints$Street.Address)
sanitationComplaints$Location <- as.character(sanitationComplaints$Location)

sanitationComplaints <- as.data.table(sanitationComplaints)
setnames(sanitationComplaints, gsub("\\.","_",colnames(sanitationComplaints)))


## Remove one row where the header is (somewhat) repeated
sanitationComplaints <- sanitationComplaints[Service_Request_Number!="SERVICE REQUEST NUMBER"]

## MODIFY DATA
geneorama::convert_datatable_IntNum(sanitationComplaints)
geneorama::convert_datatable_DateIDate(sanitationComplaints)


## Quick fix to download creation date, which is needed for the heat map calc
## The following block can be removed after issue 68 is resolved in RSocrata
## https://github.com/Chicago/RSocrata/issues/68
crdate <- list()
i <- 0
while(length(crdate)==0 || length(crdate[[length(crdate)]]) == 50000 ){
    i <- i + 1
    url <- paste0("https://data.cityofchicago.org/resource/me59-5fac.csv",
                  "?$select=creation_date&$LIMIT=50000",
                  "&$OFFSET=", (i - 1) * 50000)
    crdate[[i]] <- httr::content(httr::GET(url), as = "text")
    crdate[[i]] <- strsplit(crdate[[i]], "\n")[[1]][-2]
    print(i)
    print(length(crdate[[i]]))
}
crdate <- do.call(c, crdate)
crdate <- crdate[-1]

length(crdate) == nrow(sanitationComplaints)

crdate <- as.IDate(crdate, "%m/%d/%Y")
sanitationComplaints$Creation_Date <- crdate


# orig <- readRDS("DATA - Copy/sanitation_code.Rds")
# str(orig)
# str(sanitationComplaints)

## SAVE ANSWER
saveRDS(sanitationComplaints , "DATA/sanitation_code.Rds")

