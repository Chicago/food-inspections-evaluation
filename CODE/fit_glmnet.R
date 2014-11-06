list.files()

library(ggplot2)
library(glmnet)

# workspace from creating the train/tune/evaluate data sets
load("./DATA/original_training_data_20140129v01.Rdata")  ## ORIGINAL (WORKED)
# load("./DATA/original_training_data_20141129v01.Rdata")
# load("./DATA/recreated_training_data_20141031v01.Rdata")

# rename the evaluate dataset to 'test'
test <- evaluate
rm(evaluate)

#loading evaluation data from pilot
load("./DATA/pilot_evaluation_20140404v01.Rdata") ## ORIGINAL WORKED
# evaluate <- readRDS("./DATA/recreated_evaluate_data_20141104v01.Rds")  ## TOM's FILE
# colnames(evaluate) <- gsub("license_","license_number",colnames(evaluate))

evaluate$criticalFound <- 0
colnames(evaluate) <- gsub("risk.x","risk",colnames(evaluate), fixed=TRUE)
colnames(evaluate) <- gsub("facility_type.x","facility_type",colnames(evaluate), fixed=TRUE)


# read in inspector id, to fit model by inspector
inspectors <-read.csv("./DATA/InspectionsGarrisonExport20112014.csv", stringsAsFactors=FALSE)
inspectors <- inspectors[inspectors$Inspection.Purpose=="Canvass",c("License.Number","Inspector.Assigned","Inspection.Date")]


#cleaning up the merge key of License.Number
#removing possibly invalid license numbers
inspectors <- subset(inspectors, nchar(License.Number) > 3 & Inspector.Assigned != " ")

#thinking letters out front, and numbers trailing hyphen are not needed (e.g. -1006 I believe is the code for retail food license)
inspectors$License.Number <- sapply(regmatches(inspectors$License.Number,regexec("[0-9]{4,}",inspectors$License.Number)),function(v) {
  if (length(v)<=1) {
    return(v)
  } else {
    return(v[1])
  }
})

#cleaning any leading zeros
inspectors$License.Number <- gsub("^[0]+","",inspectors$License.Number)

#if multiple inspections for same license number, then seeking the inspector on the first inspection
#convert date to date format, for sorting ability on date
inspectors$Inspection.Date <- as.POSIXct(strptime(inspectors$Inspection.Date,format="%m/%d/%Y"))
inspectors <- inspectors[order(inspectors$License.Number, inspectors$Inspection.Date),]
inspectors <- inspectors[!duplicated(paste(inspectors$License.Number,inspectors$Inspection.Date,sep="_")),]
inspectors$Inspector.Assigned <- factor(inspectors$Inspector.Assigned, levels = c(sort(names(table(inspectors$Inspector.Assigned))),"Other"))


# clean up facility license number to do the merge
train$License.Number <- gsub("^[0]+","",train$license_)
tune$License.Number <- gsub("^[0]+","",tune$license_)
test$License.Number <- gsub("^[0]+","",test$license_)
evaluate$License.Number <- gsub("^[0]+","",evaluate$license_number)



train_w_inspector <- merge(
  x=train,
  y=inspectors,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

tune_w_inspector <- merge(
  x=tune,
  y=inspectors,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

test_w_inspector <- merge(
  x=test,
  y=inspectors,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)

evaluate_w_inspector <- merge(
  x=evaluate,
  y=inspectors,
  by.x=c("License.Number","inspection_date"),
  by.y=c("License.Number","Inspection.Date"),
  all.x=FALSE,
  all.y=FALSE)



# glm model formula
myFormula <- ~ -1 + criticalFound + Inspector.Assigned +
  I(ifelse(pastSerious > 0, 1L, 0L)) + 
  I(ifelse(ageAtInspection > 4, 1L, 0L)) + 
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
mm <- model.matrix(myFormula, data=rbind(train_w_inspector[,all.vars(myFormula)],tune_w_inspector[,all.vars(myFormula)],test_w_inspector[,all.vars(myFormula)]))


# fit ridge regression, alpha = 0, only inspector coefficients penalized
net <- glmnet(x=mm[1:nrow(train),-1],y=mm[1:nrow(train),1],
              family="binomial", 
              alpha=0,
              penalty.factor=ifelse(grepl("^Inspector.Assigned",colnames(mm)),1,0))


# function to calculate the binomial likelihood
logLik <- function(p,y) {
  p <- pmin(pmax(p,0.0000000000001),0.999999999999)
  -sum(y*log(p) + (1-y)*log(1-p))
}


# function to calculate the normalized gini coeficient
gini <- function(p,y, plot=FALSE){
  sorted <- cbind(p,y)
  y.val <- sum(y)
  sorted <- cbind(sorted[order(-p),-1],c(1:y.val,rep(y.val,nrow(sorted)-y.val)))
  sorted <- cbind(sorted,cumsum(sorted[,1]))
  sorted <- cbind(sorted,cumsum(rep(y.val/length(y),length(y))))
  csum <- colSums(sorted[,2:4])
  gini <- (csum[2]-csum[3])/(csum[1]-csum[3])
  
  if (plot){
    plot(
      x=1:nrow(sorted)/nrow(sorted),
      y=sorted[,3]/y.val,
      main="Cummulative Captured",
      xlab="% Investigated",
      ylab="% Captured")
    lines(x=1:nrow(sorted)/nrow(sorted),y=sorted[,2]/y.val)
    text(x=0.8,y=0.2,labels=paste("Gini: ",round(gini*100,1),"%",sep=""))
    
  }
  gini
}



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
tune_w_inspector$glm_pred <- as.numeric(predict(net, newx=mm[(nrow(train_w_inspector)+1):(nrow(train_w_inspector)+nrow(tune_w_inspector)),-1], s=lam, type="response"))
gini(tune_w_inspector$glm_pred,tune_w_inspector$criticalFound, plot=TRUE)



evaluate_w_inspector$criticalFound <- 0

# make design matrix for scoring
mm <- model.matrix(myFormula, data=evaluate_w_inspector)

# score the inspector model on the 700 pilot inspections
evaluate_w_inspector$pred_inspector <- as.numeric(predict(net, newx=mm[,-1], s=lam, type="response"))



#train data average violation rate
mean(train$criticalFound)


evaluate_w_inspector$criticalFound <- ifelse(evaluate_w_inspector$criticalCount>0, 1L, 0L)
#actual results
with(evaluate_w_inspector, mean(criticalFound[type %in% c('test','both')])) 
with(evaluate_w_inspector, mean(criticalFound[type %in% c('control','both')]))

#predicted results (based on zipcode rather than inspector)
with(evaluate_w_inspector, mean(prediction[type %in% c('test','both')])) 
with(evaluate_w_inspector, mean(prediction[type %in% c('control','both')]))


#predicted results using inspector rather than zip
with(evaluate_w_inspector, mean(pred_inspector[type %in% c('test','both')])) 
with(evaluate_w_inspector, mean(pred_inspector[type %in% c('control','both')]))



#projected lift cuts in half on these 700 pilot inspections when accounting for sanitarian rather than zip