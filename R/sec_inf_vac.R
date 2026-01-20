# Determine which secondary infections occur given vaccination status
# Models vaccine effectiveness against transmission (VE.trans) and infection (VE.inf) for index and secondary cases

sec.inf.vac <- function(inf.times, vacc.status, sc.vac.status){
  n <- length(inf.times)
  if(n > 0){
    ( runif(n) < (1 - VE.trans*vacc.status)*(1 - VE.inf*sc.vac.status) ) # returns a vector of those that were infected
  } else{
    (vector("logical") )
  }
}
