

myheader <- matrix(c(
  "creation_date", "graffiti.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "what_type_of_suface_is_the_graffiti_on_", "NULL",
  "where_is_the_graffiti_located_", "NULL",
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


setting <- list(name="graffiti.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"

graffiti <- liveReadCSV(key="hec5-y4x5", header=myheader, filter=mySubset, dateSetting=setting)

graffiti <- subset(graffiti, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
graffiti <- subset(graffiti, status %in% c("Completed", "Open"))
graffiti$status <- NULL

rm(myheader, mySubset, setting); gc()


