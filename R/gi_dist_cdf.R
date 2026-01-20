# Generation interval cumulative distribution function
# Returns CDF of lognormal generation interval distribution calibrated to Australian COVID-19 data

gi.dist.cdf <- function(q){
  # Change to Aus baseline GI distribution
  plnorm(q, meanlog = 1.376, sdlog = 0.567)
}
