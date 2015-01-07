
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
business <- readRDS("DATA/bus_license.Rds")
crime <-  readRDS("DATA/crime.Rds")
foodInspect <- readRDS("DATA/food_inspections.Rds")
garbageCarts <- readRDS("DATA/garbage_carts.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code.Rds")

inspectors <- readRDS("DATA/inspectors.Rds")

weather <- readRDS("DATA/weather_20110401_20141031.Rds")
weather_3day <- weather_3day_calc(weather)
rm(weather)

business <- filter_business(business)
crime <- filter_crime(crime)
foodInspect <- filter_foodInspect(foodInspect)
garbageCarts <- filter_garbageCarts(garbageCarts)
sanitationComplaints <- filter_sanitationComplaints(sanitationComplaints)


##==============================================================================
## Create basis for model to be used in model
##==============================================================================
dat_model <- foodInspect[i = TRUE , 
                         j = list(Inspection_Date, 
                                  License), 
                         keyby = Inspection_ID]

##==============================================================================
## CALCULATE FEATURES BASED ON FOOD INSPECTION DATA
##==============================================================================

## Calculate violation matrix and put into data.table with inspection id as key
## calculate_violation_types calculates violations by categories:
##       Critical, serious, and minor violations
violation_dat <- data.table(Inspection_ID = foodInspect$Inspection_ID, 
                            calculate_violation_types(foodInspect$Violations), 
                            key = "Inspection_ID")
dat_model <- dat_model[violation_dat]

## For clarity, remove violations from food inspection
foodInspect$Violations <- NULL


## Merge in "results" for pass / fail flag
dat_model <- merge(dat_model[ , .SD, keyby=Inspection_ID],
                   foodInspect[ , Results, keyby=Inspection_ID])
## Set key to ensure that records are treated CHRONOLOGICALLY
setkey(dat_model, License, Inspection_Date)
dat_model[ , pass_flag := ifelse(Results=="Pass",1, 0)]
dat_model[ , fail_flag := ifelse(Results=="Fail",1, 0)]
dat_model[ , pastFail := geneorama::shift(fail_flag, -1, 0), by = License]
dat_model[ , pastCritical := geneorama::shift(criticalCount, -1, 0), by = License]
dat_model[ , pastSerious := geneorama::shift(seriousCount, -1, 0), by = License]
dat_model[ , pastMinor := geneorama::shift(minorCount, -1, 0), by = License]
## Remove "result" column now that we're done with it
dat_model[ , Results := NULL]

## Calcualte time since last inspection.
## If the time is NA, this means it's the first inspection; add an inicator 
## variable to indicate that it's the first inspection.
dat_model[i = TRUE , 
          j = timeSinceLast := as.numeric(
              Inspection_Date - geneorama::shift(Inspection_Date, -1, NA)) / 365, 
          by = License]
dat_model[ , firstRecord := 0]
dat_model[is.na(timeSinceLast), firstRecord := 1]
dat_model[is.na(timeSinceLast), timeSinceLast := 2]
dat_model[ , timeSinceLast := pmin(timeSinceLast, 2)]

##==============================================================================
## CALCULATE FEATURES BASED ON BUSINESS LICENSE DATA
##==============================================================================

## Create a table of matches between the food inspection and business license
## data, based on the where the Inspection_Date falls within the business
## license renewal
id_table_food2business <- find_bus_id_matches(business, foodInspect)



if(FALSE){
    str(dat)
    
    ## Luckily the restaurants with missing business data mostly appear to have
    ## lower counts of critical and serious violations
    geneorama::NAsummary(dat_minmaxdates)
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



