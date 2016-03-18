
simulated_date_diff_mean <- function(dates, scores, pos) {
    require(data.table)
    
    ##--------------------------------------------------------------------------
    ## Create base data
    ##--------------------------------------------------------------------------
    ## Assemble components into a data.table for convenience
    dat <- data.table(date=dates, score=scores, pos)
    
    ##--------------------------------------------------------------------------
    ## Add simulated result
    ##--------------------------------------------------------------------------
    
    ## This assumes inspectors would perform the same number of inspections per
    ## day, as they had in their original schedule.
    
    ## The simulated date is a vector of the original dates in sequential
    ## order, but matched to the original data ordered by score.
    dat <- dat[order(-score), simulated_date := dat[order(date), date]][]
    
    ## The time difference is the difference between the original date and 
    ## the simulated date, for occurrences that are "positive"
    mean_diff <- dat[pos==1, mean(date - simulated_date)]
    
    ##--------------------------------------------------------------------------
    ## Return average date difference
    ##--------------------------------------------------------------------------
    return(mean_diff)

}
