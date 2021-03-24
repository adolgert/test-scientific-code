mean_age_naive <- function(mx, nx) {
  expx <- exp(-mx * nx)
  (1 / mx) - (nx * expx) / (1 - expx)
}


mean_age_taylor <- function(mx, nx) {
  mn <- mx * nx
  (nx / 2) * (1 - mn / 6 * (1 - mn**2 / 60))
}


#' Pade approximant to the mean age
#' 
#' This isn't any better than the Taylor series.
mean_age_pade <- function(mx, nx) {
  mn <- mx * nx
  nx * (1 / 2 - mn / 3 + 3 * mn**2 / 24) / (1 - mn / 2 + mn**2 / 6 - mn**3 / 24)
}


#' Plots a demonstration of failure of naive method.
#' 
#' Call with plot_mean_age_naive_low_values(-3, 7, 1)
plot_mean_age_naive_low_values <- function(high, low, age_width) {
  mx <- 10**(-(seq(high, low, 0.02)))
  nx <- rep(age_width, length(mx))
  ax1 <- mean_age_naive(mx, nx)
  plot(log10(mx), ax1, col = "black", pch = 8)
  ax3 <- mean_age_taylor(mx, nx)
  points(log10(mx), ax3, col = "blue")
  ax4 <- mean_age_pade(mx, nx)
  points(log10(mx), ax4, col = "green")
}


#' Plots a demonstration correction.
#' 
#' Call with plot_mean_age_naive_low_values(5, 7, 1)
plot_constant_mortality_mean_age <- function(high, low, age_width) {
  mx <- 10**(-(seq(high, low, 0.02)))
  nx <- rep(age_width, length(mx))
  ax <- constant_mortality_mean_age(mx, nx)
  plot(log10(mx), ax)
}

#' Given mortality, calculate mean age of death.
#' 
#' This assumes the mortality rate is constant
#' across the age interval. When the mortality
#' rate is small, this uses a Taylor series to
#' do the calculation so that the result doesn't
#' give wild results. This uses a smooth interpolation
#' between the two functions.
#' 
#' @param mx Mortality rate, per person, per year.
#' @param nx Width of each interval, in years.
#' @return Mean age of death within the interval.
constant_mortality_mean_age <- function(mx, nx) {
  # The low-mortality polynomial is excellent, even out to mu=1.
  # The goal is to get a monotonic prediction even for low precision.
  lower_bound = 1e-5  # Taylor expansion below this.
  upper_bound = 1e-4  # regular calculation above this.
  low <- mx <= upper_bound
  high <- mx >= lower_bound

  mid <- low & high  # Interpolate between the two.
  mid_fraction <- (mx[mid] - lower_bound) / (upper_bound - lower_bound)
  
  ax <- vector(mode = "numeric", length = length(nx))
  axl <- vector(mode = "numeric", length = length(nx))
  axh <- vector(mode = "numeric", length = length(nx))
  
  # Do the version where mx is large enough.
  nxh <- nx[high]
  mxh <- mx[high]
  expx <- exp(-mxh * nxh)
  axh[high] <- (1 / mxh) - (nxh * expx) / (1 - expx)
  
  nxl <- nx[low]
  mn <- mx[low] * nx[low]
  # a_x = n/2 - m n^2 / 12 + m^3 n^4 / 720 - m^5 n^6/30240
  axl[low] <- (nxl / 2) * (1 - mn / 6 * (1 - mn**2 / 60))

  ax[low] <- axl[low]
  ax[high] <- axh[high]
  ax[mid] <- (1 - mid_fraction) * axl[mid] + mid_fraction * axh[mid]
  ax
}


#' Given survival and its integral, estimate mean age of death.
#' 
#' This integral comes from Greville's work in the 1930s and 1940s.
#' It converges quickly to the value for mean age of death.
#' 
#' This equation comes from the definition of ax as the mean
#' age of death within an interval.
#' 
#' $$
#' \frac{{}_na_x / n_x) = \frac{\mbox{average lx} - \mbox{lx at end of interval}}
#'   {\mbox{lx at beginning of interval} - \mbox{lx at end of interval}}.
#' $$
#'   
#' Keyfitz shows this by partial integration of the numerator
#' of ax in _A life table that agrees with the data I,_ JASS, (1966).
#' 
#' @param lx Survival from birth, $l_x$, as a fraction of 1. Not 100,000.
#' @param lx_integrated Integral over the age range of lx,
#'        $\int_0^nl_xdx$. This
#'        will be an estimate using splines.
#' @param nx The width, $n_x$, of each age range, same length as lx and
#'        lx_integrated.
#' @return Mean age of death, ${}_na_x$, in each age range.
mean_age_from_interpolation <- function(lx, lx_integrated, nx) {
  l = length(nx)
  (lx_integrated[1:(l - 1)] - nx[1:(l - 1)] * lx[2:l]) /
    (lx[1:(l - 1)] - lx[2:l])
}


