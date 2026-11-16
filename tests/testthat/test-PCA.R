test_that("standard deviations are equal", {
  set.seed(17)
  y <- matrix(rnorm(101*10), 101, 10)
  expect_equal(PCA(y)$sdev, prcomp(y)$sdev)
})
