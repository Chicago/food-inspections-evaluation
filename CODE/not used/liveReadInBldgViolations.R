

myheader <- matrix(c(
  "id","NULL",
  "violation_last_modified_date","NULL",
  "violation_date","violation.date",
  "violation_code","NULL",
  "violation_status","NULL",
  "violation_status_date","NULL",
  "violation_description","character",
  "violation_location","NULL",
  "violation_inspector_comments","NULL",
  "violation_ordinance","character",
  "inspector_id","NULL",
  "inspection_number","NULL",
  "inspection_status","NULL",
  "inspection_waived","NULL",
  "inspection_category","character",
  "department_bureau","NULL",
  "address","NULL",
  "property_group","NULL",
  "latitude", "numeric",
  "longitude", "numeric",
  "location", "NULL"
), ncol=2, byrow=TRUE)


setting <- list(name="violation.date",
                func=function(from) as.POSIXct(strptime(from,format="%m/%d/%Y"))
)


mySubset <- "&$where=violation_date>to_floating_timestamp('2011-01-01T01:00:01')"

bldgViolations <- liveReadCSV(key="22u3-xenr", header=myheader, filter=mySubset, dateSetting=setting)

bldgViolations <- subset(bldgViolations, !is.na(latitude) & !is.na(longitude) & !is.na(violation_date))
bldgViolations$violation_description<- factor(bldgViolations$violation_description,levels=names(table(bldgViolations$violation_description)[order(-table(bldgViolations$violation_description))]))
bldgViolations$violation_ordinance<- factor(bldgViolations$violation_ordinance,levels=names(table(bldgViolations$violation_ordinance)[order(-table(bldgViolations$violation_ordinance))]))
bldgViolations$inspection_category<- factor(bldgViolations$inspection_category,levels=names(table(bldgViolations$inspection_category)[order(-table(bldgViolations$inspection_category))]))
#print(table(bldgViolations$violation_description))
#print(table(bldgViolations$violation_ordinance))
#print(table(bldgViolations$inspection_category))



rm(myheader, mySubset, setting); gc()


