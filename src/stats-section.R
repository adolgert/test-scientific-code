make_zscore <- function() {
  lim <- 3
  confidence_interval <- .95
  df <- data.frame(
    x = seq(-lim, lim, 0.01)
  )
  df["y"] <- dnorm(df$x)
  df["mask"] <- 1
  z <- qnorm(0.5 * (confidence_interval + 1))
  df[(df$x > -z) & (df$x < z), "mask"] <- 0
  df
}


zscore <- function() {
  df <- make_zscore()
  ggplot(df) +
    geom_area(mapping = aes(x=x, y=y, alpha=mask))
  #geom_line(mapping = aes(x=x, y=y)) +
}
