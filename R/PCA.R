#' Principal Component Analysis
#'
#' @param x matrix of data to find the principle components of
#' @export
PCA <- function(x){
  # make into appropriate form? (matrix, etc.)

  # store variables
  N <- dim(x)[1]

  # find the means of our columns
  xbar <- apply(x, MARGIN = 2, FUN = mean)

  # find centered variables (center by column)
  B <- x - matrix(rep(xbar, each = N), N)

  # find covariance matrix
  S <- t(B)%*%B/(N-1)

  eigens <- eigen(S)
  return(list(sdev = sqrt(eigens$values), rotation = eigens$vectors))
}

# next ideas: PCA using SVD instead of eigenvalues, other dimension reduction techniques (https://www.datanovia.com/learn/machine-learning/dimension-reduction/correspondence-analysis)
