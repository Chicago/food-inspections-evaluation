
##==============================================================================
## FIRST TRY USING rjson
##==============================================================================
geneorama::loadinstall_libraries("rjson")

qcnt <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$SELECT=COUNT(*)"
cnt <- fromJSON(file=qcnt, method='C')
cnt

qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=5&$offset=150&$order=id"
examp <- fromJSON(file=qexamp, method='C')
str(examp[[1]])
str(examp[[2]])
examp

parser <- newJSONParser()
parser$addData(as.character(examp[[1]]))
parser$getObject()
addData(examp)$getObject()

##==============================================================================
## SECOND TRY USING jsonlite
##==============================================================================
geneorama::loadinstall_libraries("jsonlite")

qcnt <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$SELECT=COUNT(*)"
cnt <- fromJSON(qcnt)
cnt

qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=5&$offset=150&$order=date"
examp <- fromJSON(qexamp)
str(examp)
cnt

qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=5&$offset=50&$order=id"
examp <- fromJSON(qexamp)


qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=50000&$offset=0&$order=id"
qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$exclude_system_fields=false&$limit=500&$offset=1000000&$order=id"

system.time(examp <- fromJSON(qexamp))
str(examp)

library(data.table)d

dt <- as.data.table(examp)
str(dt)
dt_loc <- dt$location
dt$location <- NULL
dt

dt[,as.IDate(date),id]

## FULL EXAMpLE
qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=NCxdKMXKT2fPVvmZQnCdziPel&$$exclude_system_fields=false&$limit=50000&$offset=0&$order=id"      
system.time(examp <- fromJSON(qexamp))
str(examp)
qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$app_token=NCxdKMXKT2fPVvmZQnCdziPel&$$exclude_system_fields=false&$limit=50000&$offset=49999&$order=id"  
system.time(examp <- fromJSON(qexamp))
str(examp)




##==============================================================================
## THIRD TRY USING csv
##==============================================================================
qcnt <- "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$SELECT=COUNT(*)"
cnt <- readLines(qcnt)
cnt

qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$limit=50000&$offset=150&$order=date"
examp <- read.table(qexamp, header=TRUE, sep=",", stringsAsFactors=FALSE)
str(examp)
cnt

qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=5&$offset=150&$order=id"
examp <- fromJSON(qexamp)


qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$limit=50000&$offset=0&$order=id"
qexamp <- "https://data.cityofchicago.org/resource/ijzp-q8t2.json?$$exclude_system_fields=false&$limit=500&$offset=1000000&$order=id"
system.time(examp <- fromJSON(qexamp))
str(examp)

library(data.table)d

dt <- as.data.table(examp)
str(dt)
dt_loc <- dt$location
dt$location <- NULL
dt

dt[,as.IDate(date),id]

