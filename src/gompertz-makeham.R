gompertz_makeham <- function(lambda, alpha, beta) {
  force(lambda)
  force(alpha)
  force(beta)
  list(
    hazard = function(t) {
      lambda + alpha * exp(beta * t)
    },
    integrated_hazard = function(t0, t1) {
      lambda * (t1 - t0) + (alpha / beta) * (exp(beta * t1) - exp(beta * t0))
    },
    conditional_survival = function(t0, t1) {
      exp(lambda * (t1 - t0) + (alpha / beta) * (exp(beta * t1) - exp(beta * t0)))
    },
    survival = function(t) {
      exp(lambda * t + (alpha / beta) * (exp(beta * t) - 1))
    },
    pdf = function(t) {
      (lambda + alpha * exp(beta * t)) * exp(lambda * t + (alpha / beta) * (exp(beta * t) - 1))
    },
    cdf = function(t) {
      1 - exp(lambda * t + (alpha / beta) * (exp(beta * t) - 1))
    }
  )
}


lifetable <- function(model, nx) {
  #data.frame()
}