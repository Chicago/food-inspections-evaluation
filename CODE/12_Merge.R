
stop()  ## This stop is to prevent *accidental* execution of the entire script

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
geneorama::loadinstall_libraries(c("data.table", "MASS"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
business <- readRDS("DATA/bus_license_filtered.Rds")
crime <-  readRDS("DATA/crime_filtered.Rds")
foodInspect <- readRDS("DATA/food_inspections_filtered.Rds")
garbageCarts <- readRDS("DATA/garbage_carts_filtered.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code_filtered.Rds")

inspectors <- readRDS(inspectors, "DATA/inspectors.Rds")

weather <- readRDS("DATA/weather_20110401_20141031.Rds")
weather_3day <- weather_3day_calc(weather)
rm(weather)


## FIX FOOD INSPECTIONS LATITUDE
## (THIS SHOULD HAPPEN IN THE 10 IMPORT STEP)
foodInspect[ , Latitude := as.numeric(Latitude)]
## FIX SANITATION LATITUDE
## (THIS SHOULD HAPPEN IN THE 10 IMPORT STEP)
sanitationComplaints[ , Latitude := as.numeric(Latitude)]
## FIX GARBAGE CART LATITUDE
## (THIS SHOULD HAPPEN IN THE 10 IMPORT STEP)
garbageCarts[ , Latitude := as.numeric(Latitude)]

##==============================================================================
## FOOD INSPECTIONS
##==============================================================================

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
# colnames(vio_mat)
# range(vio_mat)

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


business[ , minDate := min(LICENSE_TERM_START_DATE), LICENSE_NUMBER]
business[ , maxDate := max(LICENSE_TERM_EXPIRATION_DATE), LICENSE_NUMBER]

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

if(FALSE){
    str(dat)
    
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
dat[ , Inspection_Date_end := NULL]
dat <- dat[LICENSE_DESCRIPTION == "Retail Food Establishment"]

## Calculate age at inspection
dat[,ageAtInspection := as.numeric(Inspection_Date - minDate) / 365]

## CALCULATE AND MERGE IN OTHER CATEGORIES
OtherCategories <- GenerateOtherLicenseInfo(dat, business, max_cat = 12)
setkey(OtherCategories, Inspection_ID)
setkey(dat, Inspection_ID)
dat <- merge(dat, OtherCategories, all.x = T)
# dat

## Remove NAs in category columns and set max value to 1
for (j in match(colnames(OtherCategories)[-1], colnames(dat))) {
    set(x = dat, i = which(is.na(dat[[j]])), j = j, value = 0)
    set(x = dat, j = j, value = pmin(dat[[j]], 1))
}


##==============================================================================
## ATTACH CRIME DATA
##==============================================================================

WINDOW <- 90
N <- nrow(dat)
PAGE <- 500
II <- mapply(`:`, seq(1,N,PAGE), c(seq(1,N,PAGE)[-1]-1,N))

heat_burglary <- rbindlist(lapply(II, function(ii) {
    print(paste(sys.call()[2], "out of", length(II)))
    foverlaps(    
        x = dat[i = ii, 
                j = list(Inspection_ID, 
                         Latitude, 
                         Longitude), 
                keyby = list(start = Inspection_Date - WINDOW, 
                             end = Inspection_Date)],
        y = crime[i = TRUE, 
                  j = list(Latitude, Longitude),
                  keyby = list(start = Date,  end = Date)],
        type = "any")[ , kde(new=c(i.Latitude[1], i.Longitude[1]), 
                             x = Latitude, 
                             y = Longitude, 
                             h = c(.01, .01)),
                      keyby = Inspection_ID]}))

heat_sanitation <- rbindlist(lapply(II, function(ii) {
    print(paste(sys.call()[2], "out of", length(II)))
    foverlaps(    
        x = dat[i = ii, 
                j = list(Inspection_ID, 
                         Latitude, 
                         Longitude), 
                keyby = list(start = Inspection_Date - WINDOW, 
                             end = Inspection_Date)],
        y = sanitationComplaints[i = TRUE, 
                                 j = list(Latitude, Longitude),
                                 keyby = list(start = Creation_Date,  end = Creation_Date)],
        type = "any")[ , kde(new=c(i.Latitude[1], i.Longitude[1]), 
                             x = Latitude, 
                             y = Longitude, 
                             h = c(.01, .01)),
                      keyby = Inspection_ID]}))

heat_garbage <- rbindlist(lapply(II, function(ii) {
    print(paste(sys.call()[2], "out of", length(II)))
    foverlaps(    
        x = dat[i = ii, 
                j = list(Inspection_ID, 
                         Latitude, 
                         Longitude), 
                keyby = list(start = Inspection_Date - WINDOW, 
                             end = Inspection_Date)],
        y = garbageCarts[i = TRUE, 
                         j = list(Latitude, Longitude),
                         keyby = list(start = Creation_Date,  end = Creation_Date)],
        type = "any")[ , kde(new=c(i.Latitude[1], i.Longitude[1]), 
                             x = Latitude, 
                             y = Longitude, 
                             h = c(.01, .01)),
                      keyby = Inspection_ID]}))

## Merge in results of heat calculations:
setnames(heat_burglary, "V1", "heat_burglary")
setnames(heat_garbage, "V1", "heat_garbage")
setnames(heat_sanitation, "V1", "heat_sanitation")
setkey(dat, Inspection_ID)
setkey(heat_burglary, Inspection_ID)
setkey(heat_garbage, Inspection_ID)
setkey(heat_sanitation, Inspection_ID)
dat <- dat[heat_burglary][heat_garbage][heat_sanitation]
rm(heat_burglary, heat_garbage, heat_sanitation)

##==============================================================================
## ATTACH INSPECTOR DATA
##==============================================================================
## Removing letters out front, and numbers trailing hyphen are not needed 
## (e.g. -1006 I believe is the code for retail food license)
inspectors[ , License := gsub('[A-z]+|-.+$', "", License)]
## cleaning any leading zeros
inspectors[ , License := gsub('^[0]+', "", License)]
## removing possibly invalid license numbers
inspectors <- inspectors[nchar(License) > 3 & Inspector_Assigned != " "]
## if multiple inspections for same license number, then seeking the inspector 
## on the first inspection
inspectors <- inspectors[ , .N, by=list(License, Inspection_Date, Inspector_Assigned)]
inspectors$N <- NULL
## Convert to integer to match 
inspectors[ , License := as.integer(License)]
setkey(inspectors, License, Inspection_Date)
setkey(dat, License, Inspection_Date)


dat_w_inspector <- merge(
    x = dat,
    y = inspectors,
    by = c("License","Inspection_Date"),
    all.x = FALSE,
    all.y = FALSE)
# dim(dat_w_inspector)

##==============================================================================
## MERGE IN WEATHER
##==============================================================================
dat <- merge(dat, weather_3day, by="Inspection_Date")

##==============================================================================
## SAVE RDS
##==============================================================================
# dat_w_inspector
saveRDS(dat_w_inspector, file.path(DataDir, "dat_with_inspector.Rds"))



