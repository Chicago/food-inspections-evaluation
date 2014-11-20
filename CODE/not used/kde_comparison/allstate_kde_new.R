allstate_kde <- function (new, x, y, h) {
    nx <- length(x)
    if (length(y) != nx) 
        stop("data vectors must be the same length")
    if (any(!is.finite(x)) || any(!is.finite(y))) 
        stop("missing or infinite values in the data are not allowed")





    h <- if (missing(h)) 
        c(bandwidth.nrd(x), bandwidth.nrd(y))
    else rep(h, length.out = 2L)
  

    h <- h / 4
    ax <- (new[1]-x)        / h[1L]
    ay <- (new[2]-y)        / h[2L]
    z <- tcrossprod(matrix(dnorm(ax), , nx), 
                    matrix(dnorm(ay), , nx)) / (nx * h[1L] * h[2L])
    z
}
