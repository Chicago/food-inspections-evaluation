
calculate_confusion_values <- function(actual, expected, r){
    res <-  expected > r
    true_pos <- res & actual
    true_neg <- !res & !actual
    false_pos <- res & !actual
    false_neg <- !res & actual
    
    result <- c(r = r,
                true_pos = sum(true_pos) / length(res),
                true_neg = sum(true_neg) / length(res),
                false_neg = sum(false_neg) / length(res),
                false_pos = sum(false_pos) / length(res))
    return(result)
}

