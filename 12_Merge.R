
stop()

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
business <- readRDS("data/bus_license_filtered.Rds")
crime <-  readRDS("data/crime_filtered.Rds")
foodInspect <- readRDS("data/food_inspections_filtered.Rds")
garbageCarts <- readRDS("data/garbage_carts_filtered.Rds")
sanitationComplaints <- readRDS("data/sanitation_code_filtered.Rds")

##==============================================================================
## FOOD INSPECTIONS
##==============================================================================
#omit records with a missing inspection date

## Tabluate voilation types
## 1) Split violoation description by "|"
## 2) use regex to extract leading digits of code number
## 3) create indicator matrix of code violations
## 4) use apply to total up each group of code violations
vio <- strsplit(foodInspect$Violations,"| ",fixed=T)
vio_nums <- lapply(vio, 
                   function(item) regmatches(x = item, 
                                             m = gregexpr(pattern = "^[0-9]+", 
                                                          text = item)))
vio_mat <- geneorama::list2matrix(vio_nums, count = T)
vio_mat <- vio_mat[ , order(as.numeric(colnames(vio_mat)))]
colnames(vio_mat)
range(vio_mat)

foodInspect$criticalCount <- apply(vio_mat[ , colnames(vio_mat) %in% 1:14], 1, sum)
foodInspect$seriousCount <- apply(vio_mat[ , colnames(vio_mat) %in% 15:29], 1, sum)
foodInspect$minorCount <- apply(vio_mat[ , colnames(vio_mat) %in% 30:44], 1, sum)

foodInspect$Violations <- NULL
rm(vio, vio_nums, vio_mat)

## Set key to ensure that records are treated CHRONOLOGICALLY
setkey(foodInspect, License, Inspection_Date)
foodInspect[ , pass_flag := ifelse(Results=="Pass",1, 0)]
foodInspect[ , fail_flag := ifelse(Results=="Fail",1, 0)]
foodInspect[ , pastFail := geneorama::shift(fail_flag, -1, 0), by = License]
foodInspect[ , pastCritical := geneorama::shift(criticalCount, -1, 0), by = License]
foodInspect[ , pastSerious := geneorama::shift(seriousCount, -1, 0), by = License]
foodInspect[ , pastMinor := geneorama::shift(minorCount, -1, 0), by = License]


## Calcualte time since last inspection.
## If the time is NA, this means it's the first inspection; add an inicator 
## variable to indicate that it's the first inspection.
foodInspect[i = TRUE , 
            j = timeSinceLast := as.numeric(
                Inspection_Date - geneorama::shift(Inspection_Date, -1, NA)) / 365, 
            by = License]
foodInspect[ , firstRecord := 0]
foodInspect[is.na(timeSinceLast), firstRecord := 1]
foodInspect[is.na(timeSinceLast), timeSinceLast := 2]
# hist(foodInspect$timeSinceLast)
# foodInspect[, timeSinceLast := pmin(timeSinceLast, 2)]
# hist(foodInspect$timeSinceLast)

# foodInspect[License==40]
# foodInspect[License==62]
# foodInspect[License==104]

##==============================================================================
## ATTACH BUSINESS LICENSE DATA
##==============================================================================

business[ , WP :=paste("w",WARD,"p",PRECINCT,sep="_")]


## Matching food licenses in business:
# inin(foodInspect$License, business$LICENSE_NUMBER)
# table(unique(foodInspect$License) %in% business$LICENSE_NUMBER)
# found <- unique(foodInspect$License)[unique(foodInspect$License) %in% business$LICENSE_NUMBER]
# notfound <- unique(foodInspect$License)[!unique(foodInspect$License) %in% business$LICENSE_NUMBER]
# set.seed(1);clipper(sample(found)[1:10])
# set.seed(1);clipper(sample(notfound)[1:10])
# rm(found, notfound)


# load("DATA_ORIGINAL/original_training_data_20140129v01.Rdata")
# inin(train$license_, found)
# inin(train$license_, notfound)
# train[train$license_==notfound[1]]

# train[grep("104", train$license_),]
# train[train$license_=="104",]

# range(foodInspect$Inspection_Date)
# range(business$DATE_ISSUED)
# range(business$APPLICATION_CREATED_DATE, na.rm=T)
# range(business$DATE_ISSUED, na.rm=T)
# range(business$LICENSE_STATUS_CHANGE_DATE, na.rm=T)

business[,.N,LICENSE_NUMBER]
foodInspect[License=="349"]
business[LICENSE_NUMBER=="349"]
foodInspect[License=="1593938"]
business[LICENSE_NUMBER=="1593938"]
foodInspect[License=="1892716"]
business[LICENSE_NUMBER=="1892716"]
foodInspect[License=="18236"]
business[LICENSE_NUMBER=="18236"]

bus <- business[LICENSE_TERM_START_DATE < LICENSE_TERM_EXPIRATION_DATE, LICENSE_NUMBER]
fd <- foodInspect[,License] 
length(unique(bus))
geneorama::inin(bus, fd)

## Merge over time periods
dat <- foverlaps(foodInspect[i = TRUE,
                             j = .SD,
                             keyby = list(License, 
                                          Inspection_Date = Inspection_Date, 
                                          Inspection_Date_end = Inspection_Date)], 
                 business[i = LICENSE_TERM_START_DATE < LICENSE_TERM_EXPIRATION_DATE, 
                          j = .SD,
                          keyby = list(LICENSE_NUMBER, 
                                       LICENSE_TERM_START_DATE, 
                                       LICENSE_TERM_EXPIRATION_DATE)], 
                 mult="first", 
                 type="any", nomatch=NA)
str(dat)

dat[,table(is.na(ID))]

business[,list(minDate=min(DATE_ISSUED),
               maxDate=max(LICENSE_TERM_EXPIRATION_DATE),
               payment_date=min(PAYMENT_DATE),
               license_start_date=min(LICENSE_TERM_START_DATE))]

business[,list(SSA), list(License=LICENSE_NUMBER), mult="first"]
business[,.N, list(License=LICENSE_NUMBER, SSA)]

NAsummary(business)
nrow(foodInspect)
temp <- merge(foodInspect, all.y=F,
              business[,list(.N), list(License=LICENSE_NUMBER, SSA)], 
              by="License")
nrow(temp)
nrow(foodInspect)
nrow(business)

merge(foodInspect, business[,list(SSA, License=LICENSE_ID)], by="License")
merge(foodInspect, 
      business[,list(SSA), keyby=list(License=LICENSE_ID)], 
      by="License")






