
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

## Add criticalFound variable to dat:
dat[ , criticalFound := pmin(1, criticalCount)]

## Set the key for dat
setkey(dat, Inspection_ID)

##==============================================================================
## CREATE MODEL DATA
##==============================================================================
# sort(colnames(dat))
xmat <- dat[ , list(criticalFound,
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

##==============================================================================
## CREATE TEST / TRAIN PARTITIONS
##==============================================================================
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


##==============================================================================
## GLMNET MODEL
##==============================================================================
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

## ATTACH PREDICTIONS TO XMAT AND DAT
xmat$glm_pred <- as.numeric(predict(net, newx=mm[, -(1:2)], 
                                    s=lam, 
                                    type="response"))
dat$glm_pred <- as.numeric(predict(net, newx=mm[, -(1:2)], 
                                   s=lam, 
                                   type="response"))

# show gini performance of inspector model on tune data set
xmat[iiTest, gini(glm_pred, criticalFound, plot=TRUE)]
dat[iiTest, gini(glm_pred, criticalFound, plot=TRUE)]

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



## TEST PERIOD: Date range
dat[iiTest, range(Inspection_Date)]
## TEST PERIOD: Total inspections
dat[iiTest, .N]
## TEST PERIOD: Critical found
dat[iiTest, sum(criticalCount)]
## TEST PERIOD: Inspections with any critical violations
dat[iiTest, sum(criticalFound)]


## Subset test period
datTest <- dat[iiTest]
## Identify first period
datTest[ , period := ifelse(Inspection_Date < median(Inspection_Date),1,2)]
datTest[, .N, keyby=list(period)]
datTest[, .N, keyby=list(Inspection_Date, period)]
## Identify top half of scores (which would have been the first period)
datTest[ , period_modeled := ifelse(glm_pred > median(glm_pred), 1, 2)]

datTest[period == 1, sum(criticalFound)]
datTest[period_modeled == 1, sum(criticalFound)]

datTest[, list(.N, Violations = sum(criticalFound)), keyby=list(period)]
datTest[, list(.N, Violations = sum(criticalFound)), keyby=list(period_modeled)]

110 / (129 + 71)
129 / (129 + 71)
0.645 - .5445545

## Subset test period
## Exact match of actual inspection counts in first half
ratio_of_days <- nrow(datTest[period==1]) / nrow(datTest)
ratio_of_days
datTest[ , period_modeled_strict := 
            ifelse(glm_pred > quantile(glm_pred, 1-ratio_of_days), 1, 2)]
datTest[,.N,period_modeled_strict]
datTest[,.N,period]

datTest[, list(.N, Violations = sum(criticalFound)), keyby=list(period)]
datTest[, list(.N, Violations = sum(criticalFound)), keyby=list(period_modeled_strict)]

110 / (129+73)
127 / (129+73)
0.6287129 - .5445545

