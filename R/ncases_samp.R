# Sample number of secondary cases from negative binomial distribution
# Models overdispersed transmission with transmission potential (TP) and dispersion parameter (k)

ncases.samp <- function(n, TP, k){
  # number of samples, transmission potential, dispersion parameter
  rnbinom(n, size = k, mu = TP)
}
