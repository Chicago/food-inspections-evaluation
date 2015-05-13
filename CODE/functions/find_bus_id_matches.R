
##
## Match food inspection ids to business license ids
## based on when the inspection happened in relationship
## to the business license renewal cycle.
##

find_bus_id_matches <- function(business, foodInspect) {
    
    ## Merge over time periods
    dat <- foverlaps(foodInspect[i = TRUE,
                                 j = Inspection_ID,
                                 keyby = list(License, 
                                              Inspection_Date = Inspection_Date, 
                                              Inspection_Date_end = Inspection_Date)], 
                     business[i = LICENSE_TERM_START_DATE < LICENSE_TERM_EXPIRATION_DATE, 
                              j = list(Business_ID = ID),
                              keyby = list(LICENSE_NUMBER, 
                                           LICENSE_TERM_START_DATE, 
                                           LICENSE_TERM_EXPIRATION_DATE)], 
                     mult = "first", 
                     type = "any", 
                     nomatch = NA)
    return(dat[ , list(Inspection_ID, Business_ID)])
}
