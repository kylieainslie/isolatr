#' Abbreviate Australian state and territory names
#'
#' Converts full Australian state and territory names to their standard abbreviations.
#' The function accepts both full names and abbreviations as input and returns
#' abbreviations. This is useful for standardizing state names in datasets.
#'
#' @param state_names A character vector of Australian state or territory names.
#'   Can be either full names (e.g., "New South Wales") or abbreviations (e.g., "NSW").
#'
#' @return A character vector of abbreviated state/territory names. Returns NA for
#'   unrecognized state names.
#'
#' @details
#' Recognized states and territories:
#' \itemize{
#'   \item Australian Capital Territory (ACT)
#'   \item New South Wales (NSW)
#'   \item Northern Territory (NT)
#'   \item Queensland (QLD)
#'   \item South Australia (SA)
#'   \item Tasmania (TAS)
#'   \item Victoria (VIC)
#'   \item Western Australia (WA)
#' }
#'
#' @examples
#' abbreviate_states("New South Wales")
#' # Returns: "NSW"
#'
#' abbreviate_states(c("Victoria", "Queensland", "NSW"))
#' # Returns: c("VIC", "QLD", "NSW")
#'
#' @family state helper functions
#' @importFrom dplyr case_when
#' @export

abbreviate_states <- function(state_names) {
  rtn <- case_when(
    state_names %in% c("Australian Capital Territory", "ACT") ~ "ACT",
    state_names %in% c("New South Wales", "NSW") ~ "NSW",
    state_names %in% c("Northern Territory", "NT") ~ "NT",
    state_names %in% c("Queensland", "QLD") ~ "QLD",
    state_names %in% c("South Australia", "SA") ~ "SA",
    state_names %in% c("Tasmania", "TAS") ~ "TAS",
    state_names %in% c("Victoria", "VIC") ~ "VIC",
    state_names %in% c("Western Australia", "WA") ~ "WA"
  )

  return(rtn)
}
