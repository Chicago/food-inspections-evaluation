
##==============================================================================
## ORIGINAL WHERE EXPERIMENTS
##==============================================================================

library(httr)

# https://data.cityofchicago.org/resource/xzkq-xp2w.json
# https://data.cityofchicago.org/resource/r5kz-chrr.json
# https://data.cityofchicago.org/Community-Economic-Development/Business-Licenses/r5kz-chrr

GET("https://data.cityofchicago.org/resource/r5kz-chrr.json", 
    # config = "NCxdKMXKT2fPVvmZQnCdziPel",
    # path = "search", 
    #query = list(WHERE = "doing_business_as_name = 'BERGHOFF CAFE'")
    query = list(WHERE = "account_number > 395500"))

GET("https://soda.demo.socrata.com/resource/4tka-6guv")
GET("https://soda.demo.socrata.com/resource/4tka-6guv", query=list(`$select`='location'))
GET("https://soda.demo.socrata.com/resource/4tka-6guv", query=list(`$select`='location, magnitude'))



res <- GET("https://data.cityofchicago.org/resource/r5kz-chrr", 
           query = list(`$$app_token`="NCxdKMXKT2fPVvmZQnCdziPel",
                        `$WHERE` = "doing_business_as_name = 'BERGHOFF CAFE'"))
str(res)
str(res$content)
str(content(res), 0)
str(data.frame(t(sapply(content(res), unlist)), stringsAsFactors=FALSE))
res$headers


res <- GET("https://data.cityofchicago.org/resource/r5kz-chrr", 
           query = list(`$$app_token`="NCxdKMXKT2fPVvmZQnCdziPel",
                        `$WHERE` = "doing_business_as_name = 'BERGHOFF CAFE'"))
res <- GET("https://data.cityofchicago.org/resource/r5kz-chrr", 
           query = list(`$$app_token`="NCxdKMXKT2fPVvmZQnCdziPel",
                        `$WHERE` = "doing_business_as_name = 'BERGHOFF CAFE'"))

str(content(res))
http_status(res)
str(data.frame(t(sapply(content(res), unlist)), stringsAsFactors=FALSE))

library('RJSONIO') # for parsing data types from Socrata
fromJSON(res$headers[['x-soda2-types']])
fromJSON(res$headers[['x-soda2-fields']])
headers(res)


res$headers


update.packages()
res <- GET("https://data.cityofchicago.org/resource/r5kz-chrr.json", 
           query = list(`$limit`=100))
str(res$headers$`x-soda2-fields`)
library('RJSONIO') # for parsing data types from Socrata
fromJSON(res$headers[['x-soda2-types']])
fromJSON(res$headers[['x-soda2-fields']])

##==============================================================================
## TOM EXAMPLE
##==============================================================================
library(RSocrata)

df.json <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json")
df.csv <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.csv")
dim(df.json) == dim(df.csv)
# Yields TRUE TRUE

df.json <- read.socrata("https://data.cityofchicago.org/resource/4ijn-s7e5.json")
df.csv <- read.socrata("https://data.cityofchicago.org/resource/4ijn-s7e5.csv")

##==============================================================================
## IMPORTING FILES AFTER THEY'RE DOWNLOADED
##==============================================================================
library(httr)
library('RJSONIO') # for parsing data types from Socrata


# res <- GET("https://data.cityofchicago.org/resource/r5kz-chrr.json", 
#            query = list(`$limit`=100))

res_list <- lapply(list.files("test", full.names = T)[1:4], 
                   function(f){
                       
                       res <- readRDS(f)
                       
                       res_content <- content(res)
                       res_headers <- fromJSON(res$headers[['x-soda2-fields']])
                       res_matrix <- matrix(NA_character_, 
                                            nrow = length(res),
                                            ncol = length(res_headers))
                       
                       
                       for(i in 1:length(res)){
                           res_matrix[i, ] <- unlist(res_content[[i]])[res_headers]
                       }
                       colnames(res_matrix) <- res_headers
                       res_matrix
                       
                   })
