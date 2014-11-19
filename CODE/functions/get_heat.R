#function needed to work on a batch of rows
get_heat <- function(rows, dat, dateColumn, day_window) {
  mapply(
    FUN = heat, 
    date = foodInspect[rows,"inspection_date"],
    lat = foodInspect[rows,"latitude"],
    long = foodInspect[rows,"longitude"],
    MoreArgs = list(data = dat, dateColumnName = dateColumn, days = day_window),
    SIMPLIFY=TRUE
  )
}