#' Given mortality rate and mean age of death, calculate survival.
#' 
#' This calculation is exact if the mean age of death is exact.
#' 
#' @param mx Mortality rate over each interval.
#' @param ax Mean age of death within each interval.
#' @param nx The width of each age interval.
#' @return Survival, px, over each interval.
survival_from_mortality_rate <- function(mx, ax, nx) {
  (1 - mx * ax) / (1 + mx * (nx - ax))
}


#' Fraction of population surviving to each age.
#' 
#' @param px Fraction that survive an interval.
#'           The first value will always be l0.
#' @param l0 Initial number of people (default to 1)
#' @return Fraction of individuals at the start of
#'         each interval. Same length as px on input.
population_from_survival <- function(px, l0=1) {
  px[px > 1] <- 1  # ax is sometimes too high.
  px[px < 0] <- 0
  lx_shifted <- cumprod(px)
  l0 * c(1, lx_shifted[1:(length(lx_shifted) - 1)])
}


#' Iterative application of graduation method.
#' 
#' This applies Greville's graduation method, except that
#' Greville used a cubic b-spline and this method can use
#' an arbitrary interpolation method. Recent work has shown
#' that using a monotonic spline improves stability of this
#' technique, so this makes that possible.
#' 
#' @param mx Mortality rate, ${}_nm_x$, over each age interval.
#' @param nx Width, $n_x$ of each age interval.
#' @param interpolation_method A function that will interpolate
#'        surviving population and return the integral over
#'        the population within each interval.
#' @param max_error The stopping condition is that, on the last
#'        iteration, no value of the mean age changed more than
#'        this amount.
#' @return Mean age of death within each interval.
graduate_mean_age <- function(mx, nx, interpolation_method, max_error=1e-9) {
  ax <- constant_mortality_mean_age(mx, nx)
  for (iteration_idx in 1:20) {
    px <- survival_from_mortality_rate(mx, ax, nx)
    lx <- population_from_survival(px)
    lx_integrated <- interpolation_method(lx, nx)
    # The interpolation doesn't give a value for the last mean age.
    ax_next <- c(mean_age_from_interpolation(lx, lx_integrated, nx), ax[length(ax)])
    if (max(abs(ax_next - ax)) < max_error) {
      return(list(ax = ax_next, iterations = iteration_idx))
    }
    ax <- ax_next
  }
  warning("mean age did not converge")
  list(ax = ax, iterations = iteration_idx)
}


#' Greville's original graduation method.
#' 
#' It's a simple cubic spline fit and should agree with the
#' more modular one when used with a non-monotonic spline.
graduate_mean_age_greville <- function(mx, nx, max_error=1e-9) {
  n <- length(nx)
  # The first five-year age range is the fourth entry.
  # The known algorithm turns the first ages into a single
  # five-year age range. This is a bit lazy.
  low <- 4:(n - 2)
  mid <- 5:(n - 1)
  high <- 6:n

  ax <- constant_mortality_mean_age(mx, nx)
  for (iteration_idx in 1:20) {
    px <- survival_from_mortality_rate(mx, ax, nx)
    px[px < 0] <- 0
    px[px > 1] <- 1
    lx <- population_from_survival(px)
    dx <- c(lx[1:(n - 1)] - lx[2:n], lx[n])
    ax_next = nx[mid] * (-dx[low] + 12 * dx[mid] + dx[high]) / (24 * dx[mid])
    # The interpolation doesn't give a value for the last mean age.
    ax_next <- c(ax[1:4], ax_next, ax[length(ax)])
    cat(paste(ax_next, "\n"))
    if (max(abs(ax_next - ax)) < max_error) {
      return(list(ax = ax_next, iterations = iteration_idx))
    }
    ax <- ax_next
  }
  warning("mean age did not converge")
  list(ax = ax, iterations = iteration_idx)
}


#' The smooth mortality rate used for graduation.
#' 
#' If the population is l_x, which is the survival,
#' then hazard rate is mu = -(1/lx) * (d lx / dx).
smooth_population <- function(mx, ax, nx) {
  px <- survival_from_mortality_rate(mx, ax, nx)
  lx <- population_from_survival(px)
  x <- c(0, cumsum(nx))
  y <- c(lx, 0)
  # The returned function can do derivatives but not integrals.
  splinefun(x, y, method = "monoH.FC")
}

smooth_mortality <- function(mx, ax, nx) {
  interpolation <- smooth_population(mx, ax, nx)
  function(x) {
    -interpolation(x, deriv = 1) / interpolation(x)
  }
}


