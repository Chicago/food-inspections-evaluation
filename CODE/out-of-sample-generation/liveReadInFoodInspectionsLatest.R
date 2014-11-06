#library(plyr)
library(stringr)



myheader <- matrix(c("inspection_id", "character",
                     "dba_name", "NULL",
                     "aka_name", "NULL",
                     "license_", "character",
                     "facility_type", "character",
                     "risk", "character",
                     "address", "NULL",
                     "city", "NULL",
                     "state", "NULL",
                     "zip", "NULL",
                     "inspection_date", "food.date",
                     "inspection_type", "character",
                     "results", "character",
                     "violations", "character",
                     "latitude", "NULL",
                     "longitude", "NULL",
                     "location", "NULL"), ncol=2, byrow=TRUE)


setting <- list(name="food.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)

#mySubset <- "&$where=inspection_date>to_floating_timestamp('2011-06-01T01:00:01')"
# AND inspection_date<to_floating_timestamp('2013-09-01T01:00:01')
mySubset <- "&$where=1=1"


#read in data from web
foodInspect <- liveReadCSV(key="4ijn-s7e5", header=myheader, filter=mySubset, dateSetting=setting)
cat("finished reading in ",nrow(foodInspect)," records ...\n\n")

#omit records with a missing inspection date
foodInspect <- subset(foodInspect, !is.na(inspection_date) & !is.na(license_))


cat("adding counts for critical, serious, and minor violations ...\n\n")
vio <- strsplit(foodInspect$violations,"| ",fixed=T)
foodInspect$criticalCount <- sapply(vio,function(x) sum(as.numeric(sapply(x,str_match,"^[0-9]+")) %in% 1:14))
foodInspect$seriousCount <- sapply(vio,function(x) sum(as.numeric(sapply(x,str_match,"^[0-9]+")) %in% 15:29))
foodInspect$minorCount <- sapply(vio,function(x) sum(as.numeric(sapply(x,str_match,"^[0-9]+")) %in% 30:44))
foodInspect$violations <- NULL


#cat("adding indicators for each critical violation 1-14 ...\n\n")
#vios <- ldply(vio,function(x) table(factor(sapply(x,str_match,"^[0-9]+"),levels=1:44)))
#colnames(vios) <- paste("vio",1:44,sep="")
#vios <- vios[,paste("vio",1:14,sep="")]
#head(vios)
#foodInspect <- cbind(foodInspect, vios)
#rm(vio, vios)
rm(vio)


cat("adding counts of critical, serious, and minor violations from last inspection ...\n",
    "also adding time since last inspection ...\n\n")
source("./CODE/addPast.R")



#subset to data to time period
## Time period for model training
# foodInspect <- subset(foodInspect, 
#                       inspection_date < as.POSIXct(strptime("09/01/2013",format="%m/%d/%Y")) & 
#                         inspection_date >= as.POSIXct(strptime("09/01/2011",format="%m/%d/%Y"))
# )
## Time period for results
foodInspect <- subset(foodInspect, 
                      inspection_date < as.POSIXct(strptime("10/31/2014",format="%m/%d/%Y")) & 
                        inspection_date >= as.POSIXct(strptime("08/25/2014",format="%m/%d/%Y"))
)

#omit re-inspections or special task forces
foodInspect <- subset(foodInspect, inspection_type == "Canvass")
#c("Canvass","License","Complaint","Short Form Complaint")

#keep records with a valid result
foodInspect <- subset(foodInspect, results %in%
                        c("Fail","Pass","Pass w/ Conditions"))

foodInspect$pass_flag <- ifelse(foodInspect$results=="Pass",1L,0L)

foodInspect$facility_type[!(foodInspect$facility_type %in% c("Restaurant","Grocery Store"))] <- "Other"



rm(mySubset,setting,myheader)
gc()
