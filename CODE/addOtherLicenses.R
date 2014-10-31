

food_licenses <- foodInspect[,c("license_","inspection_date")]
biz <- business[,c("doing_business_as_name","license_number","address","license_start_date","expiration_date","license_description")]

assoc <- function(row){
  name <- biz$doing_business_as_name[biz$license_number==food_licenses$license_[row]][1]
  addr <- biz$address[biz$license_number==food_licenses$license_[row]][1]
  data <- subset(biz, doing_business_as_name == name & 
                   address == addr &
                   license_number != food_licenses$license_[row] &
                   license_start_date < food_licenses$inspection_date[row] &
                   expiration_date > food_licenses$inspection_date[row])
  table(data$license_description)
}

sfInit(parallel=TRUE, cpus=CPUs) 
export <- c("biz","food_licenses")
sfExport(list=export) 
other_licenses <- sfLapply(1:nrow(food_licenses), fun = assoc)
sfStop()

other_licenses <- do.call("rbind",other_licenses)
other_licenses <- other_licenses[,order(-colSums(other_licenses))]
other_licenses <- other_licenses[,1:10]
lapply(1:ncol(other_licenses), FUN=function(col) other_licenses[,col] <<- pmin(1,other_licenses[,col]))

names <- tolower(colnames(other_licenses))
names <- gsub("[[:punct:]]+","",names)
names <- gsub("[ ]+","_",names)

colnames(other_licenses) <- names

foodInspect <- cbind(foodInspect,other_licenses)

rm(food_licenses, other_licenses, assoc, names, biz, export)
gc()
