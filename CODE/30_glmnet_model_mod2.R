
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
geneorama::loadinstall_libraries(c("data.table", "glmnet", "ggplot2"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## DEFINE GLOBAL VARIABLES / MANUAL CODE
##==============================================================================
DataDir <- "DATA/20141110"

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS(file.path(DataDir, "dat_with_inspector.Rds"))

## Remove NA's
dat[,.N,is.na(heat_burglary)]
dat <- dat[!is.na(heat_burglary)]


##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
## glm model formula
# myFormula <- ~ -1 + criticalFound + Inspector.Assigned +
#     I(ifelse(pastSerious > 0, 1L, 0L)) + 
#     #   I(ifelse(ageAtInspection > 4, 1L, 0L)) + 
#     I(ifelse(pastCritical > 0, 1L, 0L)) + 
#     consumption_on_premises_incidental_activity + 
#     tobacco_retail_over_counter +
#     temperatureMax + 
#     I(pmin(heat_sanitation, 70)) +
#     I(pmin(heat_garbage, 50)) + 
#     I(pmin(heat_burglary, 70)) + 
#     risk +
#     facility_type +
#     timeSinceLast 

sort(colnames(dat))
xmat <- dat[ , list(criticalFound = pmin(1, criticalCount),
                    Inspector_Assigned,
                    pastSerious = pmin(pastSerious, 1),
                    ageAtInspection = ifelse(ageAtInspection > 4, 1L, 0L),
                    pastCritical = pmin(pastCritical, 1),
                    consumption_on_premises_incidental_activity,
                    tobacco_retail_over_counter,
                    temperatureMax,
                    heat_burglary = pmin(heat_burglary, 70),
                    heat_sanitation = pmin(heat_sanitation, 70),
                    heat_garbage = pmin(heat_garbage, 50),
                    # risk = as.factor(Risk),
                    # facility_type = as.factor(Facility_Type),
                    timeSinceLast),
            keyby = "Inspection_ID"]

MyFormula <- ~ -1 + Inspection_ID + criticalFound + Inspector_Assigned +
    pastSerious + ageAtInspection + pastCritical + 
    consumption_on_premises_incidental_activity + tobacco_retail_over_counter +
    temperatureMax + heat_burglary + heat_sanitation + heat_garbage + 
    # risk + facility_type + 
    timeSinceLast

mm <- model.matrix(MyFormula, data=xmat[,all.vars(MyFormula),with=F])
str(xmat)
str(mm)

## 2014-07-01 is an easy separator
dat[Inspection_Date < "2014-07-01", range(Inspection_Date)]
dat[Inspection_Date > "2014-07-01", range(Inspection_Date)]

iiTrain <- dat[ , which(Inspection_Date < "2014-07-01")]
iiTest <- dat[ , which(Inspection_Date > "2014-07-01")]

## Check to see if any rows didn't make it through the model.matrix formula
nrow(dat)
nrow(xmat)
nrow(mm)
dat[!Inspection_ID %in% mm[, "Inspection_ID"]]

# fit ridge regression, alpha = 0, only inspector coefficients penalized
net <- glmnet(x = mm[iiTrain, -(1:2)],
              y = mm[iiTrain,  2],
              family = "binomial", 
              alpha = 0,
              penalty.factor = ifelse(grepl("^Inspector.Assigned", colnames(mm)), 1, 0))
names(net)
