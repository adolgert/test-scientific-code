source("graduation-method.R")

test_that("constant_mortality_mean_age gets larger with larger n", {
  mx <- 1e-4
  nx <- 1:100 / 10
  ax <- constant_mortality_mean_age(mx, nx)
  expect(all(ax[2:length(ax)] > ax[1:length(ax) - 1]))
})


test_that("constant_mortality_mean_age gets larger with larger n for small mx", {
  mx <- 1e-9
  nx <- 1:100 / 10
  ax <- constant_mortality_mean_age(mx, nx)
  expect(all(ax[2:length(ax)] > ax[1:length(ax) - 1]))
})


test_that("constant_mortality_mean_age within bounds of nx", {
  mx <- 10**(-(5 + 4 * runif(1000)))
  nx <- rep(1, length(mx)) * c(1/365, 1/12, 1, 5)
  ax <- constant_mortality_mean_age(mx, nx)
  expect(all(ax > 0))
  expect(all(ax < nx / 2))
})


test_that("constant_mortality_mean_age goes to 0 for large mx", {
  ax <- constant_mortality_mean_age(100, 1)
  expect_lt(1e-6, ax)
})


test_that("constant_mortality_mean_age goes to 1/2 for small mx", {
  ax <- constant_mortality_mean_age(0, 1)
  expect_lt(abs(1/2 - ax), 1e-9)
  expect_gte(1/2 - ax, 0)
})


# Mean age can be written so that a and mu are together
# and mx and n are together:
# a*mx = (1-(1+n*mx) exp(-n*mx)) / (1-exp(-n*mx))
# so we use the relationship f(n*mx) = a*mx
# mx <- c(1e-9, 1e-8, 5e-8, 1e-7, 5e-7, 5e-3)
test_that("constant_mortality_mean_age scales with a, mx, n", {
  mx <- c(5e-3, 4e-3, 3e-3, 2e-3, 1e-3)
  nx = 5e-3 / mx
  ax <- constant_mortality_mean_age(mx, nx)
  expect(max(abs(ax * mx - ax[1] * mx[1])) < 1e-7)
})
