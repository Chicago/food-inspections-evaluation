##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)

## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table", "MASS"))
geneorama::sourceDir("CODE/functions/")
## Import shift function
shift <- geneorama::shift

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
business <- readRDS("DATA/11_bus_license.Rds")

## Apply filter to remove invalid / unused data
business <- filter_business(business)

## Food inspection data needed for some feature calculations inspection date
foodInspect <- readRDS("DATA/23_food_insp_features.Rds")

##==============================================================================
## CALCULATE FEATURES BASED ON BUSINESS LICENSE DATA
##==============================================================================

## Calculate min date (by license)
business[ , minDate := min(LICENSE_TERM_START_DATE), LICENSE_NUMBER]
business[ , maxDate := max(LICENSE_TERM_EXPIRATION_DATE), LICENSE_NUMBER]

##==============================================================================
## Use only the business data that pertains to food inspections
##==============================================================================
## Create a table of matches between the food inspection and business license
## data, based on the where the Inspection_Date falls within the business
## license renewal
id_table_food2business <- find_bus_id_matches(business, foodInspect)
geneorama::NAsummary(id_table_food2business)

## Add food key to matched business data
bus_matched <- merge(x = id_table_food2business, 
                     y = business, 
                     by = "ID", 
                     all.y = FALSE, 
                     all.x = TRUE)
setkey(bus_matched, Inspection_ID)

## Add business key to food data
foodInspect <- merge(x = id_table_food2business, 
                     y = foodInspect, 
                     by = "Inspection_ID")
setkey(foodInspect, Inspection_ID)

## Use minDate and Inspection date to calculate age at 
bus_matched <- bus_matched[foodInspect[,Inspection_Date,keyby=Inspection_ID]]
bus_matched[ , ageAtInspection := as.numeric(Inspection_Date - minDate) / 365]

## Remove Inspection Date to avoid conflict names when merging later
bus_matched[ , Inspection_Date := NULL]


## CALCULATE AND MERGE IN OTHER CATEGORIES
OtherCategories <- GenerateOtherLicenseInfo(foodInspect, business,  max_cat = 12)
geneorama::NAsummary(OtherCategories)

## Merge in results
bus_matched <- merge(x = bus_matched, 
                     y = OtherCategories, 
                     by = "Inspection_ID",
                     all.x = T)
## Remove NAs in category columns and set max value to 1
for (j in match(colnames(OtherCategories)[-1], colnames(bus_matched))) {
    set(x = bus_matched, i = which(is.na(bus_matched[[j]])), j = j, value = 0)
    set(x = bus_matched, j = j, value = pmin(bus_matched[[j]], 1))
}

bus_matched

##==============================================================================
## SAVE RDS
##==============================================================================
## Set the key for dat_model
setkey(bus_matched, Inspection_ID)
saveRDS(bus_matched, file.path("DATA/24_bus_features.Rds"))

