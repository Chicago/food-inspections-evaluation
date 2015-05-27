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
stopifnot(nrow(sched) == nrow(testSet))
testSet$inspection.priority <- sched$inspection.priority


##==============================================================================
## ANALYZE
##==============================================================================


# Show gini performance of inspector model on tune data set
testSet[gini(inspection.priority, criticalFound, plot=TRUE)]

##==============================================================================
## CALCULATION OF LIFT
##==============================================================================
## TEST PERIOD: Date range
testSet[, range(Inspection_Date)]
## TEST PERIOD: Total inspections
testSet[, .N]
## TEST PERIOD: Critical found
testSet[, sum(criticalCount)]
## TEST PERIOD: Inspections with any critical violations
testSet[, sum(criticalFound)]

## Identify first period
testSet[, period := ifelse(Inspection_Date < median(Inspection_Date),1,2)]
testSet[, .N, keyby=list(period)]
testSet[, .N, keyby=list(Inspection_Date, period)]
## Identify top half of scores (which would have been the first period)
testSet[, period_modeled := ifelse(inspection.priority > median(inspection.priority), 1, 2)]

testSet[period == 1, sum(criticalFound)]
testSet[period_modeled == 1, sum(criticalFound)]

BAU_period_violations <- testSet[, list(.N, Violations = sum(criticalFound)), keyby=list(period)]
BAU_period_violations
Model_period_violations <- testSet[, list(.N, Violations = sum(criticalFound)), keyby=list(period_modeled)]
Model_period_violations

print("Percent of critical violations found in period 1 (business as usual):")
print(BAU_period_violations$Violations[1]
      /
      sum(BAU_period_violations$Violations))

print("Percent of critical violations found in period 1 (model):")
print(Model_period_violations$Violations[1]
      /
      sum(Model_period_violations$Violations))
