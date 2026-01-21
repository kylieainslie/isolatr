#' Sample Household Sizes
#'
#' Draws n household sizes from a specified distribution using inverse transform sampling.
#'
#' @param n Integer. Number of samples to draw.
#' @param region Character. Region name for built-in household size distribution.
#'   For Australian states, see \code{\link{abbreviate_states}} for valid values.
#'   Ignored if \code{hh_probs} is provided.
#' @param hh_probs Numeric vector. Custom household size probabilities for sizes 1-8+.
#'   Must sum to 1 and have length 8. If provided, \code{region} is ignored.
#'
#' @return Integer vector of length n containing household sizes (1-8).
#'
#' @details
#' If \code{hh_probs} is provided, it should be a vector of 8 probabilities
#' corresponding to household sizes 1, 2, 3, 4, 5, 6, 7, and 8+ persons.
#'
#' @examples
#' # Using built-in Australian data
#' samp.hh.size(100, region = "NSW")
#'
#' # Using custom UK-like distribution
#' uk_probs <- c(0.28, 0.35, 0.18, 0.12, 0.05, 0.015, 0.004, 0.001)
#' samp.hh.size(100, hh_probs = uk_probs)
#'
#' @export
samp.hh.size <- function(n, region = NULL, hh_probs = NULL) {

  # Get cumulative distribution
  if (!is.null(hh_probs)) {
    # Use custom probabilities
    if (length(hh_probs) != 8) {
      stop("hh_probs must have length 8 (for household sizes 1-8+)")
    }
    if (abs(sum(hh_probs) - 1) > 1e-6) {
      stop("hh_probs must sum to 1")
    }
    hhs <- cumsum(hh_probs)
  } else if (!is.null(region)) {
    # Use built-in data for region
    hhs <- hhsizes(region)
  } else {
    stop("Either 'region' or 'hh_probs' must be provided")
  }

  r <- runif(n)
  hh.sizes <- sapply(X = r, FUN = function(x) { min(which(x < hhs)) })
  return(hh.sizes)
}
