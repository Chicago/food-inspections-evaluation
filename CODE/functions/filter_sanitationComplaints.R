filter_sanitationComplaints <- function(sanitationComplaints) {
    sanitationComplaints <- sanitationComplaints[!is.na(Latitude) & !is.na(Longitude) & !is.na(Creation_Date)]
    sanitationComplaints <- sanitationComplaints[Status %in% c("Completed", "Open")]
    sanitationComplaints
}
