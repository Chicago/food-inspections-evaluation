## INSTALL THESE DEPENDENCIES
install.packages("devtools",
                 dependencies = TRUE,
                 repos='http://cran.us.r-project.org')
install.packages("Rcpp",
                 dependencies = TRUE,
                 repos='http://cran.us.r-project.org')

## Update two packages not on CRAN using the devtools package.
devtools::install_github(repo = 'geneorama/geneorama')
devtools::install_github(repo = 'yihui/printr')

## Update RSocrata to a particular build not yet released:
devtools::install_github(repo = 'chicago/RSocrata', ref = "sprint7")

