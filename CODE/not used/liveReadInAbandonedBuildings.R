
myheader <- matrix(c(
  "service_request_type", "NULL",
  "service_request_number", "NULL",
  "date_service_request_was_received", "abandonedbuildings.date",
  "location_of_building_on_the_lot", "NULL",
  "is_the_building_dangerous_or_hazardous", "NULL",
  "is_the_building_open_or_boarded", "NULL",
  "if_the_building_is_open_where_is_the_entry_point", "NULL",
  "is_the_building_currently_vacant_or_occupied", "NULL",
  "is_the_building_vacant_due_to_fire", "NULL",
  "any_people_using_property_homeless_children_gangs", "NULL",
  "address_street_number", "NULL",
  "address_street_direction", "NULL",
  "address_street_name", "NULL",
  "address_street_suffix", "NULL",
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



setting <- list(name="abandonedbuildings.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=1=1"


abandonedBuildings <- liveReadCSV(key="7nii-7srd", header=myheader, filter=mySubset, dateSetting=setting)


abandonedBuildings <- subset(abandonedBuildings, !is.na(latitude) & !is.na(longitude) & !is.na(date_service_request_was_received))

rm(myheader, mySubset, setting); gc()
