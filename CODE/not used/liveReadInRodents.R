

myheader <- matrix(c(
  "creation_date", "rodent.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "number_of_premises_baited", "NULL",
  "number_of_premises_with_garbage", "NULL",
  "number_of_premises_with_rats","NULL",
  "current_activity","NULL",
  "most_recent_action","NULL",
  "street_address", "NULL",
  "zip_code", "NULL",
  "x_coordinate", "NULL",
  "y_coordinate", "NULL",
  "ward", "NULL",
  "police_district", "NULL",
  "community_area", "NULL",
  "latitude", "numeric",
  "longitude", "numeric",
  "location", "NULL"
), ncol=2, byrow=TRUE)


setting <- list(name="rodent.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"

rodents <- liveReadCSV(key="97t6-zrhs", header=myheader, filter=mySubset, dateSetting=setting)

rodents <- subset(rodents, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
rodents <- subset(rodents, status %in% c("Completed", "Open"))
rodents$status <- NULL

rm(myheader, mySubset, setting); gc()


