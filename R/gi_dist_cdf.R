#' Generation Interval Cumulative Distribution Function
#'
#' Returns the CDF of the lognormal generation interval distribution.
#'
#' @param q Numeric vector. Quantiles (time values in days).
#' @param meanlog Numeric. Mean of the distribution on the log scale.
#'   Default is 1.376 (COVID-19 estimate).
#' @param sdlog Numeric. Standard deviation of the distribution on the log scale.
#'   Default is 0.567 (COVID-19 estimate).
#'
#' @return Numeric vector of cumulative probabilities.
#'
#' @details
#' Used to calculate the proportion of secondary transmissions that would have
#' occurred by a given time point. This is used in calculating infection potential.
#'
#' @examples
#' # Probability of transmission within 5 days (COVID-19)
#' gi.dist.cdf(5)
#'
#' # Probability of transmission within 3 days (Influenza)
#' gi.dist.cdf(3, meanlog = 0.91, sdlog = 0.52)
#'
#' @export
gi.dist.cdf <- function(q, meanlog = 1.376, sdlog = 0.567) {

  plnorm(q, meanlog = meanlog, sdlog = sdlog)
}
