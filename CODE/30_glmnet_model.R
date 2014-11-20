
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


# see what regularization parameter 'lambda' is optimal on tune set
errors <- sapply(net$lambda, 
                 function(lam) 
                     logLik(p = as.numeric(predict(net, 
                                                   newx = mm[iiTrain,-(1:2)], 
                                                   s=lam, 
                                                   type="response")), 
                            y = mm[iiTrain ,2]))
plot(x=log(net$lambda), y=errors, type="l")



which.min(errors)
w.lam <- 100
lam <- net$lambda[w.lam]
coef <- net$beta[,w.lam]
inspCoef <- coef[grepl("^Inspector.Assigned",names(coef))]
inspCoef <- inspCoef[order(-inspCoef)]
head(inspCoef,10); tail(inspCoef,10)
coef[!grepl("^Inspector.Assigned",names(coef))]


# show gini performance of inspector model on tune data set
dat$glm_pred <- as.numeric(predict(net, newx=mm[, -(1:2)], 
                                   s=lam, 
                                   type="response"))
xmat$glm_pred <- as.numeric(predict(net, newx=mm[, -(1:2)], 
                                    s=lam, 
                                    type="response"))
xmat[iiTest, gini(glm_pred, criticalFound, plot=TRUE)]
dat[iiTest, gini(glm_pred, criticalCount, plot=TRUE)]

## Calculate confusion matrix values for evaluation
calculate_confusion_values(actual = xmat[iiTest, criticalFound],
                           expected = xmat[iiTest, glm_pred], 
                           r = .25)

## Calculate matrix of confusion matrix values for evaluation
confusion_values_test <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = xmat[iiTest, criticalFound],
                                  expected = xmat[iiTest, glm_pred]))
confusion_values_test
ggplot(reshape2::melt(as.data.table(confusion_values_test), 
                      id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))




