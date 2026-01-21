#' Sample Interview and Notification Delays
#'
#' Samples combined delays from notification to interview and from interview
#' to notifying close contacts.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. Built-in scenario name: "optimal", "partial",
#'   or "baseline". Ignored if scenario_config is provided.
#' @param scenario_config A scenario_config object created by
#'   \code{\link{create_scenario_config}}. If provided, the.scenario is ignored.
#'
#' @return Numeric vector of combined delay times in days.
#'
#' @details
#' This function samples two components:
#' \itemize{
#'   \item Interview delay: time from positive test to case interview
#'   \item Notification delay: time from interview to notifying close contacts
#' }
#' The sum of these delays is returned.
#'
#' @keywords internal
other.delay.samp <- function(n, the.scenario, scenario_config = NULL) {

  # Use custom config if provided
  if (!is.null(scenario_config)) {
    interview_delay <- sample_from_dist(n, scenario_config$interview_delay)
    notify_delay <- sample_from_dist(n, scenario_config$notification_delay)
    return(interview_delay + notify_delay)
  }

  # Normalize scenario name
  the.scenario <- normalize_scenario_name(the.scenario)

  if (the.scenario == "partial") {
    cumulative.probs.interview <- partial.interview.dat
    cumulative.probs.notify <- partial.cc.notify.dat
  } else if (the.scenario == "optimal") {
    cumulative.probs.interview <- optimal.interview.dat
    cumulative.probs.notify <- optimal.cc.notify.dat
  } else {
    # baseline / current_nsw_case_init
    cumulative.probs.interview <- nsw.ci.interview.dat
    cumulative.probs.notify <- nsw.ci.cc.notify.dat
  }

  r1 <- runif(n)
  r2 <- runif(n)

  interview.delay <- sapply(X = r1, FUN = function(x) {
    names(cumulative.probs.interview)[min(which(x < cumulative.probs.interview))]
  })
  notify.delay <- sapply(X = r2, FUN = function(x) {
    names(cumulative.probs.notify)[min(which(x < cumulative.probs.notify))]
  })

  return(as.numeric(interview.delay) + as.numeric(notify.delay))
}
