
myheader <- matrix(c(
  "creation_date", "pothole.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "currentActivity", "NULL",
  "most_recent_action", "NULL",
  "number_of_potholes_filled_on_block", "NULL",
  "street_address", "NULL",
  "zip", "NULL",
  "x_coordinate", "NULL",
  "y_coordinate", "NULL",
  "ward", "NULL",
  "police_district", "NULL",
  "community_area", "NULL",
  "latitude", "numeric",
  "longitude", "numeric",
  "location", "NULL"
), ncol=2, byrow=TRUE)



setting <- list(name="pothole.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


potHoles <- liveReadCSV(key="7as2-ds3y", header=myheader, filter=mySubset, dateSetting=setting)


potHoles <- subset(potHoles, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
potHoles <- subset(potHoles, status %in% c("Completed", "Open"))
potHoles$status <- NULL

rm(myheader, mySubset, setting); gc()
