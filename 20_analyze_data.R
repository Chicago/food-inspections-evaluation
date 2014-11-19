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

hist(foodInspect$timeSinceLast)

foodInspect[License==40]
foodInspect[License==62]
foodInspect[License==104]


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
setkey(foodInspect, Inspection_ID)
setkey(prev, inspection_id)
foodInspect[prev][,.N,list(License, Facility_Type)][!is.na(License)][order(N)]
foodInspect[prev][,.N,list(license_, Facility_Type)][!is.na(license_)][order(N)]
prev[foodInspect][,.N,list(License, Facility_Type)][!is.na(License)][order(N)]
prev[foodInspect][,.N,list(license_, Facility_Type)][!is.na(license_)][order(N)]

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

##==============================================================================
## Checking individual licenses that would have been duplicates for school
##==============================================================================
foodInspect[License==192013962][order(Inspection_Date)]
foodInspect[License>190000000][,.N,list(License, Facility_Type)]

foodInspect[License>190000000][,.N,list(License, Facility_Type)][order(N)]
lic_schools <- foodInspect[License>190000000, .N,License][,License]
temp <- foodInspect[License%in%c(lic_schools, lic_schools-1.9e8)]
temp[,.N,keyby=list(License, Facility_Type)]

foodInspect[License%in%(22181+c(0,1.9e8))][order(Inspection_Date)]
foodInspect[License%in%(22361+c(0,1.9e8))][order(Inspection_Date)]

foodInspect[License%in%(16394+c(0,1.9e8))][order(Inspection_Date)]

rm(temp)

##==============================================================================
## Checking business license merge 
##==============================================================================

business[,.N,LICENSE_NUMBER]

foodInspect[License=="349"]
business[LICENSE_NUMBER=="349"]
foodInspect[License=="1593938"]
business[LICENSE_NUMBER=="1593938"]
foodInspect[License=="1892716"]
business[LICENSE_NUMBER=="1892716"]
foodInspect[License=="18236"]
business[LICENSE_NUMBER=="18236"]


## Matching food licenses in business:
geneorama::inin(foodInspect$License, business$LICENSE_NUMBER)
table(unique(foodInspect$License) %in% business$LICENSE_NUMBER)
found <- unique(foodInspect$License)[unique(foodInspect$License) %in% business$LICENSE_NUMBER]
notfound <- unique(foodInspect$License)[!unique(foodInspect$License) %in% business$LICENSE_NUMBER]
set.seed(1);clipper(sample(found)[1:10])
set.seed(1);clipper(sample(notfound)[1:10])
rm(found, notfound)


bus <- business[LICENSE_TERM_START_DATE < LICENSE_TERM_EXPIRATION_DATE, 
                LICENSE_NUMBER]
fd <- foodInspect[,License] 
length(unique(bus))
geneorama::inin(bus, fd)
rm(bus, fd)


##==============================================================================
## LICENSE DESCRIPTIONS
##==============================================================================
dat[,.N, LICENSE_DESCRIPTION][order(-N)]
dat[,.N, LICENSE_DESCRIPTION][order(LICENSE_DESCRIPTION)]
business[,.N, LICENSE_DESCRIPTION][order(-N)]

business[,.N, LICENSE_DESCRIPTION][order(LICENSE_DESCRIPTION)][grep("fill|gas", LICENSE_DESCRIPTION, ignore.case=T)]
foodInspect[,.N, Facility_Type][order(Facility_Type)][grep("fill|gas", Facility_Type, ignore.case=T)]

business[,.N, LICENSE_DESCRIPTION][order(LICENSE_DESCRIPTION)]
business[,.N, LICENSE_DESCRIPTION][order(N)]
business[,.N, LICENSE_DESCRIPTION][order(-N)][1:15]
business[,.N, LICENSE_DESCRIPTION][order(-N)][1:100]
foodInspect[,.N, Facility_Type][order(-N)][1:100]



