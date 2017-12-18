##------------------------------------------------------------------------------
## INSTALL DEPENDENCIES IF MISSING
##------------------------------------------------------------------------------

if(!"devtools" %in% rownames(installed.packages())){
    install.packages("devtools",
                     dependencies = TRUE,
                     repos = "https://cloud.r-project.org/")
}

if(!"Rcpp" %in% rownames(installed.packages())){
    install.packages("Rcpp",
                     dependencies = TRUE,
                     repos = "https://cloud.r-project.org/")
}

if(!"RSocrata" %in% rownames(installed.packages())){
    install.packages("RSocrata",
                     dependencies = TRUE,
                     repos = "https://cloud.r-project.org/")
}

if(!"data.table" %in% rownames(installed.packages())){
    install.packages("data.table",
                     dependencies = TRUE,
                     repos = "https://cloud.r-project.org/")
}

if(!"geneorama" %in% rownames(installed.packages())){
    devtools::install_github('geneorama/geneorama')
}

if(!"printr" %in% rownames(installed.packages())){
    devtools::install_github(repo = 'yihui/printr')
}

##------------------------------------------------------------------------------
## UPDATE DEPENDENCIES IF MISSING
##------------------------------------------------------------------------------

## Update to RSocrata 1.7.2-2 (or later) 
if(installed.packages()["RSocrata","Version"] < "1.7.2-2"){
    install.packages("RSocrata", 
                     repos = "https://cloud.r-project.org/")
}

## Needs recent version for foverlaps
if(installed.packages()["data.table","Version"] < "1.10.0"){
    install.packages("data.table", 
                     repos = "https://cloud.r-project.org/")
}

if(installed.packages()["geneorama","Version"] < "1.5.0"){
    devtools::install_github('geneorama/geneorama')
}
