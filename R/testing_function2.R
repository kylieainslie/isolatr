# Simulate testing schedule and determine time to first positive test
# Models test sensitivity over viral load trajectory and returns time of first positive result

testing.function2 <- function(test.times, iso.time, inc.period, the.scenario){
  C <- min(inc.period, 3.5)*runif(1)

  t <- iso.time + test.times - 1 - inc.period
  s <- t + C

  idx <- t >= -inc.period & t <= -C

  test.prob <- c(1 / (1 + exp(-(1.5 + 2.2 * s[idx]))),  # pre peak
                 1 / (1 + exp(-(1.5 - 0.22 * s[!idx])))) # post peak


  test.results <- runif(length(t)) < test.prob
  ttiv <- iso.time + test.times - 1
  # + test.turnaround.samp(n = length(test.times), the.scenario = the.scenario)
  first.pos <- min(ttiv[as.logical(test.results)], Inf)
  # Time results returned relative to isolation
  return(first.pos)
}
