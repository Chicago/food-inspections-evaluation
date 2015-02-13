##
## Because this step takes so long, it's pre-calculated here.
##

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

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
foodInspect <- readRDS("DATA/food_inspections.Rds")

##==============================================================================
## CALCULATE FEATURES BASED ON FOOD INSPECTION DATA
##==============================================================================

## Calculate violation matrix and put into data.table with inspection id as key
## calculate_violation_types calculates violations by categories:
##       Critical, serious, and minor violations
violation_dat <- calculate_violation_types(foodInspect$Violations,
                                           Inspection_ID = foodInspect$Inspection_ID)
saveRDS(violation_dat, "DATA/violation_dat.Rds")
