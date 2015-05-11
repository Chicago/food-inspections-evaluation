## INSTALL THESE DEPENDENCIES
install.packages("devtools",dependencies = TRUE)
install.packages("Rcpp",dependencies = TRUE)

## UPDATE PACKAGES
## *NOTE* THIS WILL UPDATE YOUR R LIBRARIES AUTOMATICALLY
## For most users this is fine, but if you may wish to skip this step
## if you want to keep your current package versions, and update only 
## if you experience problems.
update.packages(ask = FALSE)

## Update two packages not on CRAN using the devtools package.
devtools::install_github(repo = 'geneorama/geneorama')
devtools::install_github(repo = 'yihui/printr')

## Update RSocrata to a particular build not yet released:
devtools::install_github(repo = 'chicago/RSocrata', ref = "sprint7")

