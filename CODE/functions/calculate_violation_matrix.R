
## Requires a vector of violations in text format, 
## where each element is a collapsed list of violations
## separated by |

calculate_violation_matrix <- function(violation_text){
    
    require(data.table)
    
    ## Tabluate voilation types
    ## 1) Split violoation description by "|"
    ## 2) use regex to extract leading digits of code number
    ## 3) create indicator matrix of code violations
    vio <- strsplit(violation_text,"| ",fixed=T)
    vio_nums <- lapply(vio, 
                       function(item) regmatches(x = item, 
                                                 m = gregexpr(pattern = "^[0-9]+", 
                                                              text = item)))
    vio_mat <- geneorama::list2matrix(vio_nums, count = T)
    vio_mat <- vio_mat[ , order(as.numeric(colnames(vio_mat)))]
    # colnames(vio_mat)
    # range(vio_mat)
    
    return(vio_mat)
}

