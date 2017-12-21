
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
geneorama::loadinstall_libraries(c("data.table", "MASS"))
geneorama::sourceDir("CODE/functions/")
## Import shift function
shift <- geneorama::shift

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
foodInspect <- readRDS("DATA/13_food_inspections.Rds")

## Apply row filter to remove invalid data
foodInspect <- filter_foodInspect(foodInspect)

## Remove violations from food inspection, violations are caputured in the 
## violation matrix data
foodInspect$Violations <- NULL

## Import violation matrix which lists violations by categories:
##       Critical, serious, and minor violations
violation_dat <- readRDS("DATA/21_food_inspection_violation_matrix.Rds")

##==============================================================================
## CALCULATE FEATURES
##==============================================================================

## Facility_Type_Clean: Anything that is not "restaurant" or "grocery" is "other"
foodInspect[ , Facility_Type_Clean := 
                 categorize(x = Facility_Type,
                            primary = list(Restaurant = "restaurant",
                                           Grocery_Store = "grocery"),
                            ignore.case = TRUE)]
## Join in the violation matrix
foodInspect <- merge(x = foodInspect, 
                     y = violation_dat, 
                     by = "Inspection_ID")
## Create pass / fail flags
foodInspect[ , pass_flag := ifelse(Results=="Pass",1, 0)]
foodInspect[ , fail_flag := ifelse(Results=="Fail",1, 0)]
## Set key to ensure that records are treated CHRONOLOGICALLY...
setkey(foodInspect, License, Inspection_Date)
## Then find previous info by "shifting" the columns (grouped by License)
foodInspect[ , pastFail := shift(fail_flag, -1, 0), by = License]
foodInspect[ , pastCritical := shift(criticalCount, -1, 0), by = License]
foodInspect[ , pastSerious := shift(seriousCount, -1, 0), by = License]
foodInspect[ , pastMinor := shift(minorCount, -1, 0), by = License]

## Calcualte time since last inspection.
## If the time is NA, this means it's the first inspection; add an inicator 
## variable to indicate that it's the first inspection.
foodInspect[i = TRUE , 
            j = timeSinceLast := as.numeric(
                Inspection_Date - shift(Inspection_Date, -1, NA)) / 365, 
            by = License]
foodInspect[ , firstRecord := 0]
foodInspect[is.na(timeSinceLast), firstRecord := 1]
foodInspect[is.na(timeSinceLast), timeSinceLast := 2]
foodInspect[ , timeSinceLast := pmin(timeSinceLast, 2)]

##==============================================================================
## SAVE RDS
##==============================================================================
setkey(foodInspect, Inspection_ID)
saveRDS(foodInspect, file.path("DATA/23_food_insp_features.Rds"))



