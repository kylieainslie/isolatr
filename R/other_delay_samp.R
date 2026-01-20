# Sample delays from notification to interview and interview to notifying close contacts
# Combines time to interview and interview to isolation delays for the specified TTIQ scenario

other.delay.samp <- function(n, the.scenario){

  if(the.scenario == "partial"){
    cumulative.probs.interview <- partial.interview.dat
    cumulative.probs.notify <- partial.cc.notify.dat}
  else { if(the.scenario == "optimal"){
    cumulative.probs.interview <- optimal.interview.dat
    cumulative.probs.notify <- optimal.cc.notify.dat
  } else{
    cumulative.probs.interview <- nsw.ci.interview.dat
    cumulative.probs.notify <- nsw.ci.cc.notify.dat
  }
  }

  r1 <- runif(n)
  r2 <- runif(n)

  interview.delay <- sapply(X = r1, FUN = function(x){names(cumulative.probs.interview)[min(which(x < cumulative.probs.interview))]})
  notify.delay <- sapply(X = r2, FUN = function(x){names(cumulative.probs.notify)[min(which(x < cumulative.probs.notify))]})

  return(as.numeric(interview.delay) + as.numeric(notify.delay))

}
