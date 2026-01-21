#' Sample Time to Active Detection
#'
#' Draws n samples of time to active detection (contact tracing) for the
#' specified TTIQ scenario or custom configuration.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. Built-in scenario name: "optimal", "partial",
#'   or "baseline". Ignored if scenario_config is provided.
#' @param scenario_config A scenario_config object created by
#'   \code{\link{create_scenario_config}}. If provided, the.scenario is ignored.
#'
#' @return Numeric vector of active detection times in days.
#'
#' @importFrom dplyr filter select slice_sample pull %>%
#' @keywords internal
active.detection.only <- function(n, the.scenario, scenario_config = NULL) {

  # Use custom config if provided
  if (!is.null(scenario_config)) {
    return(sample_from_dist(n, scenario_config$active_detection))
  }

  # Normalize scenario name for built-in data
  the.scenario <- normalize_scenario_name(the.scenario)

  distn.dat %>%
    filter(scenario == the.scenario) %>%
    select(time_to_active) %>%
    slice_sample(n = n) %>%
    pull() %>% as.numeric()
}
