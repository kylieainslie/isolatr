#' Sample Generation Intervals
#'
#' Draws n samples from a lognormal distribution representing generation intervals
#' (time between successive infections).
#'
#' @param n Integer. Number of samples to draw.
#' @param meanlog Numeric. Mean of the distribution on the log scale.
#'   Default is 1.376 (COVID-19 estimate, ~3.96 day median).
#' @param sdlog Numeric. Standard deviation of the distribution on the log scale.
#'   Default is 0.567 (COVID-19 estimate).
#'
#' @return Numeric vector of length n containing generation intervals in days.
#'
#' @details
#' The default parameters are calibrated to COVID-19 data. For other diseases,
#' supply appropriate lognormal parameters:
#' \itemize{
#'   \item Influenza: meanlog ≈ 0.91, sdlog ≈ 0.52 (~2.5 day median)
#'   \item SARS: meanlog ≈ 2.0, sdlog ≈ 0.45 (~7.4 day median)
#'   \item Measles: meanlog ≈ 2.4, sdlog ≈ 0.3 (~11 day median)
#' }
#'
#' @examples
#' # COVID-19 default
#' gi.dist.samp(100)
#'
#' # Influenza (shorter generation interval)
#' gi.dist.samp(100, meanlog = 0.91, sdlog = 0.52)
#'
#' @export
gi.dist.samp <- function(n, meanlog = 1.376, sdlog = 0.567) {

  rlnorm(n, meanlog = meanlog, sdlog = sdlog)
}
