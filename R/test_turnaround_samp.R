#' Sample Test Turnaround Times
#'
#' Draws n samples from the test turnaround time distribution for the
#' specified TTIQ scenario or custom configuration.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. Built-in scenario name: "optimal", "partial",
#'   or "baseline". Ignored if scenario_config is provided.
#' @param scenario_config A scenario_config object created by
#'   \code{\link{create_scenario_config}}. If provided, the.scenario is ignored.
#'
#' @return Numeric vector of test turnaround times in days.
#'
#' @details
#' Test turnaround time is the delay from sample collection to result notification.
#' This varies by testing capacity and scenario.
#'
#' @keywords internal
test.turnaround.samp <- function(n, the.scenario, scenario_config = NULL) {

  # Use custom config if provided
  if (!is.null(scenario_config)) {
    return(sample_from_dist(n, scenario_config$test_turnaround))
  }

  # Normalize scenario name
  the.scenario <- normalize_scenario_name(the.scenario)

  if (the.scenario == "partial") {
    sample(x = partial.tat.dat, size = n, replace = TRUE)
  } else if (the.scenario == "optimal") {
    sample(x = optimal.tat.dat, size = n, replace = TRUE)
  } else {
    # baseline / current_nsw_case_init
    sample(x = nsw.ci.tat.dat, size = n, replace = TRUE)
  }
}
