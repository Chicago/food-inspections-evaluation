
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
geneorama::loadinstall_libraries(c("data.table", "glmnet", "ggplot2", "ROCR"))
## Load custom functions
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS("DATA/30_glmnet_data.Rds")
cvfit <- readRDS("DATA/30_glmnet_cvfit.Rds")
allscores <- readRDS("DATA/30_glmnet_allscores.Rds")

str(cvfit)
str(cvfit$glmnet.fit$beta)

##==============================================================================
## GLMNET specific diagnostics
##==============================================================================

## Find the index of the lambda that is closest to the optimal lambda of cvfit
## Because of issues with numerical precision on different platforms, it's a
## good idea to find the index of the lambda, rather than rely on matching the
## actual values.
## This result should be zero, but it might not be exactly zero on all platforms
## cvfit$glmnet.fit$lambda[iLambda] - cvfit$lambda.min
cat("The lambda that minimizes error in cvfit is:", cvfit$lambda.min, "\n")
iLambda <- which.min((cvfit$glmnet.fit$lambda - cvfit$lambda.min)^2)

## Print the coefficients
coef <- cvfit$glmnet.fit$beta[,iLambda]
coef

## Performance for different values of lambda:
plot(cvfit$cvm ~ log(cvfit$lambda))

## Note, this is equivalent to the log likelihood results
loglik_errors <- sapply(1:100, 
                        function(i) {
                            logLik(p = allscores[Train==TRUE][[i]], 
                            y = dat[Train==TRUE, criticalFound])
                            })
plot(loglik_errors ~ log(cvfit$glmnet.fit$lambda))
lines(x = log(cvfit$glmnet.fit$lambda),
      y = (1 - cvfit$glmnet.fit$dev.ratio) * cvfit$glmnet.fit$nulldev / 2,
      col = "blue")

## Evolution of coefficients as penalty changes
plot(cvfit$glmnet.fit, label = TRUE)
plot(cvfit$glmnet.fit, xvar = "dev", label = TRUE)


##==============================================================================
## Gini and confusion matrix calculations
##==============================================================================

# Show gini performance of inspector model on tune data set
dat[Train==TRUE, gini(score, criticalFound, plot=TRUE)]
dat[Test==TRUE, gini(score, criticalFound, plot=TRUE)]

## Calculate confusion matrix values for evaluation
calculate_confusion_values(actual = dat[Test==TRUE, criticalFound],
                           expected = dat[Test==TRUE, score], 
                           r = .25)

## Calculate matrix of confusion matrix values for evaluation
confusion_values_test <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = dat[Test==TRUE, criticalFound],
                                  expected = dat[Test==TRUE, score]))
confusion_values_test <- as.data.table(confusion_values_test)
confusion_values_test


ggplot(melt(confusion_values_test, id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))

##==============================================================================
## MODEL EVALUATION
##    - TIME SAVINGS
##    - PERIOD A vs PERIOD B
##==============================================================================
## Subset of just observations during test period:
datTest <- dat[Test == TRUE]

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


##==============================================================================
## Metrics with ROCR Package
##==============================================================================

## Example with random values:
# predTest <- prediction(datTest[ ,list(score, runif(.N) )], 
#                        datTest[ ,list(criticalFound, criticalFound)])

predTest <- prediction(datTest$score, datTest$criticalFound)

## precision / recall
plot(performance(predTest, "prec", "rec"), main="precision recall")

# ROC
plot(performance(predTest, "tpr", "fpr"), main="ROC")
abline(0, 1, lty=2)

## sensitivity / specificity
plot(performance(predTest, "sens", "spec"), main="sensitivity vs specificity")
abline(1, -1, lty=2)

## phi
plot(performance(predTest, "phi"), main="phi scores")

## Fancy ROC curve:
op <- par(bg="lightgray", mai=c(1.2,1.5,1,1))
plot(performance(predTest,"tpr","fpr"), 
     main="ROC Curve", colorize=TRUE, lwd=10)
par(op)

## Effect of using a cost function on cutoffs
plot(performance(predTest, "cost", cost.fp = 1, cost.fn = 1), 
     main="Even costs (FP=1 TN=1)")
plot(performance(predTest, "cost", cost.fp = 1, cost.fn = 4), 
     main="Higher cost for FN (FP=1 TN=4)")

## Accuracy
plot(performance(predTest, measure = "acc"))

## AUC
performance(predTest, measure = "auc")@y.values[[1]]
