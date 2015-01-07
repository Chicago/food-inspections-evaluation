filter_business <- function(business){
    business <- business[!is.na(LICENSE_TERM_START_DATE)]
    business <- business[!is.na(LICENSE_TERM_EXPIRATION_DATE)]
    business <- business[!(APPLICATION_TYPE %in% c("C_CAPA","C_SBA"))]
    business
}
