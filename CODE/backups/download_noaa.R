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
geneorama::loadinstall_libraries(c("data.table"))
geneorama::loadinstall_libraries(c("rgdal", "spdep", "sp", "MBA"))
# geneorama::loadinstall_libraries(c("rgdal", "spdep", "sp", "elds", "MBA"))
geneorama::sourceDir("CODE/functions/")



##==========================================================================
## Hourly NOAA
##==========================================================================
# data_directory <- "DATA/20141219"
# dir.create(data_directory)
# download.file(url = "http://www1.ncdc.noaa.gov/pub/orders/cdo/447045.dat",
#               destfile = file.path(data_directory, "NOAA.dat"))


infile <- "DATA/20141219/447045.dat"

##------------------------------------------------------------------------------
## NOAA Weather Data
##------------------------------------------------------------------------------

## Monthly NOAA weather
hdr_dashes <- readLines(infile, n=2)[2]
hdr_widths <- unname(sapply(strsplit(hdr_dashes, " ")[[1]], nchar)) + 1
hdr <- gsub(" ", "", unname(unlist(read.fwf(file=infile, widths=hdr_widths, n=1,  
                                            header=FALSE, stringsAsFactors=FALSE))))
str(hdr)
weather_data <- as.data.table(read.fwf(file=infile, widths=hdr_widths, n=-1, 
                                       skip=2, header=FALSE, 
                                       stringsAsFactors=FALSE))
weather_data_backup <- copy(weather_data)

for (col in colnames(weather_data)) {
    set(weather_data, 
        i = which(weather_data[,col,with=FALSE]==-9999), 
        j = col, 
        value = NA)
}
setnames(weather_data, hdr)
weather_data[ , STATION_NAME := gsub("^ +| $+", "", STATION_NAME)]
geneorama::NAsummary(weather_data)
# geneorama::wtf(temp <- weather_data[1:10000]);rm(temp)
# dcast(weather_data, DATE~STATION_NAME, value.var = "TPCP")
# str(weather_data)
# weather_data
# geneorama::NAsummary(weather_data)
# str(weather_data)


weather_data[,DATE:=as.IDate(as.character(DATE), "%Y%m%d")]

infile
saveRDS(weather_data, gsub("\\.dat", ".Rds", infile))

# ## OHARE ONLY 
# weather_data <- weather_data[STATION_NAME=="CHICAGO OHARE INTERNATIONAL AIRPORT IL US"]
# weather_data <- 
#     weather_data[,list(date = DATE, 
#                        prcp_count = DP01, 
#                        prcp_tot = TPCP, 
#                        temp_avemax = MMXT * 9 / 5 / 10 + 32, 
#                        temp_avemin = MMNT * 9 / 5 / 10 + 32, 
#                        temp_ave = MNTM * 9 / 5 / 10 + 32)]
# weather_data
# ggplot(melt(weather_data[,c(1,4:6),with=F], "date")) + 
#     aes(date, value, colour=variable) + geom_point() + geom_line()



