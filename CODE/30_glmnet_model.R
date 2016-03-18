
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
geneorama::loadinstall_libraries(c("data.table", "glmnet", "ggplot2"))
## Load custom functions
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS("DATA/dat_model.Rds")

## Only keep "Retail Food Establishment"
dat <- dat[LICENSE_DESCRIPTION == "Retail Food Establishment"]
## Remove License Description
dat[ , LICENSE_DESCRIPTION := NULL]
dat <- na.omit(dat)

## Add criticalFound variable to dat:
dat[ , criticalFound := pmin(1, criticalCount)]

## Set the key for dat
setkey(dat, Inspection_ID)

## Match time period of original results
# dat <- dat[Inspection_Date < "2013-09-01" | Inspection_Date > "2014-07-01"]

##==============================================================================
## CREATE MODEL DATA
##==============================================================================
# sort(colnames(dat))
xmat <- dat[ , list(Inspector = Inspector_Assigned,
                    pastSerious = pmin(pastSerious, 1),
                    pastCritical = pmin(pastCritical, 1),
                    timeSinceLast,
                    ageAtInspection = ifelse(ageAtInspection > 4, 1L, 0L),
                    consumption_on_premises_incidental_activity,
                    tobacco_retail_over_counter,
                    temperatureMax,
                    heat_burglary = pmin(heat_burglary, 70),
                    heat_sanitation = pmin(heat_sanitation, 70),
                    heat_garbage = pmin(heat_garbage, 50),
                    # Facility_Type,
                    criticalFound),
            keyby = Inspection_ID]
mm <- model.matrix(criticalFound ~ . -1, data=xmat[ , -1, with=F])
mm <- as.data.table(mm)
str(mm)
colnames(mm)

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

##==============================================================================
## GLMNET MODEL
##==============================================================================
# fit ridge regression, alpha = 0, only inspector coefficients penalized
pen <- ifelse(grepl("^Inspector", colnames(mm)), 1, 0)
model <- glmnet(x = as.matrix(mm[iiTrain]),
                y = xmat[iiTrain,  criticalFound],
                family = "binomial", 
                alpha = 0,
                penalty.factor = pen)

## See what regularization parameter 'lambda' is optimal on tune set
## (We are essentially usin the previous hardcoded value)
errors <- sapply(model$lambda, 
                 function(lam) 
                     logLik(p = predict(model, 
                                        newx = as.matrix(mm[iiTrain]), 
                                        s=lam, 
                                        type="response")[,1], 
                            y = xmat[iiTrain, criticalFound]))
## Plot of the errors by lambda
plot(x=log(model$lambda), y=errors, type="l")
which.min(errors)
model$lambda[which.min(errors)]
## Manual selection of lambda
w.lam <- 100
lam <- model$lambda[w.lam]
coef <- model$beta[,w.lam]
inspCoef <- coef[grepl("^Inspector",names(coef))]
inspCoef <- inspCoef[order(-inspCoef)]

## Print coefficients for the Inspectors (and for other variables)
inspCoef
coef[!grepl("^Inspector",names(coef))]

## Plot of the errors by Lambda for the out of sample Test data
errorsTest <- sapply(model$lambda, 
                     function(lam) 
                         logLik(p = predict(model, 
                                            newx = as.matrix(mm[iiTest]), 
                                            s=lam, 
                                            type="response")[,1], 
                                y = xmat[iiTest, criticalFound]))
plot(x=log(model$lambda), y=errorsTest, type="l")
which.min(errorsTest)
model$lambda[which.min(errorsTest)]

## ATTACH PREDICTIONS TO DAT
dat$score <- predict(model, newx=as.matrix(mm), 
                     s=lam, 
                     type="response")[,1]

# Show gini performance of inspector model on tune data set
dat[iiTest, gini(score, criticalFound, plot=TRUE)]

## Calculate confusion matrix values for evaluation
calculate_confusion_values(actual = xmat[iiTest, criticalFound],
                           expected = dat[iiTest, score], 
                           r = .25)

## Calculate matrix of confusion matrix values for evaluation
confusion_values_test <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = xmat[iiTest, criticalFound],
                                  expected = dat[iiTest, score]))
confusion_values_test
ggplot(reshape2::melt(as.data.table(confusion_values_test), 
                      id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))

##==============================================================================
## MODEL EVALUATION
##    - TIME SAVINGS
##    - PERIOD A vs PERIOD B
##==============================================================================
## Subset of just observations during test period:
datTest <- dat[iiTest]

## Mean time savings:
datTest[ , simulated_date_diff_mean(Inspection_Date, score, criticalFound)]

## Detailed time savings:
bins <- datTest[ , simulated_bin_summary(Inspection_Date, score, criticalFound)]
bins

## This calculation is the weighted average date difference, which should match
## the previous result from `simulated_bin_summary`
bins[ , sum(as.integer(date) * POS) / sum(POS)] -
    bins[ , sum(as.integer(date) * POS_SIM) / sum(POS_SIM)]

## Find the midpoint of the inspections to divide bins into period A & B
mid <- bins[ , sum(N)/2]

## Divide the bins into period A & B based on midpoint
## Note: GT and LT is strict, so ties would be excluded.  Although there are no
##       ties for now (as of 2015 publication).
binsA <- bins[NTOT < mid]
binsB <- bins[NTOT > mid]

tot_crit <- sum(bins$POS)

binsA[ , sum(POS)/tot_crit]     ## [1] 0.5465116
binsA[ , sum(POS_SIM)/tot_crit] ## [1] 0.6821705


