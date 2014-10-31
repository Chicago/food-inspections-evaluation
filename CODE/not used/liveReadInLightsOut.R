
myheader <- matrix(c(
  "creation_date", "lights.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "character",
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



setting <- list(name="lights.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


alleyLights <- liveReadCSV(key="t28b-ys7j", header=myheader, filter=mySubset, dateSetting=setting)
streetLights <- liveReadCSV(key="3aav-uy2v", header=myheader, filter=mySubset, dateSetting=setting)


alleyLights <- subset(alleyLights, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
alleyLights <- subset(alleyLights, status %in% c("Completed", "Open"))
alleyLights$status <- NULL

streetLights <- subset(streetLights, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
streetLights <- subset(streetLights, status %in% c("Completed", "Open"))
streetLights$status <- NULL

lightsOut <- rbind(alleyLights,streetLights)

rm(myheader, mySubset, setting, alleyLights, streetLights); gc()
