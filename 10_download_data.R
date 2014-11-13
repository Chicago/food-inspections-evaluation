##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Check for dependencies
if(!"geneorama" %in% rownames(installed.packages())){
    if(!"devtools" %in% rownames(installed.packages())){install.packages('devtools')}
    devtools::install_github('geneorama/geneorama')}
## Load libraries
geneorama::detach_nonstandard_packages()
geneorama::loadinstall_libraries(c("geneorama"))
geneorama::sourceDir("functions/")


## Tokens:
mytoken <- "NCxdKMXKT2fPVvmZQnCdziPel"  ## gmail account
mytoken <- "YPSdn0B006OmWzSQkhIBpDc0R"  ## city account

# multi <- FALSE
multi <- TRUE
if(multi){
    geneorama::loadinstall_libraries(c("doMC", "parallel", "iterators"))
}

##==============================================================================
## DOWNLOAD FILES FROM DATA PORTAL AS CSV
##==============================================================================
chi_dp_downloader(db="r5kz-chrr", outdir = "data/bus_license", multicore=multi, 
                  apptoken=mytoken, useaskey="id")
chi_dp_downloader(db="ijzp-q8t2", outdir = "data/crime", multicore=multi, 
                  apptoken=mytoken, useaskey="id")
chi_dp_downloader(db="4ijn-s7e5", outdir = "data/food_inspections", multicore=multi, 
                  apptoken=mytoken, useaskey="inspection_id", rowlimit=25000)
chi_dp_downloader(db="9ksk-na4q", outdir = "data/garbage_carts", multicore=multi, 
                  apptoken=mytoken, useaskey="service_request_number")
chi_dp_downloader(db="me59-5fac", outdir = "data/sanitation_code", multicore=multi, 
                  apptoken=mytoken, useaskey="service_request_number")


##==============================================================================
## CONVERT FILES FROM CSV TO RDS FILES (ALSO CHECK FOR DATES AND CONVERT THOSE)
##==============================================================================
chi_dp_csv2rds(indir = "data/bus_license")
chi_dp_csv2rds(indir = "data/crime")
chi_dp_csv2rds(indir = "data/food_inspections")
chi_dp_csv2rds(indir = "data/garbage_carts")
chi_dp_csv2rds(indir = "data/sanitation_code")

## Delete the old directories with the downloaded parts
unlink("data/bus_license/*");unlink("data/bus_license", recursive = T, force=T)
unlink("data/crime/*");unlink("data/crime", recursive = T, force=T)
unlink("data/food_inspections/*");unlink("data/food_inspections", recursive = T, force=T)
unlink("data/garbage_carts/*");unlink("data/garbage_carts", recursive = T, force=T)
unlink("data/sanitation_code/*");unlink("data/sanitation_code", recursive = T, force=T)

#==============================================================================
## SMALL FIXES
##==============================================================================

## read in data
business <- readRDS("data/bus_license.Rds")
crime <-  readRDS("data/crime.Rds")
foodInspect <- readRDS("data/food_inspections.Rds")
garbageCarts <- readRDS("data/garbage_carts.Rds")
sanitationComplaints <- readRDS("data/sanitation_code.Rds")

geneorama::convert_datatable_IntNum(business)
geneorama::convert_datatable_IntNum(crime)
geneorama::convert_datatable_IntNum(foodInspect)
geneorama::convert_datatable_IntNum(garbageCarts)
geneorama::convert_datatable_IntNum(sanitationComplaints)

crime[ , Arrest := as.logical(Arrest)]
crime[ , Domestic := as.logical(Domestic)]

str(business)
str(crime)
str(foodInspect)
str(garbageCarts)
str(sanitationComplaints)

## Remove one row where the header is (somewhat) repeated
sanitationComplaints <- sanitationComplaints[Service_Request_Number!="SERVICE REQUEST NUMBER"]
## Fix non-numeric latitude in sanitation complaints
sanitationComplaints[ , Latitude := as.numeric(Latitude)]

saveRDS(business, "data/bus_license.Rds")
saveRDS(crime , "data/crime.Rds")
saveRDS(foodInspect , "data/food_inspections.Rds")
saveRDS(garbageCarts , "data/garbage_carts.Rds")
saveRDS(sanitationComplaints , "data/sanitation_code.Rds")














