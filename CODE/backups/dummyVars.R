# Q
# dummyVars('criticalFound ~ .', xmat[1:100])
dummyVars <- function (formula, data, sep = ".", levelsOnly = FALSE, 
                       fullRank = FALSE, ...) {
    # browser()}
    require(data.table)
    formula <- as.formula(formula)
    #     if (!is.data.frame(data)) 
    #         data <- as.data.frame(data)
    vars <- all.vars(formula)
    if (any(vars == ".")) {
        vars <- vars[vars != "."]
        vars <- unique(c(vars, colnames(data)))
    }
    isFac <- unlist(data[, lapply(.SD, is.factor)])
    if (sum(isFac) > 0) {
        facVars <- vars[isFac]
        lvls <- lapply(data[,facVars,with=F], levels)
        if (levelsOnly) {
            tabs <- table(unlist(lvls))
            if (any(tabs > 1)) {
                stop(paste("You requested `levelsOnly = TRUE` but", 
                           "the following levels are not unique", "across predictors:", 
                           paste(names(tabs)[tabs > 1], collapse = ", ")))
            }
        }
    }
    else {
        facVars <- NULL
        lvls <- NULL
    }
    trms <- attr(model.frame(formula, data), "terms")
    out <- list(call = match.call(), form = formula, vars = vars, 
                facVars = facVars, lvls = lvls, sep = sep, terms = trms, 
                levelsOnly = levelsOnly, fullRank = fullRank)
    class(out) <- "dummyVars"
    out
}


