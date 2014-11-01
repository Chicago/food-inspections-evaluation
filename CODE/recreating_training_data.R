
#recreate space20140129v01.Rdata
setwd('./')


‘gsubfn’, ‘proto’, ‘RSQLite’, ‘RSQLite.extfuns’, ‘DBI’, ‘chron’ are not available for package ‘sqldf’

library(snowfall)
# library(sqldf) Current version is incompatible with 3.0.x

# Install and load older SQLDF library 
install.packages('chron')
install.packages('proto')
install.packages('gsubfn')
DBI_0.2_5 <- "http://cran.r-project.org/src/contrib/Archive/DBI/DBI_0.2-5.tar.gz" # Compatible with RSQLite_0.9.1
RSQLite_0.9_1 <- "http://cran.r-project.org/src/contrib/Archive/RSQLite/RSQLite_0.9-1.tar.gz" # This version is compatible with sqldf_0.4_7.1
install.packages('RSQLite.exfuns')
install.packages(RSQLite_0.8_0, contriburl=NULL, type="source")
sqldf_0.4_6 <- "http://cran.r-project.org/src/contrib/Archive/sqldf/sqldf_0.4-6.tar.gz" # Compatible with R >= 2.14 https://code.google.com/p/sqldf/source/browse/trunk/DESCRIPTION?r=104
install.packages(sqldf_0.4_7, contriburl=NULL, type="source")

CPUs <- 2

#load project custom built functions
source("./CODE/myfun.R")

#read in food inspections records from SODA URL
source("./CODE/liveReadInFoodInspections.R")

#read in busines licenses 
source("./CODE/liveReadInBusinessLicense.R")

#filter to food inspections with a valid license number
foodInspect <- subset(foodInspect, license_ %in% business$license_number)



