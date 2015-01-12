

## Overwrite original inspector file

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
geneorama::loadinstall_libraries(c("data.table", "glmnet", "ggplot2", "caret"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS("DATA/dat_model.Rds")

insp_tab <- readRDS("DATA/insp_table.Rds")
inspectors <- readRDS("DATA/inspectors.Rds")

insp_merged <- 
    merge(inspectors,
          insp_tab[ , list(Inspector_Assigned = insp, 
                           insp_grade = as.character(insp_grade))],
          by = "Inspector_Assigned", 
          all.x = TRUE)
insp_merged[ , Inspector_Assigned := insp_grade]
insp_merged[ , insp_grade := NULL]
insp_merged <- insp_merged[!is.na(Inspector_Assigned)]
insp_merged

saveRDS(insp_merged, "DATA/inspectors.Rds")

