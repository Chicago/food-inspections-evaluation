

foodInspect <- foodInspect[order(foodInspect$license_,foodInspect$inspection_date),]

id <- foodInspect$license_[1]

firstRecord <- rep(0,nrow(foodInspect))
firstRecord[1] <- 1

time <- rep(2,nrow(foodInspect))
lastTime <- foodInspect$inspection_date[1]

pastFail <- rep(0,nrow(foodInspect))
failCount <- ifelse(foodInspect$results[1]=="Fail",1,0)

pastCrit <- rep(0,nrow(foodInspect))
critCount <- foodInspect$criticalCount[1]

pastSerious <- rep(0,nrow(foodInspect))
seriousCount <- foodInspect$seriousCount[1]

pastMinor <- rep(0,nrow(foodInspect))
minorCount <- foodInspect$minorCount[1]

for (row in 2:nrow(foodInspect)){
  if (foodInspect$license_[row] == id) {
    pastFail[row] <- failCount
    pastCrit[row] <- critCount
    pastSerious[row] <- seriousCount
    pastMinor[row] <- minorCount
    time[row] <- as.integer(foodInspect$inspection_date[row] - lastTime)/365

    lastTime <- foodInspect$inspection_date[row]
    failCount <- ifelse(foodInspect$results[row]=="Fail",1,0)
    critCount <- foodInspect$criticalCount[row]
    seriousCount <- foodInspect$seriousCount[row]
    minorCount <- foodInspect$minorCount[row]
  } else {
    id <- foodInspect$license_[row]
    firstRecord[row] <- 1 
    lastTime <- foodInspect$inspection_date[row]
    failCount <- ifelse(foodInspect$results[row]=="Fail",1,0)
    critCount <- foodInspect$criticalCount[row]
    seriousCount <- foodInspect$seriousCount[row]
    minorCount <- foodInspect$minorCount[row]
  }
}
foodInspect$pastFail <- pastFail
foodInspect$pastCritical <- pastCrit
foodInspect$pastSerious <- pastSerious
foodInspect$pastMinor <- pastMinor
foodInspect$timeSinceLast <- pmin(time,2)
foodInspect$firstRecord <- firstRecord

rm(firstRecord, time, lastTime, failCount,critCount,seriousCount,minorCount, 
   id, pastFail,pastCrit,pastSerious,pastMinor, row); gc()
