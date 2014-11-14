##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Check for dependencies
if(!"geneorama" %in% rownames(installed.packages())){
    if(!"devtools" %in% rownames(installed.packages())){install.packages('devtools')}
    devtools::install_github('geneorama/geneorama')}
## Load libraries
geneorama::detach_nonstandard_packages()
# geneorama::loadinstall_libraries(c("geneorama", "data.table"))
geneorama::loadinstall_libraries(c("data.table"))
geneorama::sourceDir("functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
business <- readRDS("DATA/bus_license.Rds")
crime <-  readRDS("DATA/crime.Rds")
foodInspect <- readRDS("DATA/food_inspections.Rds")
garbageCarts <- readRDS("DATA/garbage_carts.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code.Rds")


##==============================================================================
## LOAD PREVIOUS DATA
##==============================================================================
load("DATA/recreated_training_data_20141103v02.Rdata")
prev <- as.data.table(rbind(train,tune,evaluate))
rm(train,tune,evaluate)
prev[ , inspection_id := as.integer(inspection_id)]
prev[duplicated(inspection_id)]
prev <- prev[!duplicated(inspection_id)]

##==============================================================================
## BUSINESS
##==============================================================================
str(business)
business[ , .N, LICENSE_STATUS]
business[ , .N, APPLICATION_TYPE]
business[ , .N, is.na(LICENSE_TERM_START_DATE)]
business[ , .N, is.na(LICENSE_TERM_EXPIRATION_DATE)]

##==============================================================================
## CRIME
##==============================================================================
crime[ , .N, Primary_Type][order(-N)]
lvls <- crime[ , .N, Primary_Type][order(-N), Primary_Type]
crime[ , Primary_Type := factor(x = Primary_Type, levels = lvls)]
rm(lvls)


##==============================================================================
## FOOD INSPECTIONS
##==============================================================================
str(foodInspect)
foodInspect[,.N,Inspection_Type]


##==============================================================================
## Checking "CARNICERIA LA GLORIA NO. 2" for the pastFail field
##==============================================================================
foodInspect[grep("CARNICERIA LA GLORIA NO. 2", DBA_Name)]
foodInspect[Inspection_ID==509323]
foodInspect[License==1514813][order(Inspection_Date)]


# The first inspection shows pastFail == 1?
prev[inspection_id==509323]
prev[grep("CARNICERIA LA GLORIA NO. 2", doing_business_as_name)]
prev[license_==1514813][order(inspection_date)]
prev[license_==1514813,
     list(license_, doing_business_as_name,pastFail),
     keyby=inspection_date]

## Checking merge
setkey(foodInspect, Inspection_ID)
setkey(prev, inspection_id)
foodInspect[prev]

## Intersection between License and Address:
foodInspect[,.N,list(Address, License)][,.N,License]
foodInspect[,.N,list(Address, License)][,.N,License][order(-N)]

## Places with more than one address per license:
foodInspect[License==1932251]
foodInspect[License==1932]
foodInspect[License==1354323]


foodInspect[,.N,list(Address, License)][,.N,Address]
foodInspect[grep("3101 N BROADWAY", Address)]
foodInspect[,.N,list(Address, License)][,.N,Address][order(N)]
foodInspect[grep("11601 W TOUHY AVE", Address)]
foodInspect[grep("500 W MADISON", Address)]

##==============================================================================
## Checking individual licenses that are in both prev and current
##==============================================================================

## table of licenses that are common between prev and current food insp
foodInspect[prev][,.N,License][!is.na(License)][order(N)]

## ----CARLOS FUENTES CHARTER SCHOOL UNO CHARTER SCHOOL  / SUBWAY---------------
foodInspect[License==18236][order(Inspection_Date)]
prev[license_==18236][order(inspection_date)]
prev[grep("6555 N CLARK", address)]
prev[grep("2845 W BARRY ST", address)]
foodInspect[grep("6555 N CLARK", Address)]
foodInspect[grep("2845 W BARRY ST", Address)]
## ----Edwards / STARBUCKS COFFEE #2223 ----------------------------------------
foodInspect[License==23081][order(Inspection_Date)]
prev[license_==23081][order(inspection_date)]
## ----GILHOOLEY'S GRANDE SALOON 
foodInspect[License==1493893][order(Inspection_Date)]
dat[License==1493893][order(Inspection_Date)]
prev[license_==1493893][order(inspection_date)]
## ----LITTLE QUIAPO RESTAURANT ------------------------------------------------
foodInspect[License==1740130][order(Inspection_Date)]
prev[license_==1740130][order(inspection_date)]
## ----CARNICERIA LA GLORIA NO. 2 ----------------------------------------------
# The first inspection shows pastFail == 1?
prev[inspection_id==509323]
prev[grep("CARNICERIA LA GLORIA NO. 2", doing_business_as_name)]
prev[license_==1514813][order(inspection_date)]
prev[license_==1514813,
     list(license_, doing_business_as_name,pastFail),
     keyby=inspection_date]
foodInspect[License==1514813][order(Inspection_Date)]





