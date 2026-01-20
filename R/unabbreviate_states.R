#' Expand abbreviated state names to full names
#'
#' Converts Australian state and territory abbreviations to their full names.
#' The function accepts both abbreviations and full names as input and returns
#' full names. This is useful for creating readable output and reports.
#'
#' @param state_names A character vector of Australian state or territory names.
#'   Can be either abbreviations (e.g., "NSW") or full names (e.g., "New South Wales").
#'
#' @return A character vector of full state/territory names. Returns NA for
#'   unrecognized state names.
#'
#' @details
#' Recognized states and territories:
#' \itemize{
#'   \item ACT (Australian Capital Territory)
#'   \item NSW (New South Wales)
#'   \item NT (Northern Territory)
#'   \item QLD (Queensland)
#'   \item SA (South Australia)
#'   \item TAS (Tasmania)
#'   \item VIC (Victoria)
#'   \item WA (Western Australia)
#' }
#'
#' @examples
#' unabbreviate_states("NSW")
#' # Returns: "New South Wales"
#'
#' unabbreviate_states(c("VIC", "QLD", "Australian Capital Territory"))
#' # Returns: c("Victoria", "Queensland", "Australian Capital Territory")
#'
#' @family state helper functions
#' @importFrom dplyr case_when
#' @export

unabbreviate_states <- function(state_names) {
  case_when(
    state_names %in% c("Australian Capital Territory", "ACT") ~ "Australian Capital Territory",
    state_names %in% c("New South Wales", "NSW") ~ "New South Wales",
    state_names %in% c("Northern Territory", "NT") ~ "Northern Territory",
    state_names %in% c("Queensland", "QLD") ~ "Queensland",
    state_names %in% c("South Australia", "SA") ~ "South Australia",
    state_names %in% c("Tasmania", "TAS") ~ "Tasmania",
    state_names %in% c("Victoria", "VIC") ~ "Victoria",
    state_names %in% c("Western Australia", "WA") ~ "Western Australia"
  )
}
