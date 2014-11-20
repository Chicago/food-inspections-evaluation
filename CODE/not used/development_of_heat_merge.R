foodInspect$heat_burglary <- merge_heat(events=burglary, dateCol="date", window=90, nGroups=CPUs)
crime

dat
CUR <- dat[1789]$Inspection_Date
LAT <- dat[1789]$Latitude
LON <- dat[1789]$Longitude

WIN <- 90

## "Current" crime
crime[Date >= (CUR - WIN) & Date <= CUR,
      list(Latitude, Longitude),
      keyby = Date]
## KDE based on "Current" crime and current lat/long
crime[Date > (CUR - WIN) & Date < CUR,
      kde(new=c(LAT, LON), x=Latitude, y=Longitude, h = c(.01, .01))]

mydat <- dat[1789:1810]

## Mydat (relevant fields only)
mydat[ , Inspection_ID, keyby = list(Begin = Inspection_Date - WIN,
                                     End = Inspection_Date,
                                     Latitude,
                                     Longitude)]
## Merge
foverlaps(x = mydat[i = 1, 
                    j = list(Inspection_ID,
                             Latitude,
                             Longitude), 
                    keyby = list(start = Inspection_Date - WIN,
                                 end = Inspection_Date)],
          y = crime[i = TRUE,
                    list(Latitude, 
                         Longitude), 
                    keyby=list(start = Date, 
                               end = Date)],
          type = "any")


foverlaps(x = mydat[, j = list(Inspection_ID, Latitude, Longitude), 
                    keyby = list(start = Inspection_Date - WIN, end = Inspection_Date)],
          y = crime[i = TRUE, list(Latitude, Longitude),  
                    keyby=list(start = Date,  end = Date)],
          type = "any")[ , kde(new=c(i.Latitude[1], i.Longitude[1]), 
                               x = Latitude, y = Longitude, h = c(.01, .01)),
                        keyby = Inspection_ID]
crime[Date >= (CUR - WIN) & Date <= CUR,
      kde(new=c(LAT, LON), x=Latitude, y=Longitude, h = c(.01, .01))]

