
##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Detach libraries that are not used
geneorama::detach_nonstandard_packages()
## Load libraries that are used
geneorama::loadinstall_libraries(c("data.table", "MASS"))
## Load custom functions
geneorama::sourceDir("CODE/functions/")

## Import shift function
shift <- geneorama::shift

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================

## Import the key data sets used for prediction
foodInspect <- readRDS("DATA/food_inspections.Rds")
business <- readRDS("DATA/bus_license.Rds")

## For clarity, remove violations from food inspection
## This information is caputured in the violation matrix (below)
foodInspect$Violations <- NULL

## Import violation matrix which lists violations by categories:
##       Critical, serious, and minor violations
violation_dat <- readRDS("DATA/violation_dat.Rds")

## Import the inspectors
inspectors <- readRDS("DATA/inspectors.Rds")

## Import weather data
weather <- readRDS("DATA/weather_20110401_20141031.Rds")
weather_3day <- weather_3day_calc(weather)
rm(weather)

## Import the heat density values, previously calculated
burglary_heat <- readRDS("DATA/burglary_heat.Rds")
garbage_heat <- readRDS("DATA/garbageCarts_heat.Rds")
sanitation_heat <- readRDS("DATA/sanitationComplaints_heat.Rds")

##==============================================================================
## Filter the primary data sets to remove unnecessary rows
##==============================================================================
foodInspect <- filter_foodInspect(foodInspect)
business <- filter_business(business)

foodInspect[ , Facility_Type_Clean := 
                categorize(x = Facility_Type,
                           primary = list(Restaurant = "restaurant",
                                          Grocery_Store = "grocery"),
                           ignore.case = TRUE)]

##==============================================================================
## Create basis for dat_model, which is the data that will be used in the model
##==============================================================================
dat_model <- foodInspect[i = TRUE , 
                         j = list(Inspection_Date, 
                                  License,
                                  Inspection_Type,
                                  Results), 
                         keyby = Inspection_ID]

##==============================================================================
## CALCULATE FEATURES BASED ON FOOD INSPECTION DATA
##==============================================================================

## Join in the violation matrix
dat_model <- merge(x = dat_model, 
                   y = violation_dat, 
                   by = "Inspection_ID")

## Join in the clean facility type
dat_model <- merge(
    x = dat_model, 
    y = foodInspect[ , list(Inspection_ID, 
                            Facility_Type = Facility_Type_Clean)],
    by = "Inspection_ID")

## Create pass / fail flags
dat_model[ , pass_flag := ifelse(Results=="Pass",1, 0)]
dat_model[ , fail_flag := ifelse(Results=="Fail",1, 0)]
## Set key to ensure that records are treated CHRONOLOGICALLY...
setkey(dat_model, License, Inspection_Date)
## Then find previous info by "shifting" the columns (grouped by License)
dat_model[ , pastFail := shift(fail_flag, -1, 0), by = License]
dat_model[ , pastCritical := shift(criticalCount, -1, 0), by = License]
dat_model[ , pastSerious := shift(seriousCount, -1, 0), by = License]
dat_model[ , pastMinor := shift(minorCount, -1, 0), by = License]

## Calcualte time since last inspection.
## If the time is NA, this means it's the first inspection; add an inicator 
## variable to indicate that it's the first inspection.
dat_model[i = TRUE , 
          j = timeSinceLast := as.numeric(
              Inspection_Date - shift(Inspection_Date, -1, NA)) / 365, 
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

## Join business ID to dat_model
dat_model <- merge(x = dat_model, 
                   y = id_table_food2business, 
                   by = "Inspection_ID")

## Add LICENSE_DESCRIPTION to dat_model
license_dec <- business[i = TRUE, 
                        j = LICENSE_DESCRIPTION, 
                        keyby = list(Business_ID = ID)]
dat_model <- merge(dat_model, 
                   license_dec, 
                   by = "Business_ID",
                   all.x = TRUE)

## Calculate min date (by license)
business[ , minDate := min(LICENSE_TERM_START_DATE), LICENSE_NUMBER]
business[ , maxDate := max(LICENSE_TERM_EXPIRATION_DATE), LICENSE_NUMBER]

## Calculate age at inspection:
## Add minDate to dat_model
dat_model <- merge(x = dat_model, 
                   y = business[ , list(Business_ID = ID,
                                        minDate,
                                        maxDate)], # maxDate's just nice to have
                   by = "Business_ID",
                   all.x = TRUE)
## Use minDate to calculate age
dat_model[ , ageAtInspection := as.numeric(Inspection_Date - minDate) / 365]

## CALCULATE AND MERGE IN OTHER CATEGORIES
OtherCategories <- GenerateOtherLicenseInfo(dat_model, 
                                            business, 
                                            max_cat = 12)
## Merge in results
dat_model <- merge(x = dat_model, 
                   y = OtherCategories, 
                   by = "Inspection_ID",
                   all.x = T)
## Remove NAs in category columns and set max value to 1
for (j in match(colnames(OtherCategories)[-1], colnames(dat_model))) {
    set(x = dat_model, i = which(is.na(dat_model[[j]])), j = j, value = 0)
    set(x = dat_model, j = j, value = pmin(dat_model[[j]], 1))
}

##==============================================================================
## ATTACH "HEAT MAP" DATA
##==============================================================================

## Merge in results of heat calculations:
setnames(burglary_heat, "heat_values", "heat_burglary")
setnames(garbage_heat, "heat_values", "heat_garbage")
setnames(sanitation_heat, "heat_values", "heat_sanitation")

setkey(dat_model, Inspection_ID)
setkey(burglary_heat, Inspection_ID)
setkey(garbage_heat, Inspection_ID)
setkey(sanitation_heat, Inspection_ID)
dat_model <- dat_model[burglary_heat][garbage_heat][sanitation_heat]

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
setkey(dat_model, License, Inspection_Date)

inspectors_deduped <- inspectors[
    i = TRUE , 
    j = list(Inspector_Assigned = Inspector_Assigned[1]), 
    keyby = list(License, Inspection_Date)]
dat_model <- merge(
    x = dat_model,
    y = inspectors_deduped,
    by = c("License", "Inspection_Date"),
    all.x = TRUE)

##==============================================================================
## MERGE IN WEATHER
##==============================================================================
dat_model <- merge(dat_model, 
                   weather_3day, 
                   by = "Inspection_Date",
                   all.x = TRUE)

# geneorama::NAsummary(dat_model)
# str(na.omit(dat_model))
# dat_model[ , .N, LICENSE_DESCRIPTION]
# str(na.omit(dat_model[LICENSE_DESCRIPTION=="Retail Food Establishment"]))
# geneorama::NAsummary(dat_model[LICENSE_DESCRIPTION=="Retail Food Establishment"])

##==============================================================================
## SAVE RDS
##==============================================================================
## Set the key for dat_model
setkey(dat_model, Inspection_ID)
saveRDS(dat_model, file.path("DATA/dat_model.Rds"))



