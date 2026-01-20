#' Abbreviate Australian state names to standard abbreviations
#' 
#' Converts full state/territory names (e.g., "New South Wales") to short codes (e.g., "NSW")
#' 
#' @param state_names character string; Name of Australian State
#' @return converted state names
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
