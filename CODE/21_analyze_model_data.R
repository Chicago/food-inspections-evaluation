
stop()

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
# geneorama::loadinstall_libraries(c("geneorama", "data.table"))
geneorama::loadinstall_libraries(c("data.table", "MASS"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## DEFINE GLOBAL VARIABLES / MANUAL CODE
##==============================================================================
DataDir <- "DATA/20141110"

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS(file.path(DataDir, "dat_with_inspector.Rds"))


##==============================================================================
## Some plots
##==============================================================================
plot(Inspection_ID~Inspection_Date, dat)
plot(N~Inspection_Date, dat[,.N,keyby=Inspection_Date], type='o')

dat[,hist(heat_sanitation)]
dat[,hist(heat_garbage)]
dat[,hist(heat_burglary)]
