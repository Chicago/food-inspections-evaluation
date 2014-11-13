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
