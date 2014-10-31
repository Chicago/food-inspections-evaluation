
myheader <- matrix(c(
  "creation_date", "abandonedvehicles.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "license_plate", "NULL",
  "vehicle_make_model", "NULL",
  "vehicle_color", "NULL",
  "current_activity", "NULL",
  "most_recent_action", "NULL",
  "how_many_days_has_the_vechicle_been_reported_as_parked", "NULL",
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



setting <- list(name="abandonedvehicles.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


abandonedVehicles <- liveReadCSV(key="3c9v-pnva", header=myheader, filter=mySubset, dateSetting=setting)


abandonedVehicles <- subset(abandonedVehicles, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
abandonedVehicles <- subset(abandonedVehicles, status %in% c("Completed", "Open"))
abandonedVehicles$status <- NULL

rm(myheader, mySubset, setting); gc()
