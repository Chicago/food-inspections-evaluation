##==============================================================================
## INITIALIZE
##==============================================================================

# Initialize by directly generating the data matrices from earlier
# stages.
#
# TODO: Refactor to read in CSVs or something instead? That might not
# be such a great idea if the form of the data changes radically in
# future, though.
source("CODE/29_init_with_data.R", echo = FALSE)

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
dat$glm_pred <- predict(model, newx=as.matrix(mm), 
                        s=lam, 
                        type="response")[,1]

# Show gini performance of inspector model on tune data set
dat[iiTest, gini(glm_pred, criticalFound, plot=TRUE)]

## Calculate confusion matrix values for evaluation
calculate_confusion_values(actual = xmat[iiTest, criticalFound],
                           expected = dat[iiTest, glm_pred], 
                           r = .25)

## Calculate matrix of confusion matrix values for evaluation
confusion_values_test <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = xmat[iiTest, criticalFound],
                                  expected = dat[iiTest, glm_pred]))
confusion_values_test
ggplot(reshape2::melt(as.data.table(confusion_values_test), 
                      id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))

##==============================================================================
## CALCULATION OF LIFT
##==============================================================================
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

141 / (141 + 117)
178 / (178 + 80)
0.6899225 - .5465116


