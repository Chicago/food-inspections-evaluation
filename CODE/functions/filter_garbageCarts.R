filter_garbageCarts <- function(garbageCarts){
    garbageCarts <- garbageCarts[!is.na(Latitude) & !is.na(Longitude) & !is.na(Creation_Date)]
    garbageCarts <- garbageCarts[Status %in% c("Completed", "Open")]
    garbageCarts
}
