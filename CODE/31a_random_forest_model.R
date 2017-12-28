
##==============================================================================
## INITIALIZE
##==============================================================================
if(interactive()){
    ## Remove all objects; perform garbage collection
    rm(list=ls())
    gc(reset=TRUE)
    ## Detach libraries that are not used
    geneorama::detach_nonstandard_packages()
}
## Load libraries that are used
geneorama::loadinstall_libraries(c("data.table", "randomForest", "ggplot2"))
## Load custom functions
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS("DATA/30_dat.Rds")
mm <- readRDS("DATA/30_modelmatrix.Rds")
xmat <- readRDS("DATA/30_xmat.Rds")

##==============================================================================
## RANDOM FOREST MODEL
##==============================================================================
model <- randomForest(x = mm[xmat$Test==FALSE, ],
                      y = as.factor(xmat[xmat$Test==FALSE, criticalFound]),
                      importance=TRUE)

## ATTACH PREDICTIONS TO DAT
dat$rf_pred_test <- predict(model, 
                            as.matrix(mm), 
                            type="prob")[ , 2]

##==============================================================================
## SAVE RESULTS
##==============================================================================

saveRDS(dat, "DATA/31_random_forest_data.Rds")
saveRDS(model, "DATA/31_random_forest_model.Rds")



