
# Experiments with glmnet fits


## Load data (hidden:)

stop()

##==============================================================================
## INITIALIZE
##==============================================================================
## Remove all objects; perform garbage collection
rm(list=ls())
gc(reset=TRUE)
## Check for dependencies
if(!"geneorama" %in% rownames(installed.packages())){
    if(!"devtools" %in% rownames(installed.packages())){install.packages('devtools')}
    devtools::install_github('geneorama/geneorama')}
## Load libraries
geneorama::detach_nonstandard_packages()
# geneorama::loadinstall_libraries(c("geneorama", "data.table"))
geneorama::loadinstall_libraries(c("data.table", "glmnet", "ggplot2", "caret"))
geneorama::sourceDir("CODE/functions/")

##==============================================================================
## DEFINE GLOBAL VARIABLES / MANUAL CODE
##==============================================================================
DataDir <- "DATA/20141110"

##==============================================================================
## LOAD CACHED RDS FILES
##==============================================================================
dat <- readRDS(file.path(DataDir, "dat_with_inspector.Rds"))
## Remove NA's
dat[,.N,is.na(heat_burglary)]
dat <- dat[!is.na(heat_burglary)]
## Add criticalFound variable to dat:
dat[ , criticalFound := pmin(1, criticalCount)]
## Set the key for dat
setkey(dat, Inspection_ID)
## Match time period of original results
# dat <- dat[Inspection_Date < "2013-09-01" | Inspection_Date > "2014-07-01"]
dat[, .N, Results]
## Remove records where an inspection didn't happen
dat <- dat[!Results %in% c('Out of Business','Business Not Located','No Entry')]


## Define the model matrix
##==============================================================================
## CREATE MODEL DATA
##==============================================================================
xmat <- dat[ , list(criticalFound,
                    Inspector_Assigned,
                    pastSerious = pmin(pastSerious, 1),
                    ageAtInspection = ifelse(ageAtInspection > 4, 1L, 0L),
                    pastCritical = pmin(pastCritical, 1),
                    consumption_on_premises_incidental_activity,
                    tobacco_retail_over_counter,
                    temperatureMax,
                    heat_burglary = pmin(heat_burglary, 70),
                    heat_sanitation = pmin(heat_sanitation, 70),
                    heat_garbage = pmin(heat_garbage, 50),
                    # risk = as.factor(Risk),
                    # facility_type = as.factor(Facility_Type),
                    timeSinceLast),
            keyby = Inspection_ID]
mm <- model.matrix(criticalFound ~ . -1, data=xmat[ , -1, with=F])
mm <- as.data.table(mm)

##==============================================================================
## CREATE TEST / TRAIN / EVAL PARTITIONS
##==============================================================================
iiTrain <- dat[ , which(Inspection_Date < "2014-07-01")]
iiEval <- dat[ , which(Inspection_Date > "2014-07-01")]
yyTrain <- dat[iiTrain, criticalFound]
yyEval <- dat[iiEval, criticalFound]

## Try some different assumptions in the model
##==============================================================================
## GLMNET MODELS
##==============================================================================
# fit ridge regression, alpha = 0, only inspector coefficients penalized
# pen <- ifelse(grepl("^Inspector.Assigned", colnames(mm)), 1, 0)
# m0 <- glmnet(x = as.matrix(mm[iiTrain]),
#              y = xmat[iiTrain,  criticalFound],
#              family = "binomial",
#              alpha = 0,
#              penalty.factor = pen)
# m1 <- glmnet(x = as.matrix(mm[iiTrain]),
#              y = xmat[iiTrain,  criticalFound],
#              family = "binomial",
#              penalty.factor = pen)
# m2 <- glmnet(x = as.matrix(mm[iiTrain]),
#              y = xmat[iiTrain,  criticalFound],
#              family = "binomial",
#              alpha = 0)
m3 <- glmnet(x = as.matrix(mm[iiTrain]),
             y = xmat[iiTrain,  criticalFound],
             family = "binomial")

model_coef <- m3$beta[,ncol(m3$beta)]
insp_coef <- model_coef[grepl("^Inspector.Assigned",names(model_coef))]

hist(insp_coef, 20)
hist(insp_coef, 10)
coef_breaks <- c(-2.0, -1.0, -0.5, 0, 0.5, 1.4, 3.0)
insp_coef_cut <- cut(insp_coef, 
                     breaks = coef_breaks, 
                     labels = LETTERS[1:(length(coef_breaks)-1)])
table(insp_coef_cut)

insp_coef_cut
insp_table <- data.table(insp = gsub("Inspector_Assigned","",names(insp_coef)),
                         insp_grade = insp_coef_cut,
                         insp_coef)

insp_table

# dat$Inspector_Grade <- insp_table$insp_grade[match(dat$Inspector_Assigned, insp_table$insp)]

saveRDS(insp_table, file.path(DataDir, "insp_table.Rds"))


