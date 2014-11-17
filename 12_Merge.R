
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
business <- readRDS("DATA/bus_license_filtered.Rds")
crime <-  readRDS("DATA/crime_filtered.Rds")
foodInspect <- readRDS("DATA/food_inspections_filtered.Rds")
garbageCarts <- readRDS("DATA/garbage_carts_filtered.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code_filtered.Rds")

##==============================================================================
## FOOD INSPECTIONS
##==============================================================================

## Add a 19 prefix to any License for "schools"
## The 19 works as a prefix because the max license is under 100m
## The 19 is symbolic of "s" for school
# range(foodInspect$License)
# range(foodInspect$License+1.9e8)
# foodInspect[,.N,list(Facility_Type)][order(N),Facility_Type]
# school_fields <- 
#     c("School", "COLLEGE", "ALTERNATIVE SCHOOL", "School Cafeteria",
#       "AFTER SCHOOL PROGRAM", "after school program", "UNIVERSITY CAFETERIA", 
#       "1023 CHILDERN'S SERVICE S FACILITY", "RESEARCH KITCHEN", 
#       "A-Not-For-Profit Chef Training Program", "COLLEGE", "SCHOOL", 
#       "daycare under 2 and daycare above 2", "CULINARY ARTS SCHOOL", 
#       "1023-CHILDREN'S SERVICES FACILITY", "Private School", 
#       "CITY OF CHICAGO COLLEGE", "BEFORE AND AFTER SCHOOL PROGRAM", 
#       "PASTRY school", "PUBLIC SHCOOL", "1023 CHILDERN'S SERVICES FACILITY", 
#       "DAYCARE", "Children's Services Facility", "Daycare (2 Years)", 
#       "Daycare (Under 2 Years)", "Daycare Above and Under 2 Years", 
#       "Daycare Combo 1586", "Daycare (2 - 6 Years)")
# foodInspect[Facility_Type %in% school_fields, License := License+1.9e8]

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
foodInspect[, timeSinceLast := pmin(timeSinceLast, 2)]

##==============================================================================
## ATTACH BUSINESS LICENSE DATA
##==============================================================================

business[ , WP :=paste("w",WARD,"p",PRECINCT,sep="_")]

# fid <- foodInspect[!License %in% business[,unique(LICENSE_NUMBER)], License] 
# business[fid-1.9e8, geneorama::inin(fid-1.9e8, LICENSE_NUMBER)]

business[,.N,LICENSE_DESCRIPTION][order(N)][,LICENSE_DESCRIPTION]

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
if(FALSE){
    ## Luckily the restaurants with missing business data mostly appear to have
    ## lower counts of critical and serious violations
    geneorama::NAsummary(dat)
    dat[,table(is.na(ID))]
    dat[i = TRUE,
        j = list(mean_critical = mean(criticalCount), sd_critical = sd(criticalCount),
                 mean_serious = mean(seriousCount), sd_serious = sd(seriousCount),
                 mean_minor = mean(minorCount), sd_minor = sd(minorCount)), 
        is.na(ID)]
}
dat <- dat[!is.na(ID)]
setkey(dat, License)

dat[,.N, LICENSE_DESCRIPTION]
business[,.N, LICENSE_DESCRIPTION]

geneorama::lll()




