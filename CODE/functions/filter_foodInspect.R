filter_foodInspect <- function(foodInspect){
    foodInspect <- foodInspect[!is.na(Inspection_Date) & !is.na(License)]
    foodInspect <- foodInspect[!duplicated(Inspection_ID)]
    foodInspect <- foodInspect[License != 0]
    foodInspect <- foodInspect[Inspection_Date > as.IDate("2011-09-01")]
    foodInspect <- foodInspect[Inspection_Type == "Canvass"]
    foodInspect <- foodInspect[!Results %in% c('Out of Business',
                                               'Business Not Located',
                                               'No Entry')]
    foodInspect
}
