
chi_dp_downloader <- function(db, apptoken="NCxdKMXKT2fPVvmZQnCdziPel",
                              rowlimit=50000, useaskey="id", outdir,
                              includesys=TRUE,
                              multicore = FALSE, cores=NULL){
    # browser()}
    
    ## TODO: Implement query filter with WHERE clause (how to do dates?)
    ##       query_filter = NULL
    ##       query_filter <- "WHERE=DATE<2013-01-01"  ## Doesn't work
    
    ##--------------------------------------------------------------------------
    ## CREATE OUTPUT DIRECTORY 
    ##--------------------------------------------------------------------------
    dir.create(outdir)
    
    ##--------------------------------------------------------------------------
    ## DEFINE QUERY URLS
    ##--------------------------------------------------------------------------
    url_base <- paste0("http://data.cityofchicago.org/resource/", db, ".csv?")
    ## Get size and count of queries
    q_count <- paste0(url_base, "$SELECT=COUNT(*)")
    total_rows <- read.table(q_count, header=T)[ , 'count']
    total_requests <- trunc(total_rows / rowlimit) + 1
    ## Construct query
    q_apptoken <- paste0("$$app_token=", apptoken)
    q_limit <- paste0("$limit=", rowlimit)
    q_offset <- paste0("$offset=", seq(0, by=rowlimit-1, length.out=total_requests))
    q_order <- paste0("$order=", useaskey)
    ## Optionally add in "include system variables"
    if(includesys){
        q_all_parts <- paste(q_apptoken, q_limit, q_offset, q_order, 
                             "$$exclude_system_fields=false", sep = "&")
    } else {
        q_all_parts <- paste(q_apptoken, q_limit, q_offset, q_order, sep = "&")
    }
    ## Take out offset of zero
    q_all_parts <- gsub("&$offset=0", "", q_all_parts)
    ## Combine parts
    queries <- paste0(url_base, q_all_parts)
    
    ##--------------------------------------------------------------------------
    ## EXECUTE QUERIES
    ##--------------------------------------------------------------------------
    if(multicore){
        require(foreach)
        require(doMC)
        if(is.null(cores)){
            if(Sys.info()['sysname']=="Windows"){
                cores <- system("C:\\Windows\\System32\\wbem\\WMIC.exe cpu get NumberOfCores", 
                                intern = T)
                cores <- as.numeric(gsub(" .+$","",cores[2]))
            } else {
                cores <- as.numeric(system("nproc", intern=T))
            }
        }
        registerDoMC(cores)
        foreach(i=1:total_requests) %dopar% {
            cat("reading in", i, "of", total_requests, "requests", "\n")
            dat <- read.table(queries[i], header=TRUE, sep=",", quote = "\"",
                                   comment.char="", stringsAsFactors=FALSE)
            saveRDS(dat, file=sprintf(file.path(outdir, "dat%04i.Rds"), i))
        }
    } else {
        for(i in 1:total_requests){
            cat("reading in", i, "of", total_requests, "requests", "\n")
            dat <- read.table(queries[i], header=TRUE, sep=",", quote = "\"",
                                   comment.char="", stringsAsFactors=FALSE)
            saveRDS(dat, file=sprintf(file.path(outdir, "dat%04i.Rds"), i))
        }
        
    }
    
    # r <- sapply(dat, nrow)
    # table(unlist(r))
    #     
    # dt <- rbindlist(dat)
    # backup <- dat
    
    # test_url <- "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$where=id>2029890 AND id<2031125"
    # tab <- read.table(test_url, header=TRUE, sep=",", quote = "\"", stringsAsFactors=FALSE)
    # x <- readLines(test_url)
    # x
    
    
    
    ## Note, it would be nice to have the system date in the outfile name,
    ## but then it would complicate the load process... so timestamp
    ## isn't implemented
    

}
