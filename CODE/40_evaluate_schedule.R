## USAGE: Rscript 40_evaluate_schedule.R proposed_schedule.csv
##
## Evaluates the performance of a proposed prioritization of
## inspection targets, as given by a CSV file.
##
## The proposed_schedule.csv file is expected to have a header line,
## and then as many rows as there are in the test set from
## init_with_data. Each row 'i' in proposed_schedule.csv is assumed to
## correspond to the i'th test set element. The inspection priority is
## expected to be in a column named "inspection.priority".
##
## Performance is evaluated by simulating performing the inspections
## in descending order of inspection.priority and checking in several
## different ways how much faster violations would have been found if
## this order had been used.

##==============================================================================
## INITIALIZE
##==============================================================================

# Initialize by directly generating the data matrices from earlier
# stages, including the "train" and "test" sets as used in the
# original evaluation.
source("CODE/29_init_with_data.R", echo = FALSE)

# Load in the prioritization file.
args <- commandArgs(trailingOnly=TRUE)
# TODO: Print usage message instead of crashing outright.
stopifnot(length(args) == 1)
sched <- read.csv(args[1])

# Ignore everything about the loaded schedule except the
# inspection.priority column. Paste that column onto the test set.
nrow(sched)
nrow(testSet)
stopifnot(nrow(sched) == nrow(testSet))
testSet$inspection.priority <- sched$inspection.priority


##==============================================================================
## ANALYZE
##==============================================================================


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


