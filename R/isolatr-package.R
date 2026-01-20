#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom stats plnorm rlnorm rnbinom sd pexp
#' @importFrom dplyr slice_sample pull row_number starts_with
#' @importFrom tidyr pivot_longer pivot_wider
## usethis namespace: end

# Global variables to avoid R CMD check NOTEs
utils::globalVariables(c(
  # Data table variables
  "i", "n", "first.pos", "who", "inf.times", "TP", "sc.vac.status", "ipq",
  "iso.time", "inc.period", "ncases", "who.original", "hh.size", "who.new",
  "keep.row", "hh.counter", "vacc.status", "unprotected",
  # Data column names
  "distn.dat", "scenario", "time_to_active", "time_to_passive", "hhsize.dat",
  "number", "partial.interview.dat", "partial.cc.notify.dat", "optimal.interview.dat",
  "optimal.cc.notify.dat", "nsw.ci.interview.dat", "nsw.ci.cc.notify.dat",
  "partial.tat.dat", "optimal.tat.dat", "nsw.ci.tat.dat",
  # Vaccine efficacy
  "VE.trans", "VE.inf",
  # Tidyverse variables
  "id", "value", "Var1", "x"
))
