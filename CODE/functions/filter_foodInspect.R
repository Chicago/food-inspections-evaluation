filter_foodInspect <- function(foodInspect){
    foodInspect <- foodInspect[!is.na(Inspection_Date) & !is.na(License)]
    if(foodInspect[,any(duplicated(Inspection_ID))]){
        warning(paste0("Removing ", nrow(foodInspect[duplicated(Inspection_ID)]), 
                       " duplicated records from foodInspect ",
                       "of ", nrow(foodInspect), " total records.\n",
                       "Duplication is based on the Inspection_ID"))
        ## Remove any duplicated Inspection_ID values
        foodInspect <- foodInspect[!duplicated(Inspection_ID)]
    }
    foodInspect <- foodInspect[License != 0]
    foodInspect <- foodInspect[Inspection_Date > as.IDate("2011-09-01")]
    foodInspect <- foodInspect[Inspection_Type == "Canvass"]
    foodInspect <- foodInspect[!Results %in% c('Out of Business',
                                               'Business Not Located',
                                               'No Entry')]
    foodInspect
}
