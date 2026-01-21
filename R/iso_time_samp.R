#' Sample Time to Isolation
#'
#' Draws n samples from the active detection distribution (contact tracing)
#' for the specified TTIQ scenario or custom configuration.
#'
#' @param n.ind Integer. Number of samples to draw.
#' @param the.scenario Character. Built-in scenario name: "optimal", "partial",
#'   or "baseline". Ignored if scenario_config is provided.
#' @param scenario_config A scenario_config object created by
#'   \code{\link{create_scenario_config}}. If provided, the.scenario is ignored.
#'
#' @return Numeric vector of isolation times in days.
#'
#' @details
#' Time to isolation represents the delay from index case infection to when
#' close contacts are identified and isolated via contact tracing (active detection).
#'
#' @examples
#' # Using built-in scenario
#' iso.time.samp(100, the.scenario = "optimal")
#'
#' # Using custom configuration
#' config <- create_scenario_config(
#'   active_detection = list(type = "lognormal", meanlog = 1.0, sdlog = 0.4)
#' )
#' iso.time.samp(100, scenario_config = config)
#'
#' @importFrom dplyr filter mutate select slice_sample pull %>%
#' @export
iso.time.samp <- function(n.ind, the.scenario = "optimal", scenario_config = NULL) {

  # Use custom config if provided
  if (!is.null(scenario_config)) {
    return(sample_from_dist(n.ind, scenario_config$active_detection))
  }

  # Normalize scenario name for built-in data
  the.scenario <- normalize_scenario_name(the.scenario)

  # The context is PCC's of cases. Their time to isolation should come from
  # the active component (contact-tracing), rather than passive
  distn.dat %>%
    filter(scenario == the.scenario) %>%
    mutate(x = as.numeric(time_to_active)) %>%
    select(x) %>%
    filter(is.finite(x)) %>%
    slice_sample(n = n.ind, replace = TRUE) %>%
    pull() %>% as.numeric()
}
