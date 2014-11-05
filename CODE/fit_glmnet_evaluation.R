stop()

rm(list=ls())

list.files()

library(ggplot2)
library(glmnet)
library(data.table)
source("CODE/functions/gini.R")
source("CODE/functions/logLik.R")
source("CODE/functions/calculate_confusion_values.R")

##------------------------------------------------------------------------------
## LOAD DATA
##------------------------------------------------------------------------------

## Workspace from creating the train/tune/evaluate data sets
load("./DATA/original_training_data_20140129v01.Rdata")  ## ORIGINAL (WORKED)
# load("./DATA/original_training_data_20141129v01.Rdata")
# load("./DATA/recreated_training_data_20141031v01.Rdata")


## Rename the evaluate dataset to 'test'
test <- as.data.table(evaluate)
setnames(test, "license_", "License.Number")
rm(evaluate)

## Loading evaluation data from pilot
# load("./DATA/pilot_evaluation_20140404v01.Rdata") ## ORIGINAL WORKED
evaluate <- as.data.table(readRDS("./DATA/recreated_evaluate_data_20141104v01.Rds"))  ## TOM's FILE
evaluate <- droplevels(evaluate)
setnames(evaluate, "license_", "license_number")
evaluate[ , criticalFound := 0]

## read in inspector id, to fit model by inspector
inspectors_old<- as.data.table(read.csv("./DATA/InspectionsGarrisonExport20112014.csv", 
                                          stringsAsFactors=FALSE))
inspectors_new <- as.data.table(readRDS("DATA/InspectionsGarrisonExport20141105.Rds"))
# geneorama::inin(evaluate$license_number, inspectors$licensenumber)
setnames(inspectors_new, c("DBA", "Address", "License.Number", "License.Type",
                           "Inspector.Assigned", "Inspection.Date", "Inspection.Purpose"))

##------------------------------------------------------------------------------
## MODIFY DATA
##------------------------------------------------------------------------------
## convert date to date format, for sorting ability on date
inspectors_old[ , Inspection.Date := as.POSIXct(strptime(Inspection.Date, "%m/%d/%Y"))]

## Subset
inspectors_old <- inspectors_old[Inspection.Purpose=="Canvass",
                                 list(License.Number,Inspector.Assigned,Inspection.Date)]
inspectors_new <- inspectors_new[Inspection.Purpose=="Canvass",
                                 list(License.Number,Inspector.Assigned,Inspection.Date)]

## Cleaning up the merge key of License.Number

## Thinking letters out front, and numbers trailing hyphen are not needed 
## (e.g. -1006 I believe is the code for retail food license)
inspectors_new[ , License.Number := gsub('[A-z]+|-.+$', "", License.Number)]
inspectors_old[ , License.Number := gsub('[A-z]+|-.+$', "", License.Number)]

## cleaning any leading zeros
inspectors_new[ , License.Number := gsub('^[0]+', "", License.Number)]
inspectors_old[ , License.Number := gsub('^[0]+', "", License.Number)]

## removing possibly invalid license numbers
inspectors_new <- inspectors_new[nchar(License.Number) > 3 & Inspector.Assigned != " "]
inspectors_old <- inspectors_old[nchar(License.Number) > 3 & Inspector.Assigned != " "]

## if multiple inspections for same license number, then seeking the inspector 
## on the first inspection
inspectors_new <- inspectors_new[ , .N, by=list(License.Number, Inspection.Date, Inspector.Assigned)]
inspectors_old <- inspectors_old[ , .N, by=list(License.Number, Inspection.Date, Inspector.Assigned)]
inspectors_new$N <- NULL
inspectors_old$N <- NULL
setkey(inspectors_new, License.Number, Inspection.Date)
setkey(inspectors_old, License.Number, Inspection.Date)

# lvl_new <- c(sort(names(table(inspectors_new$Inspector.Assigned))),"Other")
# lvl_old <- c(sort(names(table(inspectors_old$Inspector.Assigned))),"Other")
# inspectors_new[,Inspector.Assigned := factor(Inspector.Assigned, levels = lvl_new)]
# inspectors_old[,Inspector.Assigned := factor(Inspector.Assigned, levels = lvl_old)]
lvl_all <- c(sort(unique(c(inspectors_new$Inspector.Assigned, 
                           inspectors_old$Inspector.Assigned))),
             "Other")
inspectors_new[,Inspector.Assigned := factor(Inspector.Assigned, levels = lvl_all)]
inspectors_old[,Inspector.Assigned := factor(Inspector.Assigned, levels = lvl_all)]


# clean up facility license number to do the merge
train$License.Number <- gsub("^[0]+","",train$license_)
tune$License.Number <- gsub("^[0]+","",tune$license_)
test$License.Number <- gsub("^[0]+","",test$License.Number)
evaluate$License.Number <- gsub("^[0]+","",evaluate$license_number)

