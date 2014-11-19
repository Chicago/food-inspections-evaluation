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

