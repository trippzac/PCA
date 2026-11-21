#' Principal Component Analysis
#'
#' Performs principal component analysis on a matrix of data. This function computes
#' the eigenvalues and eigenvectors of the covariance matrix in order to return the
#' result.
#'
#' @param x matrix of data to find the principle components of
#' @param center whether or not to center the columns before finding eigenvectors
#' @param scale whether or not to scale the columns before finding eigenvectors
#' @returns A list is returned including the standard deviation of the principal components
#' and the matrix of variable loadings. The variable names and dimension names are
#' made to match the results of the built-in R function "prcomp" in order to directly
#' compare the two.
#' @note Fundamentally, this function returns the same values as the built-in function
#' "prcomp", but there have been observed numerical differences due to rounding,
#' along with differences in the returned "rotation" matrix due to differences in
#' signs of the eigenvectors and/or orderings of the eigenvectors. However, it is
#' essentially the same result for the purposes of the principal component analysis,
#' but it can be an issue when trying to directly compare their results.
#' @export
#' @examples
#' # fix a large matrix of random normal values
#' set.seed(17)
#' y <- matrix(rnorm(101*10), 101, 10)
#' PCA(y)
#'
#' # compare this to the result of the built-in function "prcomp"
#' prcomp(y, scale. = TRUE)
#'
#' # similarly, we can do this on actual data, though we require our input to be in matrix form
#' PCA(as.matrix(USArrests))
#'
#' # this is analogous to the following, which returns vectors with different signs
#' prcomp(USArrests, scale. = TRUE)
#'
PCA <- function(x, center = TRUE, scale = TRUE){
  # make into appropriate form? (matrix, etc.)
  dims <- dim(x)
  if (center){
    x <- center_columns(x)
  }
  if (scale){
    x <- scale_columns(x)
  }

  # find covariance matrix (importantly, this is the covariance matrix assuming our columns have been centered)
  S <- t(x)%*%x/(dims[1]-1)

  eigens <- eigen(S)
  # make column names in order to match formatting of prcomp (for comparison)
  rotation <- eigens$vectors
  dimnames(rotation)[2] <- list(paste0("PC", 1:dims[2]))
  return(list(sdev = sqrt(eigens$values), rotation = rotation))
}

#' Principal Component Analysis using Singular Value Decomposition
#'
#' Performs principal component analysis on a matrix of data. This function computes
#' the singular value decomposition of the matrix in order to find the result.
#'
#' @param x matrix of data to find the principle components of
#' @param center whether or not to center the columns before performing singular value decomposition
#' @param scale whether or not to scale the columns before performing singular value decomposition
#' @returns A list is returned including the standard deviation of the principal components
#' and the matrix of variable loadings. The variable names and dimension names are
#' made to match the results of the built-in R function "prcomp" in order to directly
#' compare the two.
#' @note Unlike PCA, the results of this function appear to more exactly align with
#' the results of the built-in function "prcomp".
#' @export
#' @examples
#' # fix a large matrix of random normal values
#' set.seed(17)
#' y <- matrix(rnorm(101*10), 101, 10)
#' PCA_using_SVD(y)
#'
#' # compare this to the result of the built-in function "prcomp"
#' prcomp(y, scale. = TRUE)
#'
#' # similarly, we can do this on actual data, though we require our input to be in matrix form
#' PCA_using_SVD(as.matrix(USArrests))
#'
#' # this is analogous to the following
#' prcomp(USArrests, scale. = TRUE)
#'
PCA_using_SVD <- function(x, center = TRUE, scale = TRUE){
  dims <- dim(x)
  if (center){
    x <- center_columns(x)
  }
  if (scale){
    x <- scale_columns(x)
  }

  # using singular value decomposition, and return corresponding values
  svd_result <- svd(x)
  # make column names in order to match formatting of prcomp (for comparison)
  rotation <- svd_result$v
  dimnames(rotation)[2] <- list(paste0("PC", 1:dims[2]))
  return(list(sdev = sqrt(svd_result$d^2/(dims[1] - 1)), rotation = rotation))
}

