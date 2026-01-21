#' Simulate Testing and Determine First Positive
#'
#' Models test sensitivity over the viral load trajectory and determines
#' the time of first positive test result.
#'
#' @param test.times Numeric vector. Days on which tests are administered
#'   (relative to start of isolation).
#' @param iso.time Numeric. Time of isolation onset.
#' @param inc.period Numeric. Incubation period for this individual.
#' @param the.scenario Character. TTIQ scenario name (currently unused but
#'   retained for API consistency).
#' @param test_intercept Numeric. Intercept for the logistic test sensitivity
#'   model. Default is 1.5.
#' @param test_slope_prepeak Numeric. Slope for pre-peak (rising) viral load.
#'   Default is 2.2.
#' @param test_slope_postpeak Numeric. Slope for post-peak (declining) viral load.
#'   Default is 0.22.
#'
#' @return Numeric. Time of first positive test, or Inf if no positive tests.
#'
#' @details
#' Test sensitivity is modeled using a logistic function that varies with
#' the timing relative to symptom onset (peak viral load):
#' \itemize{
#'   \item Pre-peak: sensitivity increases as viral load rises
#'   \item Post-peak: sensitivity decreases as viral load declines
#' }
#'
#' The default parameters are calibrated to PCR testing for COVID-19. For rapid
#' antigen tests or other diseases, adjust the coefficients accordingly.
#'
#' @keywords internal
testing.function2 <- function(test.times, iso.time, inc.period, the.scenario,
                              test_intercept = 1.5, test_slope_prepeak = 2.2,
                              test_slope_postpeak = 0.22) {

  C <- min(inc.period, 3.5) * runif(1)

  t <- iso.time + test.times - 1 - inc.period
  s <- t + C

  idx <- t >= -inc.period & t <= -C

  test.prob <- c(
    1 / (1 + exp(-(test_intercept + test_slope_prepeak * s[idx]))),    # pre peak
    1 / (1 + exp(-(test_intercept - test_slope_postpeak * s[!idx])))   # post peak
  )

  test.results <- runif(length(t)) < test.prob
  ttiv <- iso.time + test.times - 1
  first.pos <- min(ttiv[as.logical(test.results)], Inf)

  return(first.pos)
}
