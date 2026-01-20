# Sample generation intervals (time between successive infections)
# Draws n samples from lognormal distribution calibrated to Australian COVID-19 data

gi.dist.samp <- function(n){
  # Change to Aus baseline GI distribution
  rlnorm(n, meanlog = 1.376, sdlog = 0.567)
}
