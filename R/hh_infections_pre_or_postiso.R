# Reassign pre/post-isolation infections to household infections
# Randomly converts a proportion (p) of pre- or post-isolation infections to household infections, respecting household size limits

hh.infections.pre.or.postiso <- function(inf.times, who, hh.size, p = 0.5){
  pre.postiso.to.hh <- which(who %in% c("preiso", "postiso"))
  n <- length(pre.postiso.to.hh) # number of preiso infections
  n.pre.postiso.hh <- min(rbinom(n = 1, size = n, prob = p), unique(hh.size)-1)
  idx.to.change <- sample(x = pre.postiso.to.hh, size = n.pre.postiso.hh)
  who[idx.to.change] <- "hh"
  return(who)
}
