#' Sample Incubation Periods
#'
#' Draws n samples from a lognormal distribution representing incubation periods.
#'
#' @param n Integer. Number of samples to draw.
#' @param meanlog Numeric. Mean of the distribution on the log scale.
#'   Default is 1.63 (COVID-19 estimate, ~5.1 day median).
#' @param sdlog Numeric. Standard deviation of the distribution on the log scale.
#'   Default is 0.5 (COVID-19 estimate).
#'
#' @return Numeric vector of length n containing incubation periods in days.
#'
#' @details
#' The default parameters are fitted to COVID-19 data. For other diseases,
#' supply appropriate lognormal parameters:
#' \itemize{
#'   \item Influenza: meanlog ≈ 0.34, sdlog ≈ 0.42 (~1.4 day median)
#'   \item SARS: meanlog ≈ 1.39, sdlog ≈ 0.51 (~4 day median)
#'   \item MERS: meanlog ≈ 1.61, sdlog ≈ 0.46 (~5 day median)
#' }
#'
#' @examples
#' # COVID-19 default
#' inc.period.samp(100)
#'
#' # Influenza (shorter incubation)
#' inc.period.samp(100, meanlog = 0.34, sdlog = 0.42)
#'
#' @export
inc.period.samp <- function(n, meanlog = 1.63, sdlog = 0.5) {

  rlnorm(n, meanlog = meanlog, sdlog = sdlog)
}
