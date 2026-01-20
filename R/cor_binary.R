# Generate correlated binary outcomes based on index vaccination status
# Creates correlated vaccination status for household members with specified correlation coefficient

cor.binary <- function(n, corr, idx.vac.status){
  ind <- runif(n) < corr
  as.logical(idx.vac.status*(ind) + (1 - idx.vac.status)*(!ind))
}
