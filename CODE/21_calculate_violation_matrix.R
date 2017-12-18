##
## Because this step takes so long, it's pre-calculated here.
##

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

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
foodInspect <- readRDS("DATA/13_food_inspections.Rds")
foodInspect <- filter_foodInspect(foodInspect)

##==============================================================================
## CALCULATE FEATURES BASED ON FOOD INSPECTION DATA
##==============================================================================

## Calculate violation matrix and put into data.table with inspection id as key
vio_mat <- calculate_violation_matrix(foodInspect[ , Violations])

## Add key column to vio_mat
vio_mat <- data.table(vio_mat, 
                      Inspection_ID = foodInspect[ , Inspection_ID], 
                      key = "Inspection_ID")

## calculate_violation_types calculates violations by categories:
##       Critical, serious, and minor violations
violation_dat <- calculate_violation_types(violation_mat =vio_mat)

## Save results
saveRDS(vio_mat, "DATA/21_food_inspection_violation_matrix_nums.Rds")
saveRDS(violation_dat, "DATA/21_food_inspection_violation_matrix.Rds")
