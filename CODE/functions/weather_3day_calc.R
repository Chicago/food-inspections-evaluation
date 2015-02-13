
weather_3day_calc <- function(weather){
    
    require(data.table)
    # str(weather)
    weather <- as.data.frame(weather)
    nr <- nrow(weather)
    weather <- weather[order(-as.numeric(weather$date)), ]
    threeDay <- weather[2:(nr-2), colnames(weather) != "date"] + 
        weather[3:(nr - 1), colnames(weather) != "date"] +
        weather[4:(nr - 0), colnames(weather) != "date"] 
    threeDay <- threeDay / 3
    threeDay$date <- weather$date[1:(nr-3)]
    
    threeDay <- as.data.table(threeDay)
    threeDay[ , date := as.IDate(date, format="%m/%d/%y")]
    setnames(threeDay, 'date', "Inspection_Date")
    
    threeDay <- threeDay[, .SD, keyby=Inspection_Date]
    
    return(threeDay)
}
