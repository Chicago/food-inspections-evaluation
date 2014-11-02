
myheader <- matrix(c(
  "creation_date", "garbage.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "number_of_black_carts_delivered", "NULL",
  "current_activity", "NULL",
  "most_recent_action", "NULL",
  "street_address", "NULL",
  "zip_code", "NULL",
  "x_coordinate", "NULL",
  "y_coordinate", "NULL",
  "ward", "NULL",
  "police_district", "NULL",
  "community_area", "NULL",
  "ssa","NULL",
  "latitude", "numeric",
  "longitude", "numeric",
  "location", "NULL"
), ncol=2, byrow=TRUE)


setting <- list(name="garbage.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


garbageCarts <- liveReadCSV(key="9ksk-na4q", header=myheader, filter=mySubset, dateSetting=setting)

garbageCarts <- subset(garbageCarts, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
garbageCarts <- subset(garbageCarts, status %in% c("Completed", "Open"))
garbageCarts$status <- NULL

rm(myheader, mySubset, setting); gc()
