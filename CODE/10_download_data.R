##==============================================================================
## INITIALIZE
##==============================================================================
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
geneorama::loadinstall_libraries(c("geneorama"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## DEFINE GLOBAL VARIABLES
##==============================================================================

## Application Tokens for Socrata API:
## Obtain tokens by registering on socrata.com
## Note: only the first line is used 
## Note: whitespace and comments will be stripped
if(!file.exists("CODE/socrata_token.txt")){
    stop(paste0("You need to register for an API token on socrata.com, and ",
                "put it into a file called 'socrata_token.txt' in order to ",
                "download the files from the data portal"))
} else{
    mytoken <- gsub(" |\\#.+", "", readLines("CODE/socrata_token.txt", n=1))
}

## Set "multi" to true to use parallel processor to download
## Check your platform for compatibility!  (best on Linux based systems)
# multi <- FALSE
multi <- TRUE
if(multi){
    geneorama::loadinstall_libraries(c("doMC", "parallel", "iterators"))
}


##==============================================================================
## DOWNLOAD FILES FROM DATA PORTAL AS CSV
##==============================================================================
chi_dp_downloader(db="r5kz-chrr", 
                  outdir = "DATA/bus_license", 
                  multicore = multi, 
                  apptoken = mytoken, 
                  useaskey = "id")
chi_dp_downloader(db="ijzp-q8t2",
                  outdir = "DATA/crime", 
                  multicore = multi, 
                  apptoken = mytoken, 
                  useaskey = "id",
                  where_query = "primary_type='BURGLARY'")
chi_dp_downloader(db="4ijn-s7e5", 
                  outdir = "DATA/food_inspections", 
                  multicore = multi, 
                  apptoken = mytoken, 
                  useaskey = "inspection_id", 
                  rowlimit=25000)
chi_dp_downloader(db="9ksk-na4q", 
                  outdir = "DATA/garbage_carts", 
                  multicore = multi, 
                  apptoken = mytoken, 
                  useaskey = "service_request_number")
chi_dp_downloader(db="me59-5fac", 
                  outdir = "DATA/sanitation_code", 
                  multicore = multi, 
                  apptoken = mytoken, 
                  useaskey = "service_request_number")


##==============================================================================
## CONVERT FILES FROM CSV TO RDS FILES (ALSO CHECK FOR DATES AND CONVERT THOSE)
##==============================================================================
chi_dp_csv2rds(indir = "DATA/bus_license")
chi_dp_csv2rds(indir = "DATA/crime"))
chi_dp_csv2rds(indir = "DATA/food_inspections"))
chi_dp_csv2rds(indir = "DATA/garbage_carts"))
chi_dp_csv2rds(indir = "DATA/sanitation_code"))

## Delete the files and the directories that held the temporary downloaded parts
unlink("DATA/bus_license/*")
unlink("DATA/bus_license", recursive = T, force=T)
unlink("DATA/crime/*")
unlink("DATA/crime", recursive = T, force=T)
unlink("DATA/food_inspections/*")
unlink("DATA/food_inspections", recursive = T, force=T)
unlink("DATA/garbage_carts/*")
unlink("DATA/garbage_carts", recursive = T, force=T)
unlink("DATA/sanitation_code/*")
unlink("DATA/sanitation_code", recursive = T, force=T)

#==============================================================================
## SMALL FIXES
##==============================================================================

## read in data that has been downloaded
business <- readRDS("DATA/bus_license.Rds")
crime <-  readRDS("DATA/crime.Rds")
foodInspect <- readRDS("DATA/food_inspections.Rds")
garbageCarts <- readRDS("DATA/garbage_carts.Rds")
sanitationComplaints <- readRDS("DATA/sanitation_code.Rds")

## Convert any integer columns to numeric
## Although numeric takes up more space and is slightly slower, keeping these
## fields as numeric avoids problems with integer overflow and models that
## can't handle integers.  
geneorama::convert_datatable_IntNum(business)
geneorama::convert_datatable_IntNum(crime)
geneorama::convert_datatable_IntNum(foodInspect)
geneorama::convert_datatable_IntNum(garbageCarts)
geneorama::convert_datatable_IntNum(sanitationComplaints)

## Ensure that Arrest and Domestic are Logical values
crime[ , Arrest := as.logical(Arrest)]
crime[ , Domestic := as.logical(Domestic)]

## If you are inclined, uncomment and view the structures of your downloaded 
## data before saving to see if it makes sense.
# str(business)
# str(crime)
# str(foodInspect)
# str(garbageCarts)
# str(sanitationComplaints)

## Remove one row where the header is (somewhat) repeated
sanitationComplaints <- sanitationComplaints[Service_Request_Number!="SERVICE REQUEST NUMBER"]
## Fix non-numeric latitude in sanitation complaints
sanitationComplaints[ , Latitude := as.numeric(Latitude)]

saveRDS(business, "DATA/bus_license.Rds")
saveRDS(crime , "DATA/crime.Rds")
saveRDS(foodInspect , "DATA/food_inspections.Rds")
saveRDS(garbageCarts , "DATA/garbage_carts.Rds")
saveRDS(sanitationComplaints , "DATA/sanitation_code.Rds")
