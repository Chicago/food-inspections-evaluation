
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
geneorama::loadinstall_libraries(c("data.table", "ggplot2", "ROCR"))
## Load custom functions
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS("DATA/30_xgboost_data.Rds")
model <- readRDS("DATA/30_xgboost_model.Rds")

##==============================================================================
## XGBoost specific diagnostics
##==============================================================================


##==============================================================================
## Gini and confusion matrix calculations
##==============================================================================

## Plot of the errors by Lambda for the out of sample Test data
# Show gini performance of inspector model on tune data set
dat[Train==TRUE, gini(score, criticalFound, plot=TRUE)]
dat[Test==TRUE, gini(score, criticalFound, plot=TRUE)]

## Calculate confusion matrix values for evaluation
calculate_confusion_values(actual = dat[Test==TRUE, criticalFound],
                           expected = dat[Test==TRUE, score], 
                           r = .25)

### XGBoost
#          r   true_pos   true_neg  false_neg  false_pos 
# 0.25000000 0.07819181 0.65180208 0.07941356 0.19059255 


### Random Forest
#        r   true_pos   true_neg  false_neg  false_pos 
#0.25000000 0.05497862 0.72632865 0.10262676 0.11606597 


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
     main="ROC Curve", colorize=TRUE, lwd=3)
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
# 0.6790282 - AUC: XGBoost
# 0.6577989 - AUC: Random Forest 

#No of days to discover restaurants with critical violations
#Random Forest: Time difference of 6.554264 days
#XGBoost: 		Time difference of 7.790698 days

#Random Forest Output
# Show gini performance of inspector model on tune data set
dat[Train==TRUE, gini(score, criticalFound, plot=TRUE)]
# 0.7674537      Gini Score: XGBoost
# 0.9956746      Gini Score: RandomForest


dat[Test==TRUE, gini(score, criticalFound, plot=TRUE)]
# 0.358062      Gini Score: XGBoost
# 0.3159969     Gini Score: RandomForest


