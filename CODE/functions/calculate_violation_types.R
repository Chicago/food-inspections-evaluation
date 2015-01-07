
calculate_violation_types <- function(violation_text){
    ## Tabluate voilation types
    ## 1) Split violoation description by "|"
    ## 2) use regex to extract leading digits of code number
    ## 3) create indicator matrix of code violations
    ## 4) use apply to total up each group of code violations
    vio <- strsplit(violation_text,"| ",fixed=T)
    vio_nums <- lapply(vio, 
                       function(item) regmatches(x = item, 
                                                 m = gregexpr(pattern = "^[0-9]+", 
                                                              text = item)))
    vio_mat <- geneorama::list2matrix(vio_nums, count = T)
    vio_mat <- vio_mat[ , order(as.numeric(colnames(vio_mat)))]
    # colnames(vio_mat)
    # range(vio_mat)
    
    criticalCount <- apply(vio_mat[ , colnames(vio_mat) %in% 1:14], 1, sum)
    seriousCount <- apply(vio_mat[ , colnames(vio_mat) %in% 15:29], 1, sum)
    minorCount <- apply(vio_mat[ , colnames(vio_mat) %in% 30:44], 1, sum)
    ret <- cbind(criticalCount,
                 seriousCount,
                 minorCount)
    return(ret)
}
