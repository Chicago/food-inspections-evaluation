## INSTALL THESE DEPENDENCIES
install.packages("devtools",dependencies = TRUE)
install.packages("Rcpp",dependencies = TRUE)
update.packages()

## Update two packages not on CRAN using the devtools package.
devtools::install_github('geneorama/geneorama')
devtools::install_github('yihui/printr')
