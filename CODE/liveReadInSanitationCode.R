
myheader <- matrix(c(
  "creation_date", "sanitation.date",
  "status", "character",
  "completion_date", "NULL",
  "service_request_number", "NULL",
  "type_of_service_request", "NULL",
  "what_is_the_nature_of_this_code_violation_", "NULL",
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


setting <- list(name="sanitation.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


sanitationComplaints <- liveReadCSV(key="me59-5fac", header=myheader, filter=mySubset, dateSetting=setting)



sanitationComplaints <- subset(sanitationComplaints, !is.na(latitude) & !is.na(longitude) & !is.na(creation_date))
sanitationComplaints <- subset(sanitationComplaints, status %in% c("Completed", "Open"))
sanitationComplaints$status <- NULL


rm(myheader, mySubset, setting); gc()