#' Interpolate input values and integrate them over age interval.
#' 
#' This is an interpolator for Greville's method.
#' It uses the built-in R splines interpolators in order to
#' get interpolation constants, which it then integrates.
#' 
#' @param lx The population to integrate
#' @param nx Width of each age integral, same length as lx.
#' @return Integral of lx over each age integral.
interpolate_integral <- function(lx, nx) {
  x <- c(0, cumsum(nx))
  y <- c(lx, 0)
  # The returned function can do derivatives but not integrals.
  interpolation <- splinefun(x, y, method = "fmm")
  # We pull out its function environment in order to
  # get the coefficients that it saved.
  interp_environment <- rlang::fn_env(interpolation)
  n <- length(nx)
  coefficients <- interp_environment$z
  # a + b*x + c*x^2 + d*x^3
  a <- coefficients$y[1:n]
  b <- coefficients$b[1:n]
  c <- coefficients$c[1:n]
  d <- coefficients$d[1:n]
  # Integrate
  a * nx + (b / 2) * nx**2 + (c / 3) * nx**3 + (d / 4) * nx**4
}


#' Cubic interpolation not considering boundaries
#' 
#' This is the standard cubic interpolant, the one Greville
#' used. It assumes $y(t) = a + bt + ct^2 + dt^3$
#' with conditons $y(-n) = l_{x-n}$, $y(0)=l_x$,
#' $y(n)=l_{x+n}$, and $y(2n)=l_{x+2n}$.
#' 
#' @param lx The value of the function.
#' @param nx The width of each x-axis interval.
#'           Assumes these are all the same width.
cubic_interpolation <- function(lx, nx, t) {
  stopifnot(all(abs(nx - nx[1]) < 1e-7))
  stopifnot(length(t) == 1)
  x <- c(0, cumsum(nx))
  greater_than <-(1:x)[t >= x]
  m <- greater_than[length(greater_than)]

  t <- t - x[m]
  l_n <- lx[m - 1]
  l <- lx[m]
  ln <- lx[m + 1]
  l2n <- lx[m + 2]
  n <- lx[m]
  (1 / (6 * n**3)) * (
    6 * l * n**3 + 
    n**2 * t * (
      -3 * l - l2n + 6 * ln - 2 * l_n
    ) +
    3 * n * t**2 * (
      -2 * l + ln + l_n
    ) +
    t**3 * (
      3 * l + l2n - 3 * ln - l_n
    )
  )
}


interpolate_integral_third_cubic <- function(lx, nx) {
  x <- c(0, cumsum(nx))
  y <- c(lx, 0)
  n <- length(nx)
  n0 <- 1:(n - 3)  # x-n
  n1 <- 2:(n - 2)  # x
  n2 <- 3:(n - 1)  # x+n
  n3 <- 4:n        # x+2n
  # n_L_x = (nx / 2) * (l_x + l_x+n) + (nx/24) * (d_x+n - d_x-n)
  answer1 <- (n / 24) * (-lx[n0] + 13 * (lx[n1] + lx[n2]) - lx[n3])
  answer2 <- (n1 / 2) * (lx[n1] + lx[n2]) +
    (nx[n1] / 24) * (lx[n2] - lx[n3] - (lx[n0] - lx[n1]))
}


interp_catch <- function() {
  x <- seq(0, 55, 5)
nx <- x[2:length(x)] - x[1:(length(x) - 1)]
lx <- (-x[1:length(nx)] / 50 + 1)
expected <- -(1 / 100) * ((x[1:length(lx)] + nx)**2 - x[1:length(lx)]**2) + nx
found <- interpolate_integral(lx, nx)
}

interp_plot <- function() {
  x <- seq(0, 50, 5)
  nx <- x[2:length(x)] - x[1:(length(x) - 1)]
  lx <- (-x[1:length(nx)] / 50 + 1)
  expected <- -(1 / 100) * ((x[1:length(lx)] + nx)**2 - x[1:length(lx)]**2) + nx
  interpolation <- splinefun(x[1:length(lx)], lx, method = "hyman")
  
  interp_environment <- rlang::fn_env(interpolation)
  n <- length(nx)
  coefficients <- interp_environment$z
  # a + b*x + c*x^2 + d*x^3
  a <- coefficients$y[1:n]
  b <- coefficients$b[1:n]
  c <- coefficients$c[1:n]
  d <- coefficients$d[1:n]
  x0 <- x[1:n]
  xn <- x[2:(n + 1)]
  cat(paste0("b=", b))
  cat(paste0("c=", c))
  cat(paste0("d=", d))
  cat(paste0("dx=", xn - x0))
  plot(x[1:length(lx)], lx)
  lines(x, interpolation(x), col = "green")
  points(x[1:length(a)], a, col = "blue")
}
