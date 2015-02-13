
#' 
#' @name categorize
#' @param primary: a named list of the categories to convert
#' @param other: A single character name for "other", default value is "other"
#' @param ... optional arguments passed to grep
#' 
#' @description 
#' Transforms a vector of categories to preferred names, and makes non-preferred 
#' categores into an "other" category. The "other" category can be named, but 
#' the default label is "other".
#' 
#' @details
#' The labels are found using `grep`, and the user can supply additional 
#' arguments through the ... argument (e.g. ignore.case = TRUE).
#' 
#' Warning, the matching gets complicated if one string is contained in another,
#' the first pattern will prevail. See example.
#' 
#' @note
#' This might already be more efficiently implemented in base R (or some other
#' package).
#' 
#' @example
#' dat <- c("restaurant", "Restaurant and bar", "grocery", "Grocery Store",
#'          "stadium", "school", "church", "high school", "school restaurant")
#' other = "Other"
#' 
#' categorize(x = dat, 
#'            primary = list(Restaurant = "restaurant",
#'                           Grocery_Store = "grocery",
#'                           "School"), 
#'            other = "None of the above", 
#'            ignore.case = TRUE)
#' 


categorize <- function(x, primary, other = "Other", ...){
    primary <- rev(primary)
    ## intitialize a new vector ret to be returned
    ret <- vector(mode=mode(x), length = length(x))
    ret[] <- NA
    ## Get category names
    if(is.null(names(primary))){
        ## If no names are specified use "primary" directly
        cat_names <- unlist(primary)
    } else {
        ## If names are specified use primary's names, unless missing
        cat_names <- names(primary)
        for(i in 1:length(primary)){
            if(cat_names[i] == "") cat_names[i] <- primary[[i]]
        }
    }
    ## Set the new vector to the primary category when it matches a primary name
    for(i in 1:length(primary)){
        ret[grep(paste0("^" , primary[i], "$"), x, ...)] = cat_names[i]
    }
    ## otherwise set it to the "other" label
    ret[which(is.na(ret))] <- other
    
    return(ret)
}



