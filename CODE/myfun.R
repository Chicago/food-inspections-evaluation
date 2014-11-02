


#function to get temperature on heat map at a new point
kde <- function (new, x, y, h) 
{
  nx <- length(x)
  if (length(y) != nx) 
    stop("data vectors must be the same length")
  if (any(!is.finite(x)) || any(!is.finite(y))) 
    stop("missing or infinite values in the data are not allowed")
  h <- if (missing(h)) 
    c(bandwidth.nrd(x), bandwidth.nrd(y))
  else rep(h, length.out = 2L)
  h <- h/4
  ax <- (new[1]-x)/h[1L]
  ay <- (new[2]-y)/h[2L]
  z <- tcrossprod(matrix(dnorm(ax), , nx), matrix(dnorm(ay), 
                                                  , nx))/(nx * h[1L] * h[2L])
  z
}


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


merge_heat <- function(events, dateCol, window, nGroups=3){
  row_batch <- split(1:nrow(foodInspect), ceiling(1:nrow(foodInspect)*nGroups/nrow(foodInspect)))
  sfInit(parallel=TRUE, cpus=min(nGroups,25)) 
  export <- c(deparse(substitute(events)),"foodInspect","kde", "heat")
  sfExport(list=export) 
  temp_heat <- sfLapply(row_batch, fun=get_heat, dat=events, dateColumn = dateCol, day_window=window)
  sfStop()
  do.call("c",temp_heat)
}






liveReadCSV <- function(key="", header=NULL, filter="&$where=1=1", dateSetting=NULL){
  
  if (key=="") stop("must supply SODA endpoint key")
  
  options(scipen=1000) 
  
  myread <- function(webHTTPaddress) read.csv(
    file = webHTTPaddress,
    header=TRUE,
    stringsAsFactors=FALSE,
    comment.char="",
    strip.white=TRUE
  )
  
  if (class(header)=="matrix" & ncol(header)==2) {
    myread <- function(webHTTPaddress, h=header) {
      read.csv(
        file = webHTTPaddress,
        header=FALSE,
        skip = 1,
        col.names=h[,1],
        colClasses=h[,2],
        comment.char="",
        strip.white=TRUE
      )
    }
  } 
  

  
  #find how many lines to read in
  url <- paste("http://data.cityofchicago.org/resource/",key,".csv?$select=count(*)",filter,sep="")
  N <- as.integer(readLines(url)[2])
  cat("downloading ",N," records ...\n\n")
  
  offsets <- seq(0,N-1,1000)
  
  sfInit(parallel=TRUE, cpus=min(CPUs,length(offsets)))
  sfExport("myread","filter","key","header","dateSetting")
  data <- sfLapply(offsets, function(off) {
    
    options(scipen=1000)
    
    if (!is.null(dateSetting)){
      #define how to read a date into numeric format, e.g. mm-dd-yyyy
      setClass(
        Class=dateSetting$name,
        representation=representation("character")
      )
      setAs(
        from="character",
        to=dateSetting$name,
        def=dateSetting$func
      )
    }
    url <- paste("http://data.cityofchicago.org/resource/",key,".csv?$offset=",off,filter,sep="")
    myread(url)})
  sfStop()                 
  return(do.call("rbind",data))
  
}

