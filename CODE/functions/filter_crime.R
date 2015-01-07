filter_crime <- function(crime){
    crime <- crime[Date>as.IDate('2011-07-01')]
    crime <- crime[!(is.na(Latitude) | is.na(Longitude) | is.na(Date))]
    crime
}
