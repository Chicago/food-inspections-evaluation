
weather <- read.csv("./DATA/weather-update.csv")
weather$date <- as.POSIXct(strptime(weather$date, format="%m/%d/%y"))
weather <- subset(weather, date < as.POSIXct("2014-10-31") &
                    date >= as.POSIXct("2014-08-28"))

n <- nrow(weather)
weather <- weather[n:1,]
threeDay <- weather[2:(n-2),colnames(weather)!="date"] + 
            weather[3:(n-1),colnames(weather)!="date"] +
            weather[4:(n-0),colnames(weather)!="date"] 
threeDay <- threeDay / 3
threeDay$date <- weather$date[1:(n-3)]

food_license <- foodInspect[,c("license_","inspection_date")]
food_license$date <- food_license$inspection_date

food_license$row <- match(food_license$date, threeDay$date)

rm(food_license, threeDay, n, weather); gc()