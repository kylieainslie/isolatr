# Sample COVID-19 incubation periods
# Draws n samples from lognormal distribution with parameters fitted to COVID-19 data

inc.period.samp <- function(n){
  rlnorm(n, meanlog = 1.63, sdlog = 0.5)
}
