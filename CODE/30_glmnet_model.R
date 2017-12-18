
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
dat <- readRDS("DATA/23_dat_model.Rds")

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
## FOR MORE INFO SEE:
## http://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html
##==============================================================================

# fit ridge regression, alpha = 0, only inspector coefficients penalized
penalty <- ifelse(grepl("^Inspector", colnames(mm)), 1, 0)

## Find best lambda based on CV results
## Note, The cvfit object includes the top model
cvfit <- cv.glmnet(x = as.matrix(mm[iiTrain]),
                   y = xmat[iiTrain,  criticalFound],
                   family = "binomial", 
                   alpha = 0,
                   penalty.factor = penalty,
                   type.measure = "deviance")

## View of results
plot(cvfit)
cvfit$lambda
cvfit$lambda.min

##==============================================================================
## ATTACH PREDICTIONS TO DAT
##==============================================================================

## Attach predictions for top lambda choice to the data
dat$score <- predict(cvfit$glmnet.fit, 
                     newx = as.matrix(mm), 
                     s = cvfit$lambda.min,
                     type = "response")[,1]

## Identify each row as test / train
dat$Test <- 1:nrow(dat) %in% iiTest
dat$Train <- 1:nrow(dat) %in% iiTrain

## Calculate scores for all lambda values
allscores <- predict(cvfit$glmnet.fit, 
                     newx = as.matrix(mm), 
                     s = cvfit$glmnet.fit$lambda,
                     type = "response")

allscores <- as.data.table(allscores)
setnames(allscores, 
         cvfit$glmnet.fit$beta@Dimnames[[2]])

## Identify each row as test / train
allscores$Test <- 1:nrow(allscores) %in% iiTest
allscores$Train <- 1:nrow(allscores) %in% iiTrain

##==============================================================================
## SAVE RESULTS
##==============================================================================

saveRDS(dat, "DATA/30_glmnet_data.Rds")
saveRDS(cvfit, "DATA/30_glmnet_cvfit.Rds")
saveRDS(allscores, "DATA/30_glmnet_allscores.Rds")


