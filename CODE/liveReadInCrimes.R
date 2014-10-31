

myheader <- matrix(c(
  "id", "NULL",
  "case_number","NULL",
  "date","crime.date",
  "block","NULL",
  "iucr","NULL",
  "primary_type","character",
  "description", "NULL",
  "location_description","NULL",
  "arrest","character",
  "domestic","NULL",
  "beat","NULL",
  "district", "NULL",
  "ward", "NULL",
  "community_area","NULL",
  "fbi_code","NULL",
  "x_coordinate","NULL",
  "y_coordinate","NULL",
  "year","NULL",
  "updated_on","NULL",
  "latitude","numeric",
  "longitude","numeric",
  "location","NULL"
), ncol=2, byrow=TRUE)



setting <- list(name="crime.date",
                func=function(from) as.POSIXct(strptime(substr(from,1,10),format="%m/%d/%Y"))
)


mySubset <- "&$where=date>to_floating_timestamp('2011-07-01T01:00:01')&primary_type=BURGLARY"


crime <- liveReadCSV(key="ijzp-q8t2", header=myheader, filter=mySubset, dateSetting=setting)


crime <- subset(crime, !is.na(latitude) & !is.na(longitude) & !is.na(date))

crime$primary_type<- factor(crime$primary_type,levels=names(table(crime$primary_type)[order(-table(crime$primary_type))]))
#print(table(crime$primary_type, crime$arrest))


rm(myheader, mySubset, setting)
gc()
