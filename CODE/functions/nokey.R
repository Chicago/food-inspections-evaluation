
nokey <- function(dt, usestrings){
  require(data.table)
  
  if(!inherits(x = dt, what = "data.table")){
    stop("dt should be a data.table")
  }
  
  if(haskey(dt)){
    ret <- dt[, .SD, .SDcol = -key(dt)]
  } else {
    ret <- dt
  }
  return(ret)
}

