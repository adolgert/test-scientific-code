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
  
  ax <- vector(mode="numeric", length = length(nx))
  axl <- vector(mode="numeric", length = length(nx))
  axh <- vector(mode="numeric", length = length(nx))
  
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
#' @param lx Survival from birth, as a fraction of 1. Not 100,000.
#' @param lx_integrated Integral over the age range of lx. This
#'        will be an estimate using splines.
#' @param nx The width of each age range, same length as lx and
#'        lx_integrated.
#' @return Mean age of death in each age range.
mean_age_from_interpolation <- function(lx, lx_integrated, nx) {
  l = length(nx)
  (lx_integrated[1:(l-1)] - nx[1:(l-1)] * lx[2:l]) /
    (lx[1:(l-1)] - lx[2:l])
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
#' @param mx Mortality rate over each age interval.
#' @param nx Width of each age interval.
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
    lx <- population_from_mortality_rate(mx, ax, nx, 1)
    lx_integrated <- interpolation_method(lx, nx)
    ax_next <- mean_age_from_interpolation(lx, lx_integrated, nx)
    if (max(abs(ax_next - ax)) < max_error) {
      return(ax_next)
    }
    ax <- ax_next
  }
  warning("mean age did not converge")
  ax
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
  interpolation <- splinefun(x, y, method="hyman")
  # We pull out its function environment in order to
  # get the coefficients that it saved.
  interp_environment <- rlang::fn_env(interpolation)
  n <- length(nx)
  coefficients <- interp_environment$z[1:n]
  # a + b*x + c*x^2 + d*x^3
  a <- coefficients$y
  b <- coefficients$b
  c <- coefficients$c
  d <- coefficients$d
  # Then integrate by hand, in Horner form.
  (((((d / 4) * nx + c / 3) * nx + b / 2) * nx) + a) * nx
}
