#' Convert Data Frame to Named Vector
#'
#' Converts a two-column data frame to a named vector.
#'
#' @param df Data frame with two columns. First column becomes names,
#'   second column becomes values.
#'
#' @return Named numeric vector.
#'
#' @keywords internal
to.named.vector <- function(df) {

  # Ensure we have a data frame
 df <- as.data.frame(df)
  out <- df[[2]]
  names(out) <- as.character(df[[1]])
  return(out)
}
