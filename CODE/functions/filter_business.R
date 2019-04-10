filter_business <- function(business){
    
    ##==============================================================================
    ## Filter rows
    ##==============================================================================
    ## Remove rows with na values
    business <- business[!is.na(LICENSE_TERM_START_DATE)]
    business <- business[!is.na(LICENSE_TERM_EXPIRATION_DATE)]
    ## Keep only certain application types
    business <- business[!(APPLICATION_TYPE %in% c("C_CAPA","C_SBA"))]
    ## Remove duplicate ids
    business <- business[!duplicated(ID)]
    
    ##==============================================================================
    ## Remove columns that are never used
    ##==============================================================================
    business$SITE_NUMBER <- NULL
    business$APPLICATION_CREATED_DATE <- NULL
    business$APPLICATION_REQUIREMENTS_COMPLETE <- NULL
    business$PAYMENT_DATE <- NULL
    business$CONDITIONAL_APPROVAL <- NULL
    business$LICENSE_APPROVED_FOR_ISSUANCE <- NULL
    business$DATE_ISSUED <- NULL
    business$LICENSE_STATUS_CHANGE_DATE <- NULL
    business$SSA <- NULL
    business$LOCATION <- NULL
    
    ## Return results
    return(business)
}
