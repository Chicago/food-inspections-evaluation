
simulated_bin_summary <- function(dates, scores, positives) {
    require(data.table)
    
    ##--------------------------------------------------------------------------
    ## Create base data
    ##--------------------------------------------------------------------------
    ## Assemble components into a data.table for convenience
    dat <- data.table(date=dates, score=scores, positives)
    
    ##--------------------------------------------------------------------------
    ## Add simulated result
    ##--------------------------------------------------------------------------
    
    ## This assumes inspectors would perform the same number of inspections per
    ## day, as they had in their original schedule.
    
    ## The simulated date is a vector of the original dates in sequential
    ## order, but matched to the original data ordered by score.
    dat <- dat[order(-score), simulated_date := dat[order(date), date]][]
    
    ##--------------------------------------------------------------------------
    ## Simulate inspector assignment to bins according to score
    ##--------------------------------------------------------------------------
    
    ## Create bin summary of results
    
    ## Caluclate original counts / day
    ## Note: Using `keyby` forces the result to be sorted, which is necessary
    ##       for the cumulative summation.
    bins <- dat[i = TRUE,
                j = list(POS = sum(positives), 
                         .N), 
                keyby = date]
    bins <- bins[ , NTOT := cumsum(N)][]
    bins <- bins[ , POSTOT := cumsum(POS)][]
    
    ## Caluclate simulated counts / day
    ## Note: Here we key by the simulated date
    bins_sim <- dat[i = TRUE,
                    j = list(POS = sum(positives), 
                             .N), 
                    keyby = simulated_date]
    bins_sim <- bins_sim[ , NTOT := cumsum(N)][]
    bins_sim <- bins_sim[ , POSTOT := cumsum(POS)][]
    
    setcolorder(bins, c("date", "N", "NTOT", "POS", "POSTOT"))
    bins <- merge(bins, 
                  bins_sim[i = TRUE,
                           j = list(POS_SIM = POS,
                                    POSTOT_SIM = POSTOT),
                           keyby = list(date = simulated_date)],
                  "date")
    return(bins)

}