foodinsp <- readRDS("DATA/20141110/food_inspections.Rds")
head(foodinsp)
head(res_list[[1]])

res <- readRDS("test/dat0001.Rds")

res_content <- content(res)
res_headers <- fromJSON(res$headers[['x-soda2-fields']])
res_matrix <- matrix(NA_character_, 
                     nrow = length(res),
                     ncol = length(res_headers))


for(i in 1:length(res)){
    res_matrix[i, ] <- unlist(res_content[[i]])[res_headers]
}
colnames(res_matrix) <- res_headers

head(res_matrix)

geneorama::clipper(head(res_matrix))


fromJSON(res$headers$`x-soda2-types`)
head(res_content)
geneorama::clipper(cbind(colnames(res_matrix), 
                         res_matrix[1,],
                         fromJSON(res$headers$`x-soda2-types`)))

res$url

##==============================================================================
## INITIAL FUNCTION DEVELOPMENT
##==============================================================================

##------------------------------------------------------------------------------
## INITIALIZE
##------------------------------------------------------------------------------
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Check for dependencies
if(!"geneorama" %in% rownames(installed.packages())){
    if(!"devtools" %in% rownames(installed.packages())){install.packages('devtools')}
    devtools::install_github('geneorama/geneorama')
}
## Load libraries
geneorama::detach_nonstandard_packages()
geneorama::loadinstall_libraries(c("httr", "RJSONIO"))


# url <- "http://data.cityofchicago.org/resource/4ijn-s7e5"
# url <- "http://data.cityofchicago.org/resource/4ijn-s7e5.json"

db="4ijn-s7e5"
outfile= "test.Rds"
outdir <- 'test'
multicore = F
apptoken = "NCxdKMXKT2fPVvmZQnCdziPel"
useaskey = "inspection_id"
rowlimit = 25000
includesys = TRUE

chi_dp_downloader
chi_dp_downloader2 <- function(db, 
                               outdir,
                               apptoken = NA,
                               rowlimit = 50000, 
                               useaskey = "id", 
                               includesys = TRUE,
                               multicore = FALSE, 
                               cores=NULL){
    
    ##--------------------------------------------------------------------------
    ## CREATE OUTPUT DIRECTORY 
    ##--------------------------------------------------------------------------
    if(!file.exists(dirname(outfile))){
        dir.create(dirname(outfile))
    }
    if(!file.exists(outdir)){
        dir.create(outdir)
    }
    
    ##--------------------------------------------------------------------------
    ## DEFINE QUERY URLS
    ##--------------------------------------------------------------------------
    url_base <- paste0("http://data.cityofchicago.org/resource/", db)
    ## Get size and count of queries
    total_rows_json <- GET(url_base, query=list(`$select`="count(*)"))
    total_rows <- as.numeric(content(total_rows_json)[[1]]$count)
    total_requests <- trunc(total_rows / rowlimit) + 1
    
    ## build the query
    q_apptoken <- ifelse(is.na(apptoken),
                         "",
                         paste0("$$app_token=", apptoken))
    q_limit <- paste0("$limit=", rowlimit)
    q_offset <- paste0("$offset=", seq(from = 0, 
                                       by = rowlimit - 1, 
                                       length.out = total_requests))
    q_order <- paste0("$order=", useaskey)
    q_use_system_fields <- ifelse(includesys, 
                                  "$$exclude_system_fields=false",
                                  "")
    ## Combine query components
    q_all_parts <- paste("?", q_apptoken, q_limit, q_offset, q_order, 
                         q_use_system_fields, sep = "&")
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
            dat <- GET(queries[i])
            saveRDS(dat, file=sprintf(file.path(outdir, "dat%04i.Rds"), i))
        }
    } else {
        for(i in 1:total_requests){
            cat("reading in", i, "of", total_requests, "requests", "\n")
            # dat <- read.table(queries[i], header=TRUE, sep=",", quote = "\"",
            #                   comment.char="", stringsAsFactors=FALSE)
            dat <- GET(queries[i])
            dat_content <- content(dat)
            str(dat_content[[1]])
            clipper(dat:1:10)
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
