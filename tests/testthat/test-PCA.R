test_that("standard deviations are equal", {
  set.seed(17)
  y <- matrix(rnorm(101*10), 101, 10)
  expect_equal(PCA(y)$sdev, prcomp(y, scale = TRUE)$sdev, tolerance = 1e-6)
  expect_equal(PCA_using_SVD(y)$sdev, prcomp(y, scale = TRUE)$sdev)

  z <- matrix(1:24, 8)
  expect_equal(PCA_using_SVD(z)$sdev, prcomp(z, scale = TRUE)$sdev)

  expect_equal(PCA(as.matrix(USArrests))$sdev, prcomp(USArrests, scale. = TRUE)$sdev, tolerance = 1e-6)
  expect_equal(PCA_using_SVD(as.matrix(USArrests))$sdev, prcomp(USArrests, scale. = TRUE)$sdev)
})

test_that("rotation matrices are equal",{
  set.seed(17)
  y <- matrix(rnorm(101*10), 101, 10)
  expect_equal(PCA_using_SVD(y)$rotation, prcomp(y, scale = TRUE)$rotation)

  z <- matrix(1:24, 8)
  expect_equal(PCA_using_SVD(z)$rotation, prcomp(z, scale = TRUE)$rotation)
})

test_that("percentage of variance examples", {
  library(FactoMineR)
  library(factoextra)
  set.seed(17)
  y <- matrix(rnorm(101*10), 101, 10)
  expect_equal(variance_explained_by_PCA(y), get_eigenvalue(FactoMineR::PCA(y, graph = FALSE, ncp = 10)), tolerance = 1e-8)

  z <- matrix(1:24, 8)
  expect_equal(variance_explained_by_PCA(z), get_eigenvalue(FactoMineR::PCA(z, graph = FALSE, ncp = 3)), tolerance = 1e-8)

  data(decathlon2)
  expect_equal(variance_explained_by_PCA(decathlon2[1:23, 1:10]), get_eigenvalue(FactoMineR::PCA(decathlon2[1:23, 1:10], graph = FALSE, ncp = 10)), tolerance = 1e-8)
})
