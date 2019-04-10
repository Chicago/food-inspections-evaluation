##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)

## Load libraries & project functions
geneorama::loadinstall_libraries(c("data.table", "xgboost", "ggplot2"))
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
## XGBOOST MODEL
##==============================================================================

mm <- model.matrix(criticalFound ~ . -1, 
                   data = xmat[ , .SD, .SDcol=-key(xmat)])

iiTest <- dat$Test
iiTrain <- !dat$Test


# Extract train data set
train <- mm[iiTrain, ]
test  <- mm[iiTest, ]

train.target <- xmat[iiTrain, criticalFound]
test.target  <- xmat[iiTest, criticalFound]

#table(train.target)
#table(test.target)

set.seed(1)

# 5% of test data is taken for validation purpose (733+120 = 853 [5% of 17075 - Train set] )
h <- c( sample(which(train.target == 0), 733), sample(which(train.target == 1), 120))

# Create validation data set based on the above rows
dval   <- xgb.DMatrix(data = data.matrix(train[h, ]), label = train.target[h])
dtrain <- xgb.DMatrix(data = data.matrix(train), label = train.target)

watchlist <- list(val = dval, train = dtrain)

# Run xgbmodel
set.seed(1)
xgbmodel <- xgb.train(data = dtrain, 
                      nfold = 5,
                      eta = 0.02,
                      max_depth = 6,
                      nround=500, 
                      subsample = 0.75,
                      colsample_bytree = 0.75,
                      eval_metric = "mlogloss",
                      objective = "multi:softprob",
                      num_class = 2,
                      nthread = 4,
                      num_parallel_trees = 500,
                      early_stopping_rounds = 25,
                      watchlist = watchlist,
                      verbose = 1, 
                      gamma = 0
)

# Predict Test data set score
y_pred <- predict(xgbmodel, data.matrix(test), ntree=xgbmodel$bestInd)

# Extract second column's value that correspond to "Critical factor = 1"
y_pred <- data.frame(matrix(y_pred, byrow = TRUE, ncol = 2))[, 2]

# Calculate RMSE based on predicted and actual values
RMSE <- sqrt(mean((test.target-y_pred)^2))  # test1637
RMSE

# RMSE: 0.3590026; 446  rounds; eta = 0.04;  subsample = 0.75; colsample_bytree = 0.75 - reg:linear
# RMSE: 0.3742767; 3000 rounds; eta = 0.04;  subsample = 0.75; colsample_bytree = 0.75 - reg:linear
# RMSE: 0.3678386; 2000 rounds; eta = 0.04;  subsample = 0.75; colsample_bytree = 0.75 - multi:softprob
# RMSE: 0.3586859; 1200 rounds; eta = 0.025; subsample = 0.70; colsample_bytree = 0.70 - multi:softprob
# RMSE: 0.3596287; 1200 rounds; eta = 0.03;  subsample = 0.70; colsample_bytree = 0.70 - multi:softprob
# RMSE: 0.3578677; 1200 rounds; eta = 0.02;  subsample = 0.70; colsample_bytree = 0.70 - multi:softprob
# RMSE: 0.3576444; 1100 rounds; eta = 0.02;  subsample = 0.70; colsample_bytree = 0.70 - multi:softprob
# RMSE: 0.3559322; 1100 rounds; eta = 0.02;  subsample = 0.70; colsample_bytree = 0.70 - multi:softprob
# RMSE: 0.3563522;  500 rounds; eta = 0.02;  subsample = 0.75; colsample_bytree = 0.75 - multi:softprob
# RMSE: 0.3563522; 1000 rounds; eta = 0.02;  subsample = 0.75; colsample_bytree = 0.75 - multi:softprob
# RMSE: 0.3792566; 1200 rounds; eta = 0.002; subsample = 0.75; colsample_bytree = 0.75 - multi:softprob

## ATTACH PREDICTIONS TO DAT
y_pred_mm <- predict(xgbmodel, data.matrix(mm), ntree = xgbmodel$bestInd)



dat$score <- data.frame(matrix(y_pred_mm, byrow = TRUE, ncol = 2))[, 2]

## Identify each row as test / train
dat$Test <- iiTest
dat$Train <- iiTrain

##==============================================================================
## SAVE RESULTS
##==============================================================================

saveRDS(dat, "DATA/30_xgboost_data.Rds")
saveRDS(xgbmodel, "DATA/30_xgboost_model.Rds")


