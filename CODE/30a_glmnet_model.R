##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)

## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table", "glmnet"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
food <- readRDS("DATA/23_food_insp_features.Rds")
bus <- readRDS("DATA/24_bus_features.Rds")
sanitarians <- readRDS("DATA/19_inspector_assignments.Rds")
weather <- readRDS("DATA/17_mongo_weather_update.Rds")
heat_burglary <- readRDS("DATA/22_burglary_heat.Rds")
heat_garbage <- readRDS("DATA/22_garbageCarts_heat.Rds")
heat_sanitation <- readRDS("DATA/22_sanitationComplaints_heat.Rds")

##==============================================================================
## MERGE IN FEATURES
##==============================================================================
sanitarians <- sanitarians[,list(Inspection_ID=inspectionID), keyby=sanitarian]
setnames(heat_burglary, "heat_values", "heat_burglary")
setnames(heat_garbage, "heat_values", "heat_garbage")
setnames(heat_sanitation, "heat_values", "heat_sanitation")

dat <- copy(food)
dat <- dat[bus]
dat <- merge(x = dat,  y = sanitarians,  by = "Inspection_ID")
dat <- merge(x = dat, y = weather_3day_calc(weather), by = "Inspection_Date")
dat <- merge(dat, na.omit(heat_burglary),  by = "Inspection_ID")
dat <- merge(dat, na.omit(heat_garbage),  by = "Inspection_ID")
dat <- merge(dat, na.omit(heat_sanitation),  by = "Inspection_ID")

## Set the key for dat
setkey(dat, Inspection_ID)

## Remove unnecessary data
rm(food, bus, sanitarians, weather, heat_burglary, heat_garbage, heat_sanitation)

## Only the model data should be present
geneorama::lll()

##==============================================================================
## FILTER ROWS
##==============================================================================
dat <- dat[LICENSE_DESCRIPTION=="Retail Food Establishment"]
dat

##==============================================================================
## DISPLAY AVAILABLE VARIABLES
##==============================================================================
geneorama::NAsummary(dat)

##==============================================================================
## Add criticalFound variable to dat:
##==============================================================================
dat[ , criticalFound := pmin(1, criticalCount)]

##==============================================================================
## Calculate index for training data (last three months)
##==============================================================================
dat[ , Test := Inspection_Date >= (max(Inspection_Date) - 90)]

##==============================================================================
## CREATE MODEL DATA
##==============================================================================
# sort(colnames(dat))
xmat <- dat[ , list(Inspector = as.character(sanitarian),
                    pastSerious = pmin(pastSerious, 1),
                    pastCritical = pmin(pastCritical, 1),
                    timeSinceLast,
                    ageAtInspection = ifelse(ageAtInspection > 4, 1L, 0L),
                    consumption_on_premises_incidental_activity,
                    tobacco,
                    temperatureMax,
                    heat_burglary = pmin(heat_burglary, 70),
                    heat_sanitation = pmin(heat_sanitation, 70),
                    heat_garbage = pmin(heat_garbage, 50),
                    criticalFound),
             keyby = list(Inspection_ID, Test)]

## View the structure of the final xmat
str(xmat)

##==============================================================================
## GLMNET MODEL
##==============================================================================
## Construct model matrix without the key values in xmat
mm <- model.matrix(criticalFound ~ . -1, 
                   data = xmat[ , .SD, .SDcol=-key(xmat)])
str(mm)
colnames(mm)

# fit ridge regression, alpha = 0, only inspector coefficients penalized
penalty <- ifelse(grepl("^Inspector", colnames(mm)), 1, 0)

## PRODUCTION version of the model which is not split for test / train
model <- cv.glmnet(x = mm,
                   y = xmat[ ,  criticalFound],
                   family = "binomial", 
                   alpha = 0,
                   penalty.factor = penalty)

## EVALUATION version of the model which is only fit on the training data
model_eval <- cv.glmnet(x = mm[xmat$Test==FALSE, ],
                        y = xmat[Test == FALSE ,  criticalFound],
                        family = "binomial", 
                        alpha = 0,
                        penalty.factor = penalty)

## Lambda
model$lambda
model$lambda.min

## Attach predictions for top lambda choice to the data
dat$glm_pred <- predict(model$glmnet.fit, 
                        newx = mm, 
                        s = model$lambda.min,
                        type = "response")[,1]
dat$glm_pred_test <- predict(model_eval$glmnet.fit, 
                             newx = mm, 
                             s = model_eval$lambda.min,
                             type = "response")[,1]

## Coefficients
coef <- coef(model)[,1]
inspCoef <- coef[grepl("^Inspector",names(coef))]
inspCoef <- inspCoef[order(-inspCoef)]

## Save Results
saveRDS(dat, "DATA/30_dat.Rds")
saveRDS(xmat, "DATA/30_xmat.Rds")
saveRDS(mm, "DATA/30_modelmatrix.Rds")
saveRDS(coef, "DATA/30_coef.Rds")
saveRDS(inspCoef, "DATA/30_inspCoef.Rds")
saveRDS(model, "DATA/30_model.Rds")
saveRDS(model_eval, "DATA/30_model_eval.Rds")
