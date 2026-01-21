#' Calculate Passive Detection Times
#'
#' Calculates detection times for infected individuals via passive surveillance
#' (symptom-based detection and healthcare seeking).
#'
#' @param inf.times Numeric vector. Infection times for secondary cases.
#' @param the.scenario Character. Built-in scenario name: "optimal", "partial",
#'   or "baseline". Ignored if scenario_config is provided.
#' @param scenario_config A scenario_config object created by
#'   \code{\link{create_scenario_config}}. If provided, the.scenario is ignored.
#'
#' @return Numeric vector of detection times (infection time + detection delay).
#'
#' @details
#' Passive detection represents symptom-based detection where individuals
#' seek healthcare due to illness. The delay from infection to detection
#' depends on incubation period and healthcare-seeking behavior.
#'
#' @importFrom dplyr filter select slice_sample pull %>%
#' @keywords internal
passive.detection <- function(inf.times, the.scenario, scenario_config = NULL) {

  it <- unlist(inf.times)
  n <- length(it)

  # Use custom config if provided
  if (!is.null(scenario_config)) {
    return(sample_from_dist(n, scenario_config$passive_detection) + it)
  }

  # Normalize scenario name for built-in data
  the.scenario <- normalize_scenario_name(the.scenario)

  distn.dat %>%
    filter(scenario == the.scenario) %>%
    select(time_to_passive) %>%
    slice_sample(n = n, replace = TRUE) %>%
    pull() %>% as.numeric() + it
}