#' Percentage of Variance Explained by Principal Components
#'
#' Performs principal component analysis on a matrix of data, then returns its corresponding eigenvalues
#' and how much each principal component explains the variance of the entire data set. This is analogous
#' to the function "get_eigenvalue" in the library "factoextra".
#'
#' @param x matrix of data to find the principle components of
#' @returns A data table is returned with the eigenvalues, variance of the percentage explained by
#' the given dimension, along with the cumulative percentage explained by all the dimensions so far.
#' @note We are assuming for this function that we wish to scale and center our data in order to do the
#' computations. Additionally, we note that we are actually initially computing the singular values here
#' instead of the eigenvalues directly since the singular values are more numerically stable.
#' @export
#' @examples
#' # compute the variance explained on a randomly generated dataset and on the USArrest dataset
#' set.seed(17)
#' y <- matrix(rnorm(101*10), 101)
#' variance_explained_by_PCA(y)
#' variance_explained_by_PCA(as.matrix(USArrests))
#'
#' # compare this to the analogous function in factoextra
#' library(FactoMineR)
#' library(factoextra)
#' get_eigenvalue(FactoMineR::PCA(y, graph = FALSE, ncp = 10))
#' get_eigenvalue(FactoMineR::PCA(USArrests, graph = FALSE, ncp = 4))
#'
variance_explained_by_PCA <- function(x){
  eigenvalues <- PCA_using_SVD(x)$sdev^2 # implicitly, center and scale are set to TRUE here
  N <- length(eigenvalues)
  variance_percent <- 100 * eigenvalues / N
  cum_var_percent <- cumsum(variance_percent)

  df <- matrix(c(eigenvalues, variance_percent, cum_var_percent), ncol = 3)
  colnames(df) <- c("eigenvalue", "variance.percent", "cumulative.variance.percent")
  rownames(df) <- paste0("Dim.", 1:N)

  return(df)
}

#' Scree Plot
#'
#' Performs principal component analysis on a matrix of data, then prints a graph of the
#' amount of variance that is explained by each of the principal components. This can be used
#' to determine how many principal components to keep when performing a PCA.
#'
#' @param x matrix of data to find the principle components of
#' @note This uses the function PCA_using_SVD to find the principal components and assumes that we are
#' centering and scaling our data. This function is analogous to the function "fviz_eig" from the
#' library "factoextra".
#' @export
#' @examples
#' # graph the explained variance on a randomly generated dataset and on the USArrest dataset
#' set.seed(17)
#' y <- matrix(rnorm(101*10), 101)
#' scree_plot(y)
#' scree_plot(as.matrix(USArrests))
#'
#' # compare this to the analogous function in factoextra
#' library(FactoMineR)
#' library(factoextra)
#' fviz_eig(FactoMineR::PCA(y, graph = FALSE, ncp = 10))
#' fviz_eig(FactoMineR::PCA(USArrests, graph = FALSE, ncp = 4))
#'
scree_plot <- function(x){
  var_df <- variance_explained_by_PCA(x)
  N <- dim(var_df)[1]
  ggplot(var_df, aes(x = 1:N, y = var_df[,2])) +
    geom_col(fill = "deepskyblue") +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_text(vjust = -0.3, hjust = -0.1, aes(label = paste0(round(var_df[,2], digits=1), "%"))) +
    scale_x_continuous(breaks = 1:N, minor_breaks = NULL) +
    scale_y_continuous(limits = c(0, NA)) +
    labs(title = "Scree plot", x = "Dimensions", y = "Percentage of explained variances") +
    theme_minimal()
}

# return matrix whose columns have been centered, i.e. the means of each column are subtracted from the columns
center_columns <- function(x){
  #store variables
  N <- dim(x)[1]

  # find the means of our columns
  xbar <- apply(x, MARGIN = 2, FUN = mean)

  # find centered variables (center by column)
  return(x - matrix(rep(xbar, each = N), N))
}

# return matrix whose columns have variance 1
scale_columns <- function(x){
  #store variables
  N <- dim(x)[1]

  # find the standard deviations of the columns
  stdevs <- sqrt(apply(x, MARGIN = 2, FUN = var))

  # find centered variables (center by column)
  return(x / matrix(rep(stdevs, each = N), N))
}
