chi_dp_csv2rds <- function(indir, removedots=TRUE){
    # browser()}
    require(data.table)
    require(geneorama)
    
    outfile <- paste0(indir, ".Rds")
    
    ##----------------------------------------------------------------------
    ## LOAD DATA FROM FILES
    ##----------------------------------------------------------------------
    dat <- lapply(list.files(indir, full.names=T), readRDS)
    
    # classes <- sapply(dat, function(x) sapply(x, class))
    # test <- all(apply(classes, 1, function(x)all(x[1]==x)))
    # sapply(dat, function(x) class(x$LATITUDE))
    dat <- rbindlist(dat)
    ##----------------------------------------------------------------------
    ## CONVERT STRINGS TO DATE
    ##----------------------------------------------------------------------
    
    ## Find columns that generally have a  "m/d/y" format:
    datepattern <- "^[[:digit:]]{2}\\/[[:digit:]]{2}\\/[[:digit:]]{4}"
    DatePatternCount <- sapply(X = sample(dat)[1:10000],
                               FUN = function(x) length(grep(datepattern, x)))
    DatePatternCount[DatePatternCount != 0]
    ColsToConvet <- names(DatePatternCount[DatePatternCount != 0])
    ColsToConvet
    
    ## CONVERT
    convert_datatable_StringDate(dat = dat, cols = ColsToConvet, fmt = "%m/%d/%Y")

    ##----------------------------------------------------------------------
    ## REMOVE DOTS FROM THE COLUMN NAMES
    ##----------------------------------------------------------------------
    if(removedots){
        dat_colnames <- colnames(dat)
        while(length(grep('\\.{2}', dat_colnames))!=0){
            dat_colnames <- gsub('\\.{2}', '.', dat_colnames)
        }
        dat_colnames <- gsub('^\\.|\\.$', '', dat_colnames)
        dat_colnames <- gsub('\\.', '_', dat_colnames)
        setnames(dat, dat_colnames)
    }
    ##----------------------------------------------------------------------
    ## SAVE RESULTS
    ##----------------------------------------------------------------------
    saveRDS(dat, outfile)
}


