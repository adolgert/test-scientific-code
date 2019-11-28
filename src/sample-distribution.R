library(Runuran)

pdf <- function(x) {
  exp(-sqrt(1 + x^2))
}

gen <- tdr.new(pdf = pdf, lb = -Inf, ub = Inf)

create <- function(n) {
  x <- ur(gen, n)
  x
}

