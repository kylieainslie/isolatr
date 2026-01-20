# Sample random household sizes for individuals in a given state
# Draws n household sizes from the state-specific distribution using inverse transform sampling

samp.hh.size <- function(n, the.state){
  r <- runif(n)
  hhs <- hhsizes(the.state)
  hh.sizes <- sapply(X = r, FUN = function(x){min(which(x < hhsizes(the.state)))})
  return(hh.sizes)
}
