
myheader <- matrix(c(
  "creation_date", "treetrims.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "location_of_trees", "NULL",
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



setting <- list(name="treetrims.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


treeTrims <- liveReadCSV(key="uxic-zsuj", header=myheader, filter=mySubset, dateSetting=setting)


treeTrims <- subset(treeTrims, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
treeTrims <- subset(treeTrims, status %in% c("Completed", "Open"))
treeTrims$status <- NULL

rm(myheader, mySubset, setting); gc()
