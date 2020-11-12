library(Runuran)

pdf <- function(x) {
  exp(-sqrt(1 + x^2))
}

gen <- Runuran::tdr.new(pdf = pdf, lb = -Inf, ub = Inf)


draw_distribution <- function(n) {
  Runuran::ur(gen, n)
}


mixed_gaussian <- function(x, mu, sigma, mixture) {
  mix <- mixture / sum(mixture)
  sum(mix * (1 / (sigma * sqrt(2 * pi))) * exp(-0.5 * ((x - mu) / sigma)**2))
}


# > gen <- mixed_gaussian_generator(1.0, c(0.1, 10), c(0.5, 0.5))
# Runuran::ur(gen, 10)
mixed_gaussian_generator <- function(mu, sigma, mixture) {
  curried <- function(x) mixed_gaussian(x, mu, sigma, mixture)
  Runuran::pinv.new(pdf = curried, lb = 0, ub = Inf)
}


draw_with_rejection <- function(n) {
  draws <- numeric(n)
  draw_cnt <- 0
  while (draw_cnt < n) {
    x <- Runuran::ur(gen, 2 * (n - draw_cnt))
    x <- x[x>0]
    if (length(x) == 0) {
      # Nothing to add
    } else if (draw_cnt + length(x) <= n) {
      draws[(draw_cnt + 1):(draw_cnt + length(x))] <- x
      draw_cnt <- draw_cnt + length(x)
    } else {
      draws[(draw_cnt + 1):n] <- x[1:(n - draw_cnt)]
      draw_cnt <- n
    }
  }
  draws
}
