# Calculate test sensitivity probabilities over time
# Returns probability of positive test result at each test time based on viral load trajectory

the.test.prob <- function(test.times, iso.time, inc.period){
  C <- min(inc.period, 3.5)*runif(1)

  t <- iso.time + test.times - 1 - inc.period
  s <- t + C

  idx <- t >= -inc.period & t <= -C

  test.prob <- c(1 / (1 + exp(-(1.5 + 2.2 * s[idx]))),  # pre peak
                 1 / (1 + exp(-(1.5 - 0.2 * s[!idx])))) # post peak
  return(test.prob)
}
