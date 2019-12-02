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


test_that("mean_age_from_interpolation matches exact value", {
  nx = rep(1, 50)
  x = c(0, cumsum(nx))
  mx = rep(0.01, 50)
  lx = exp(-mx * x[1:50])
  lx_integrated = (exp(-mx * x[1:50]) - exp(-mx * x[2:51])) / mx
  ax <- mean_age_from_interpolation(lx, lx_integrated, nx)
  constant_ax <- constant_mortality_mean_age(mx, nx)
  expect(max(abs(ax - constant_ax) / constant_ax) < 1e-4)
})


test_that("population_from_survival for no death", {
  px <- rep(1, 10)
  survive <- population_from_survival(px, l0 = 1)
  expect_equal(length(survive), 10)
  expect(max(abs(survive - 1)) < 1e-8)
})


test_that("population_from_survival l0 changes it", {
  px <- c(.9, .8)
  survive <- population_from_survival(px, l0 = 7)
  expect_equal(survive[1], 7)
  expect_lt(survive[2], 7)
})


test_that("population_from_survival matches by-hand", {
  px <- c(0.9, .85, 0.7)
  survive <- population_from_survival(px)
  expect(abs(survive[3] - 0.9 * 0.85) < 1e-7)
})


test_that("interpolate_integral works for a horizontal line", {
  lx <- rep(3, 5)
  nx <- c(0.1, 1, 2.4, 6, 7)
  lx_integrated <- interpolate_integral(lx, nx)
  expect_equal(length(lx_integrated), length(lx))
  expected <- lx * nx
  # Check all but last because it is forced to zero at end.
  expect(max(abs(lx_integrated[1:length(lx) - 1] - expected[1:length(lx) - 1])) < 1e-5,
         "integral of constant value isn't constant")
})


test_that("interpolate_integral works for a descending line", {
  x <- seq(0, 50, 5)
  nx <- x[2:length(x)] - x[1:length(x) - 1]
  lx <- (-x[1:length(nx)] / 50 + 1)
  expected <- -(1 / 100) * ((x[1:length(lx)] + nx)**2 - x[1:length(lx)]**2) + nx
  lx_integrated <- interpolate_integral(lx, nx)
  cat(expected)
  expect_equal(length(lx_integrated), length(lx))
  expect(max(abs(lx_integrated - expected)) < 1e-5,
         "integral of descending line didn't work")
})
