
## Requirements for calculate_violation_types:
##       1 Requires a matrix (within a keyed data.table) of violation 
##         indicators where each row contains 0 or 1 to indicate the presence
##         of a violation.  There should be columns 1:44, named "1" to "44" 
##         (plus a key column) corresponding to the 44 violation types found in 
##         the data.
##
## Uses the function calculate_violation_matrix
## to calculate intermediate result (indicator matrix)
##

calculate_violation_types <- function(violation_mat){
    
    require(data.table)
    
    ## Check that violation_mat is a data.table
    if(!inherits(x = violation_mat, what = "data.table")){
        stop("violation_mat should be a data.table, and have a defined key")
    }
    
    ## Check for the key
    if(length(key(violation_mat)) == 0) {
        stop("The violation matrix should have a defined key")
    }
    
    vio_mat <- as.matrix(nokey(violation_mat))
    vio_key <- violation_mat[ , key(violation_mat), with = FALSE]
    
    ## Tabluate voilation types
    ## use apply to total up each group of code violations
    criticalCount <- apply(vio_mat[ , colnames(vio_mat) %in% 1:14], 1, sum)
    seriousCount <- apply(vio_mat[ , colnames(vio_mat) %in% 15:29], 1, sum)
    minorCount <- apply(vio_mat[ , colnames(vio_mat) %in% 30:44], 1, sum)

    ## Construct return values
    ret <- data.table(criticalCount,
                      seriousCount,
                      minorCount,
                      vio_key,
                      key = key(violation_mat))
    return(ret)
}
