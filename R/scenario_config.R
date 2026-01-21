#' Create a Custom Scenario Configuration
#'
#' Creates a configuration object for custom TTIQ (Test-Trace-Isolate-Quarantine)
#' scenarios with user-specified distributions for detection times and delays.
#'
#' @param name Character. Name for the custom scenario.
#' @param active_detection List. Distribution for time to active detection (contact tracing).
#'   Must contain: type ("lognormal", "gamma", or "exponential") and appropriate parameters.
#' @param passive_detection List. Distribution for time to passive detection (symptoms).
#'   Must contain: type and appropriate parameters.
#' @param test_turnaround List. Distribution for test turnaround time.
#'   Must contain: type and appropriate parameters.
#' @param interview_delay List. Distribution for interview delay.
#'   Must contain: type and appropriate parameters.
#' @param notification_delay List. Distribution for contact notification delay.
#'   Must contain: type and appropriate parameters.
#'
#' @return A list of class "scenario_config" containing the scenario specification.
#'
#' @details
#' Each distribution list should specify:
#' \itemize{
#'   \item For "lognormal": meanlog, sdlog
#'   \item For "gamma": shape, rate (or scale)
#'   \item For "exponential": rate
#' }
#'
#' @examples
#' # Create a custom scenario for a different disease
#' custom <- create_scenario_config(
#'   name = "influenza_rapid",
#'   active_detection = list(type = "lognormal", meanlog = 0.8, sdlog = 0.4),
#'   passive_detection = list(type = "lognormal", meanlog = 1.2, sdlog = 0.5),
#'   test_turnaround = list(type = "exponential", rate = 2),
#'   interview_delay = list(type = "exponential", rate = 1),
#'   notification_delay = list(type = "exponential", rate = 0.8)
#' )
#'
#' @export
create_scenario_config <- function(
    name = "custom",
    active_detection = list(type = "lognormal", meanlog = 1.2, sdlog = 0.5),
    passive_detection = list(type = "lognormal", meanlog = 1.8, sdlog = 0.6),
    test_turnaround = list(type = "gamma", shape = 2, rate = 3),
    interview_delay = list(type = "exponential", rate = 2),
    notification_delay = list(type = "exponential", rate = 1.25)
) {

  config <- list(
    name = name,
    active_detection = active_detection,
    passive_detection = passive_detection,
    test_turnaround = test_turnaround,
    interview_delay = interview_delay,
    notification_delay = notification_delay
  )

  class(config) <- c("scenario_config", "list")

  validate_scenario_config(config)

  return(config)
}

#' Validate a Scenario Configuration
#'
#' Checks that a scenario configuration object has valid structure.
#'
#' @param config A scenario_config object.
#'
#' @return TRUE if valid, otherwise throws an error.
#'
#' @keywords internal
validate_scenario_config <- function(config) {

  required_components <- c("active_detection", "passive_detection",
                           "test_turnaround", "interview_delay",
                           "notification_delay")

  for (component in required_components) {
    if (is.null(config[[component]])) {
      stop(paste0("Scenario config missing required component: ", component))
    }

    dist <- config[[component]]
    if (is.null(dist$type)) {
      stop(paste0("Distribution '", component, "' missing 'type'"))
    }

    valid_types <- c("lognormal", "gamma", "exponential")
    if (!dist$type %in% valid_types) {
      stop(paste0("Distribution type must be one of: ", paste(valid_types, collapse = ", ")))
    }
  }

  return(TRUE)
}

#' Sample from a Distribution Specification
#'
#' Draws n samples from a distribution specified as a list.
#'
#' @param n Integer. Number of samples.
#' @param dist_spec List. Distribution specification with type and parameters.
#'
#' @return Numeric vector of samples.
#'
#' @importFrom stats rlnorm rgamma rexp
#' @keywords internal
sample_from_dist <- function(n, dist_spec) {

  if (dist_spec$type == "lognormal") {
    return(rlnorm(n, meanlog = dist_spec$meanlog, sdlog = dist_spec$sdlog))
  } else if (dist_spec$type == "gamma") {
    if (!is.null(dist_spec$rate)) {
      return(rgamma(n, shape = dist_spec$shape, rate = dist_spec$rate))
    } else {
      return(rgamma(n, shape = dist_spec$shape, scale = dist_spec$scale))
    }
  } else if (dist_spec$type == "exponential") {
    return(rexp(n, rate = dist_spec$rate))
  } else {
    stop(paste0("Unknown distribution type: ", dist_spec$type))
  }
}

#' Get Built-in Scenario Names
#'
#' Returns the names of available built-in TTIQ scenarios.
#'
#' @return Character vector of scenario names.
#'
#' @examples
#' get_builtin_scenarios()
#'
#' @export
get_builtin_scenarios <- function() {

  c("optimal", "partial", "baseline")
}

#' Normalize Scenario Name
#'
#' Maps scenario aliases to canonical names used in the data.
#'
#' @param scenario Character. Scenario name.
#'
#' @return Character. Canonical scenario name.
#'
#' @keywords internal
normalize_scenario_name <- function(scenario) {

  # Map aliases to canonical names in the data
  if (scenario == "baseline") {
    return("current_nsw_case_init")
  }
  return(scenario)
}
