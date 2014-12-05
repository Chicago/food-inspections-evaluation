#filter to events within a date, and get heat
heat <- function(date,lat,long, data, dateColumnName, days){
  out <- tryCatch({
    biz <- data[data[,dateColumnName]>(date - days*60*60*24) &
                  data[,dateColumnName]<date,]
    kde(
      new=c(lat,long),
      x = biz$latitude, 
      y = biz$longitude, 
      h = c(0.01, 0.01)
    )},
    error = function(cond) return(0)
  )
  return(out)
}
