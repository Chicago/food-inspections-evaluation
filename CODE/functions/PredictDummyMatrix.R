

PredictDummyMatrix <- function(dat, dummy_model){
    # browser() }
    
    ## Convert to data frame to make things simpler if we have a data.table
    df <- data.frame(dat)
    
    ## Make any new levels NA, then set the levels for each factor variable
    ## This does two things:
    ## 1  - Removes any new factors which were not modeled
    ## 2 - Adds more than one unique level in the even that there are not enough levels
    
    #print(class(df))
    #print(df)
    
    for(MyFactor in names(dummy_model$lvls)){
        # MyFactor = names(dummy_model$lvls)[1];MyFactor
        ii_levels_found <- df[ , MyFactor] %in% dummy_model$lvls[[MyFactor]]
        df[!ii_levels_found , MyFactor] <- NA
        df[ , MyFactor]  <- droplevels(df[ , MyFactor] )
        
        ## Reorder the levels...
        ## They need to go 1) existing levels 2) new factors
        i_existing_levels = match(levels(df[ , MyFactor]), dummy_model$lvls[[MyFactor]])
        i_new_levels = which(!dummy_model$lvls[[MyFactor]] %in%levels(df[ , MyFactor]))
        ii <- c(i_existing_levels, i_new_levels)
        levels(df[ , MyFactor]) <- dummy_model$lvls[[MyFactor]][ii]
    }
    
    ## Use the dummy matrix model to create the dummy matrix using predict
    mat = predict(dummy_model, df)
    ## Convert any NA's to 0 (the NA value doesn't make sense here, it's just an indicator value of 0)
    mat[is.na(mat)] <- 0
    
    ## Now re-order the columns to match the column order in the training set.
    ## 1 - Construct a list of names of the dummy-var columns
    ## 2 - Re-order the columns in mat to match this list of names
    
    ## Step 1 - build correct list of column-names
    dv_names <- c()
    for(MyFactor in names(dummy_model$lvls)){
        for(MyLevel in dummy_model$lvls[[MyFactor]]){
            name <- paste0(MyFactor, ".", MyLevel)
            dv_names <- c(dv_names, name)
        }
    }
    
    ## Step 2 - reorder mat into correct order
    mat <- data.frame(mat)
    column_order <- sapply(dv_names, function(x) match(x, names(mat)))
    mat <- mat[column_order]
    
    
    ## Convert to data table if the original variable was a data table
    if(inherits(dat, what="data.table")){
        mat <- as.data.table(mat)
    }
    return(mat)
}


