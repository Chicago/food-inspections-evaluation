filter_business <- function(business){
    ## Remove rows with na values
    business <- business[!is.na(LICENSE_TERM_START_DATE)]
    business <- business[!is.na(LICENSE_TERM_EXPIRATION_DATE)]
    ## Keep only certain application types
    business <- business[!(APPLICATION_TYPE %in% c("C_CAPA","C_SBA"))]
    ## Remove duplicate ids
    business <- business[!duplicated(ID)]
    ## Return results
    return(business)
}