train_w_inspector <- merge(
  x=train,
  y=inspectors_old,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

tune_w_inspector <- merge(
  x=tune,
  y=inspectors_old,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

test_w_inspector <- merge(
  x=as.data.frame(test),
  y=as.data.frame(inspectors_old),
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

evaluate_w_inspector <- merge(
  x=as.data.frame(evaluate),
  y=as.data.frame(inspectors_new),
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)



# glm model formula
myFormula <- ~ -1 + criticalFound + Inspector.Assigned +
  I(ifelse(pastSerious > 0, 1L, 0L)) + 
#   I(ifelse(ageAtInspection > 4, 1L, 0L)) + 
  I(ifelse(pastCritical > 0, 1L, 0L)) + 
  consumption_on_premises_incidental_activity + 
  tobacco_retail_over_counter +
  temperatureMax + 
  I(pmin(heat_sanitation, 70)) +
  I(pmin(heat_garbage, 50)) + 
  I(pmin(heat_burglary, 70)) + 
  risk +
  facility_type +
  timeSinceLast 


# make design matrix for glmnet using all train, tune, test data (will subset to train only in call to fit)
mm <- model.matrix(myFormula, data=rbind(train_w_inspector[,all.vars(myFormula)],
                                         tune_w_inspector[,all.vars(myFormula)],
                                         test_w_inspector[,all.vars(myFormula)]))

## THese columns have no data
mm <- mm[ , !colnames(mm) %in% c("Inspector.AssignedBrian Turkaly", 
                                 #     "I(ifelse(ageAtInspection > 4, 1, 0))",
                                 "Inspector.AssignedOther")]

# fit ridge regression, alpha = 0, only inspector coefficients penalized
net <- glmnet(x=mm[1:nrow(train),-1],y=mm[1:nrow(train),1],
              family="binomial", 
              alpha=0,
              penalty.factor=ifelse(grepl("^Inspector.Assigned",colnames(mm)),1,0))


# see what regularization parameter 'lambda' is optimal on tune set
ii <-  (nrow(train_w_inspector)+1):(nrow(train_w_inspector)+nrow(tune_w_inspector))
errors <- sapply(net$lambda, 
                 function(lam) 
                     logLik(p = as.numeric(predict(net, newx = mm[ii,-1], s=lam, type="response")), 
                            y = mm[ii ,1]))
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
ii = (nrow(train_w_inspector)+1):(nrow(train_w_inspector)+nrow(tune_w_inspector))
tune_w_inspector$glm_pred <- as.numeric(predict(net, newx=mm[ii,-1], s=lam, type="response"))
gini(tune_w_inspector$glm_pred,tune_w_inspector$criticalFound, plot=TRUE)



evaluate_w_inspector$criticalFound <- 0

# make design matrix for scoring
mm <- model.matrix(myFormula, data=evaluate_w_inspector)

# score the inspector model on the 700 pilot inspections
# evaluate_w_inspector$pred_inspector <- as.numeric(predict(net, newx=mm[,-1], s=lam, type="response"))
rm_j <- which(colnames(mm)%in%c("Inspector.AssignedOther","Inspector.AssignedBrian Turkaly"))
evaluate_w_inspector$pred_inspector <- as.numeric(predict(net, newx=mm[,-c(1, rm_j)], s=lam, type="response"))

#train data average violation rate
mean(train$criticalFound)

#actual results
evaluate_w_inspector$criticalFound <- ifelse(evaluate_w_inspector$criticalCount>0, 1L, 0L)
mean(evaluate_w_inspector$criticalFound)

mean(evaluate_w_inspector$pred_inspector)
gini(evaluate_w_inspector$pred_inspector, evaluate_w_inspector$criticalFound, plot=TRUE)



hist(tune_w_inspector$glm_pred)
boxplot(tune_w_inspector$results, tune_w_inspector$glm_pred)
boxplot(evaluate_w_inspector$pass_flag, evaluate_w_inspector$pred_inspector)
hist(evaluate_w_inspector$pred_inspector)

evaluate_w_inspector$pass_flag <- as.factor(evaluate_w_inspector$pass_flag)
tune_w_inspector$pass_flag <- as.factor(tune_w_inspector$pass_flag)

ggplot(evaluate_w_inspector) + aes(y=pred_inspector, x=pass_flag, fill=pass_flag) + geom_boxplot()
ggplot(tune_w_inspector) + aes(y=glm_pred, x=pass_flag, fill=pass_flag) + geom_boxplot()

lattice::bwplot( ~ pred_inspector | pass_flag, data = evaluate_w_inspector, layout = c(1,2), fill = "salmon")
lattice::bwplot( ~ glm_pred | pass_flag, data = tune_w_inspector, layout = c(1,2), fill = "salmon")


## Calculate confusion matrix values for tune
calculate_confusion_values(actual = tune_w_inspector$criticalFound,
                           expected = tune_w_inspector$glm_pred, 
                           r = .25)
confusion_values_tune <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = tune_w_inspector$criticalFound,
                                  expected = tune_w_inspector$glm_pred))
confusion_values_tune
ggplot(reshape2::melt(as.data.table(confusion_values_tune), 
                      id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))



## Calculate confusion matrix values for evaluate
calculate_confusion_values(actual = evaluate_w_inspector$criticalFound,
                           expected = evaluate_w_inspector$pred_inspector, 
                           r = .25)
confusion_values_eval <- t(sapply(seq(0, 1 ,.01), 
                                  calculate_confusion_values,
                                  actual = evaluate_w_inspector$criticalFound,
                                  expected = evaluate_w_inspector$pred_inspector))
confusion_values_eval
ggplot(reshape2::melt(as.data.table(confusion_values_eval), 
                      id.vars="r")) + 
    aes(x=r, y=value, colour=variable) + geom_line() + 
    geom_hline(yintercept = c(0,1))










