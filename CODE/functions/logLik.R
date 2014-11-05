# function to calculate the binomial likelihood
logLik <- function(p,y) {
    p <- pmin(pmax(p,0.0000000000001),0.999999999999)
    -sum(y*log(p) + (1-y)*log(1-p))
}