#get location, name, and license info from business license data
foodInspect <- sqldf("
                     select
                     a.inspection_id as inspection_id,
                     a.license_ as license_,
                     a.facility_type as facility_type,
                     a.risk as risk,
                     a.inspection_date as inspection_date__POSIXct,
                     a.inspection_type as inspection_type,
                     a.results as results,
                     a.pass_flag as pass_flag,
                     a.criticalCount as criticalCount,
                     a.seriousCount as seriousCount,
                     a.minorCount as minorCount, 
                     a.pastFail as pastFail,
                     a.pastCritical as pastCritical,
                     a.pastSerious as pastSerious,
                     a.pastMinor as pastMinor,
                     a.timeSinceLast as timeSinceLast,
                     a.firstRecord as firstRecord,
                     a.minDate as minDate__POSIXct, 
                     a.maxDate as maxDate__POSIXct,
                     case
                     when (a.inspection_date <= b.expiration_date and
                     a.inspection_date >= b.license_start_date) then 'Between'
                     when (a.inspection_date < b.license_start_date and
                     b.license_start_date = a.minDate) then 'Before'
                     when (a.inspection_date > b.expiration_date and
                     b.expiration_date = a.maxDate) then 'After'
                     else 'Error'
                     end as licenseRecord,
                     b.payment_date as payment_date__POSIXct,
                     b.license_start_date as license_start_date__POSIXct, 
                     b.expiration_date as expiration_date__POSIXct, 
                     b.doing_business_as_name as doing_business_as_name,
                     b.address as address,
                     b.city as city,
                     b.state as state,
                     b.zip_code as zip_code,
                     b.ward as ward,
                     b.precinct as precinct,
                     b.police_district as police_district,
                     b.license_description as license_description,
                     b.latitude as latitude,
                     b.longitude as longitude,
                     b.location as location
                     from (
                     select c.*, d.minDate, d.maxDate
                     from foodInspect c
                     left join 
                     (
                     select license_number, 
                     min(license_start_date) as minDate, 
                     max(expiration_date) as maxDate
                     from business group by license_number
                     ) d
                     on (c.license_ = d.license_number)
                     ) a
                     left join business b
                     on (a.license_ = b.license_number and
                     ((a.inspection_date <= b.expiration_date and
                     a.inspection_date >= b.license_start_date) or
                     (a.inspection_date <b.license_start_date and
                     b.license_start_date = a.minDate) or
                     (a.inspection_date >b.expiration_date and
                     b.expiration_date = a.maxDate))
                     )
                     
                     
                     ", method="name__class")


foodInspect <- subset(foodInspect,!is.na(latitude) & !is.na(longitude))


#the logistic regression target variable
foodInspect$criticalFound <- ifelse(foodInspect$criticalCount>0,1L,0L)


#age of license as of inspection date (in years)
foodInspect$ageAtInspection <- pmin(as.integer(foodInspect$inspection_date - foodInspect$minDate)/365/24/60/60,
                                    as.integer(Sys.Date() - as.Date("2006-01-01"))/365)
#hist(foodInspect$ageAtInspection[foodInspect$licenseRecord=="Between"])
#table(foodInspect$inspection_type[foodInspect$licenseRecord=="Before"])
#table(foodInspect$inspection_type[foodInspect$licenseRecord!="Before"])


#foodInspect <- subset(foodInspect, inspection_type != "License" & licenseRecord=="Between")
foodInspect <- subset(foodInspect, licenseRecord=="Between")
foodInspect$licenseRecord <- NULL



#turn some character fields into 'factor' data types
lapply(c("facility_type","risk","results"),FUN= function(x) {
  foodInspect[,x] <<- factor(foodInspect[,x],levels=names(table(foodInspect[,x])[order(-table(foodInspect[,x]))]))
  invisible()
})

#turn some character fields into 'factor' data types
#lapply(c("license_description","application_type",
#         "city","state","zip_code","ward","precinct","police_district"),FUN= function(x) {
#           business[,x] <<- factor(business[,x],levels=names(table(business[,x])[order(-table(business[,x]))]))
#           invisible()
#         })   

#turn some character fields into 'factor' data types
lapply(c("license_description"),FUN= function(x) {
  business[,x] <<- factor(business[,x],levels=names(table(business[,x])[order(-table(business[,x]))]))
  invisible()
})  


foodInspect$zip_code[foodInspect$address=="131 N CLINTON ST 1ST 27"] <- "60661"


#turn some character fields into 'factor' data types
lapply(c("license_description",
         "city","state","zip_code","ward","precinct","police_district"),FUN= function(x) {
           levs <- names(table(foodInspect[,x])[order(-table(foodInspect[,x]))])
           levs <- levs[levs != ""]
           foodInspect[,x] <<- factor(foodInspect[,x],levels=levs)
           invisible()
         })       

foodInspect <- subset(foodInspect, license_description == "Retail Food Establishment")

sum(is.na(foodInspect$zip_code))

#Add flags for other licenses held at the time of the inspection
source("./CODE/addOtherLicenses.R")




#add recent weather readings
source("./CODE/addWeather.R")


rm(business)




#read in crime data for BURGLARY
source("./CODE/liveReadInCrimes.R")
burglary <- subset(crime,crime$primary_type=="BURGLARY")
foodInspect$heat_burglary <- merge_heat(events=burglary, dateCol="date", window=90, nGroups=CPUs)
rm(crime, burglary)


###############311 Data sources##########################

#read in sanitation code violations
source("./CODE/liveReadInSanitationCode.R")
foodInspect$heat_sanitation <- merge_heat(events=sanitationComplaints, dateCol="creation_date", window=120, nGroups=CPUs)
rm(sanitationComplaints)

#read in garbage cart requests
source("./CODE/liveReadInGarbageCarts.R")
foodInspect$heat_garbage <- merge_heat(events=garbageCarts, dateCol="creation_date", window=30, nGroups=CPUs)
rm(garbageCarts)

load('./DATA/partitions.Rdata')

train <- subset(foodInspect, paste(inspection_id, license_, sep = "_") %in% partitions[['train']])
tune <- subset(foodInspect, paste(inspection_id, license_, sep = "_") %in% partitions[['tune']])
evaluate <- subset(foodInspect, paste(inspection_id, license_, sep = "_") %in% partitions[['evaluate']])


rm(list = setdiff(ls(),c('train','tune','evaluate')))
save(list=ls(),file="./DATA/recreated_training_data_20141031v01.Rdata")
