
load("./DATA/weather.Rdata")

n <- nrow(weather)
weather <- weather[n:1,]
threeDay <- weather[2:(n-2),colnames(weather)!="date"] + 
            weather[3:(n-1),colnames(weather)!="date"] +
            weather[4:(n-0),colnames(weather)!="date"] 
threeDay <- threeDay / 3
threeDay$date <- weather$date[1:(n-3)]

food_license <- foodInspect[,c("license_","inspection_date")]
food_license$date <- as.Date(food_license$inspection_date)
food_license$row <- sapply(1:nrow(food_license), function(row) which(threeDay$date==food_license$date[row]))


foodInspect <- cbind(foodInspect,threeDay[food_license$row,colnames(threeDay)!="date"])

rm(food_license, threeDay, n, weather); gc()