#library(plyr)
#library(data.table)
#library(RSocrata)


myheader <- matrix(c(
  "id", "NULL",
  "license_id", "NULL",
  "account_number", "NULL",
  "site_number", "NULL",
  "legal_name", "NULL",
  "doing_business_as_name", "character",
  "address", "character",
  "city", "character",
  "state", "character",
  "zip_code", "character",
  "ward", "character",
  "precinct", "character",
  "police_district", "character",
  "license_code", "NULL",
  "license_description", "character",
  "license_number", "character",
  "application_type","character",
  "application_created_date","NULL",
  "application_requirements_complete","NULL",
  "payment_date","biz.date",
  "conditional_approval","NULL",
  "license_start_date","biz.date",
  "expiration_date", "biz.date",
  "approved_date","NULL",
  "date_issued", "NULL",
  "license_status", "character",
  "license_status_change_date", "NULL",
  "ssa","NULL",
  "latitude","numeric",
  "longitude","numeric",
  "location", "character"
), ncol=2, byrow=TRUE)

setting <- list(name="biz.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)

#mySubset <- "&$where=license_start_date>to_floating_timestamp('2011-01-01T01:00:01')"
mySubset <- "&$where=1=1"
#mySubset <- "&$where=license_number=2120626"



business <- liveReadCSV(key="r5kz-chrr", header=myheader, filter=mySubset, dateSetting=setting)
#business <- read.socrata(paste("http://data.cityofchicago.org/resource/","r5kz-chrr",".csv",mySubset,sep=""))

#business <- subset(business, license_status=="AAI") #license issued
#business$license_status <- NULL
#business <- subset(business, application_type %in% c("ISSUE","RENEW"))
business <- subset(business, !(application_type %in% c("C_CAPA","C_SBA")))
#business <- subset(business, !is.na(latitude) & !is.na(longitude) & !is.na(license_start_date) & !is.na(expiration_date))
business <- subset(business, !is.na(license_start_date) & !is.na(expiration_date))

#business$paidDays <- as.integer((business$license_start_date - business$payment_date)/24/60/60)
#business$paidDays[is.na(business$paidDays)] <- 0

business$precinct <- paste("w",business$ward,"p",business$precinct,sep="_")

                     

rm(myheader, mySubset, setting)
gc()