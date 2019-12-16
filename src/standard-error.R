library(testthat)

wilson_score_interval <- function(p, n, confidence) {
  z <- qnorm((1 + confidence) / 2)
  fixed <- p + z**2 / (2 * n)
  shift <- z * sqrt(
    (p * (1 - p) + z**2 / (4 * n)) / n
  )
  denominator <- 1 + z**2 / n
  list(lower = (fixed - shift) / denominator,
       upper = (fixed + shift) / denominator)
}


wald_standard_error <- function(p, n, confidence) {
  sqrt(p / n)
}


wilson_standard_error_wrong <- function(p, n, confidence) {
  z <- qnorm((1 + confidence) / 2)
  sqrt(
    (p * (1 - p) + z**2 / (4 * n)) / n
  )
}


wilson_standard_error <- function(p, n, confidence) {
  z <- qnorm((1 + confidence) / 2)
  sqrt(
    (p * (1 - p) + z**2 / (4 * n)) / n
  ) / (1 + z**2 / n)
}


#' Plot a comparison of standard error functions.
#' 
#' This plot shows that the Wald standard error
#' underestimates error for small rates, as expected.
#' The Wald confidence interval shifts the middle of
#' the interval to larger values. Constructing a
#' standard error from Wilson score would underestimate
#' that large error because it loses the middle of
#' the interval. Therefore, someone decided to modify
#' the standard error by removing the denominator.
#' That does increase its value for small n.
#' 
#' @param n This is the number of observations.
plot_compare_standard_error <- function(n) {
  confidence <- 0.95
  log_x <- seq(-3, 0, 0.1)
  x <- 10**log_x
  plot(log_x, wald_standard_error(x, n, confidence),
       col = "green")
  lines(log_x, wilson_standard_error(x, n, confidence),
       col = "black")
  lines(log_x, wilson_standard_error_wrong(x, n, confidence),
        col = "red")
}


paper_numbers = data.frame(list(
  n = c(
    1, 1, 6, 15,
    1, 6, 7, 13, 3,
    4, 4, 18, 4,
    3, 20, 49, 18,
    13, 59, 16),
  p = c(
    1, 1, 0.8333, 0.4667,
    0, 1, 0.4286, 0.5385, 1,
    .5, .75, 0.6667, 0.5,
    1, 0.6, 0.5306, 0.6111,
    0.3846, 0.3898, 0.5),
  w_minus = c(
    0.2065, 0.2065, 0.4365, 0.2481,
    0, 0.6097, 0.1582, 0.2914, 0.4385,
    0.15, 0.3006, 0.4375, 0.15,
    0.4385, 0.3866, 0.3938, 0.3862,
    0.1771, 0.2758, 0.28),
  w_plus = c(
    1, 1, 0.9699, 0.6988,
    0.7935, 1, 0.7495, 0.7679, 1,
    0.85, 0.9544, 0.8372, 0.85,
    1, 0.7812, 0.6630, 0.7969,
    0.6448, 0.5173, 0.72)
))


test_that("paper numbers match computed", {
  confidence <- 0.95
  result <- wilson_score_interval(
    paper_numbers$p, paper_numbers$n, confidence
  )
  tolerance <- 0.001
  for (i in 1:length(result)) {
    expect(abs(result$lower[i] - paper_numbers$w_minus[i]) < tolerance,
           paste("no match:", result$lower[i], paper_numbers$w_minus[i]))
  }
})


standard_error_rates <- function(rate, n) {
  cases <- rate * n
  error <- sqrt(rate / n)
  small <- cases <= 5
  error[small] <- (
    ((5 - cases[small]) / n + cases[small] * sqrt(5 / n**2)) / 5)
  error
}

standard_error_rates_no_fix <- function(rate, n) {
  cases <- rate * n
  sqrt(rate / n)
}

plot_rates <- function(n) {
  log_rate <- seq(-3, 0, 0.1)
  rate <- 10**log_rate
  plot(log_rate, standard_error_rates_no_fix(rate, n),
         col = "green")
  points(log_rate, standard_error_rates(rate, n))
}
