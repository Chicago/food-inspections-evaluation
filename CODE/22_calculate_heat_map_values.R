##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)

## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table", "MASS"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================

## Import the key data sets used for prediction
foodInspect <- readRDS("DATA/13_food_inspections.Rds")
crime <-  readRDS("DATA/12_crime.Rds")
garbageCarts <- readRDS("DATA/14_garbage_carts.Rds")
sanitationComplaints <- readRDS("DATA/15_sanitation_code.Rds")

## Apply filters by omitting rows that are not used in the model
foodInspect <- filter_foodInspect(foodInspect)
crime <- filter_crime(crime)
garbageCarts <- filter_garbageCarts(garbageCarts)
sanitationComplaints <- filter_sanitationComplaints(sanitationComplaints)

##==============================================================================
## CALCULATE HEAT MAP VALUES
##==============================================================================
burglary_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = crime,
                          window = 90, 
                          page_limit = 500)
garbageCarts_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = garbageCarts[
                              i = TRUE,
                              j = list(Date = Creation_Date,
                                       Latitude,
                                       Longitude)],
                          window = 90, 
                          page_limit = 500)
sanitationComplaints_heat <- 
    calculate_heat_values(inspections = foodInspect, 
                          observed_values = sanitationComplaints[
                              i = TRUE,
                              j = list(Date = Creation_Date,
                                       Latitude,
                                       Longitude)],
                          window = 90, 
                          page_limit = 500)

##==============================================================================
## SAVE HEAT MAP VALUES
##==============================================================================
saveRDS(burglary_heat, "DATA/22_burglary_heat.Rds")
saveRDS(garbageCarts_heat, "DATA/22_garbageCarts_heat.Rds")
saveRDS(sanitationComplaints_heat, "DATA/22_sanitationComplaints_heat.Rds")


