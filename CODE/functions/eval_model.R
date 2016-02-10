## The following fields must be present in the data.table
##    inspectData$Inspection_Date
##    inspectData$criticalFound
##    inspectData$score

eval_model <- function(inspectData) {
    require(data.table)

    required_cols <- c("Inspection_Date", "criticalFound", "score")
    if (!all(required_cols %in% colnames(inspectData))) {
        stop(paste0("data is missing one of these columns:\n",
                    paste(required_cols, collapse=", ")))
    }

    if (nrow(inspectData) != 1637) {
        warning("data length does not match expected. Different filtering?")
    }

    # Create bins for the inspections
    # This assumes inspectors perform the same number of inspections as with
    # the original schedule.
    bins <- as.data.frame(table(inspectData$Inspection_Date))
    colnames(bins) <- c("Inspection_Date", "Count")
    binSizes <- bins[,"Count"]
    binCutoffs <- c()
    cutoff <- 0
    for (i in 1:length(binSizes)) {
        cutoff <- cutoff + binSizes[i]
        binCutoffs[i] <- cutoff
    }

    # Assign inspections to bins according to score
    sortedData <- inspectData[order(-score)]
    binDates <- as.vector(bins[,"Inspection_Date"])
    assign_bin <- function(index, cutoffs, dates) {
        x <- 1
        while (cutoffs[x] < index) {
            x <- x + 1
        }
        return(dates[x])
    }
    sortedData[, New_Inspection_Date := as.Date(sapply(.I, 
                                                       assign_bin,
                                                       cutoffs=binCutoffs,
                                                       dates=binDates))]

    # Calculate the mean time saved for finding violations
    violations <- sortedData[which(criticalFound == 1)]
    violations[, dateDiff := Inspection_Date - New_Inspection_Date]
    mean(violations[,dateDiff])
}
