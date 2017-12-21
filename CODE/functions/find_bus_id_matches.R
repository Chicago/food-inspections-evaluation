
##
## Match food inspection ids to business license ids
## based on when the inspection happened in relationship
## to the business license renewal cycle.
##

find_bus_id_matches <- function(business, foodInspect) {
    # browser()
    ## Since many food businesses are inspected before they are issued a 
    ## license,  so we need to move back the "License term start date" for 
    ## newly issued licenses.  An adjustment of 365 days seems pretty 
    ## reasonable, and creates lots of matches.
    ## Note also, the `as.integer` call.  This is needed to avoid a warning.
    business_copy <- copy(business)
    business_copy <- business_copy[APPLICATION_TYPE=="ISSUE",
                                   LICENSE_TERM_START_DATE := 
                                       as.integer(LICENSE_TERM_START_DATE - 365)]
    
    ## Merge over time periods
    dat <- foverlaps(foodInspect[i = TRUE,
                                 j = Inspection_ID,
                                 keyby = list(License, 
                                              Inspection_Date = Inspection_Date, 
                                              Inspection_Date_end = Inspection_Date)], 
                     business_copy[i = LICENSE_TERM_START_DATE < LICENSE_TERM_EXPIRATION_DATE, 
                                   j = list(ID),
                                   keyby = list(LICENSE_NUMBER, 
                                                LICENSE_TERM_START_DATE, 
                                                LICENSE_TERM_EXPIRATION_DATE)], 
                     mult = "first", 
                     type = "any", 
                     nomatch = NA)
    return(dat[ , list(Inspection_ID, ID)])
}
