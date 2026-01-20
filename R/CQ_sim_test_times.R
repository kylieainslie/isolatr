#' Evaluate Quarantine Testing Strategy
#'
#' Evaluates the effectiveness of a specified testing schedule during quarantine by
#' calculating the infection potential and mean number of cases that would occur
#' given the testing regime.
#'
#' @param CQ.sim.output Data frame. Output from \code{\link{CQ.sim2}}, containing
#'   simulated secondary infection data.
#' @param n.ind Integer. Number of index cases (must match the n.ind used in CQ.sim2).
#' @param test.times Numeric vector. Days on which tests are administered (relative
#'   to start of quarantine). For example, c(1, 3, 6) means tests on days 1, 3, and 6.
#' @param VE.trans Numeric. Vaccine effectiveness against transmission (0-1).
#'   Must match the value used in \code{\link{CQ.sim2}}.
#' @param the.scenario Character. TTIQ scenario name. Must be one of:
#'   "optimal", "partial", or "current_nsw_case_init".
#'
#' @return A single-row data frame with the following columns:
#'   \describe{
#'     \item{IPq}{Infection Potential in Quarantine - mean number of secondary
#'       infections per index case that occur before detection via testing or symptoms}
#'     \item{sdIPq}{Standard deviation of infection potential across index cases}
#'     \item{mean.cases}{Mean number of undetected secondary cases per index case}
#'   }
#'
#' @details
#' This function models the impact of a testing schedule on transmission during quarantine.
#' For each index case, it:
#' \enumerate{
#'   \item Determines the time of first positive test using an internal testing function
#'   \item Adds test turnaround time and other delays (interview, notification)
#'   \item Filters secondary infections that occur before detection
#'   \item Calculates infection potential for each undetected case
#' }
#'
#' The infection potential (IPq) represents the expected number of tertiary infections
#' from undetected secondary cases, accounting for:
#' \itemize{
#'   \item Generation interval distribution
#'   \item Time remaining until detection
#'   \item Transmission potential (TP)
#'   \item Vaccine effectiveness against transmission
#' }
#'
#' Lower IPq values indicate more effective testing strategies.
#'
#' @examples
#' \dontrun{
#' # First, run the simulation
#' set.seed(42)
#' sim_results <- CQ.sim2(
#'   n.ind = 1000, TP = 3.0, k = 0.25,
#'   p.vac.idx = 0.7, p.vac.sc = 0.7, vacc.cor = 0.8,
#'   VE.trans = 0.5, VE.inf = 0.7,
#'   quarantine.duration = 14,
#'   the.scenario = "optimal"
#' )
#'
#' # Evaluate a testing strategy: test on days 1, 3, and 6
#' evaluation <- CQ.sim.test.times(
#'   CQ.sim.output = sim_results,
#'   n.ind = 1000,
#'   test.times = c(1, 3, 6),
#'   VE.trans = 0.5,
#'   the.scenario = "optimal"
#' )
#'
#' print(evaluation)
#' }
#'
#' @seealso \code{\link{CQ.sim2}}, \code{\link{CQ.sim.notest}}
#' @family simulation functions
#' @importFrom dplyr %>% group_by ungroup mutate filter summarise
#' @export

CQ.sim.test.times <- function(CQ.sim.output, n.ind, test.times, VE.trans, the.scenario){
  out <- CQ.sim.output %>%
    group_by(i) %>%
    mutate(first.pos = testing.function2(test.times = test.times, iso.time = iso.time,
                                         inc.period = inc.period, the.scenario = the.scenario)) %>%
    mutate(first.pos = first.pos + test.turnaround.samp(n = 1, the.scenario = the.scenario) +
                                    other.delay.samp(n = 1, the.scenario = the.scenario)) %>%
    ungroup() %>%
    filter(who == "preiso" |
             who == "hh" & inf.times < first.pos |
             who == "postiso" & is.infinite(first.pos)) %>%
    mutate(ipq = gi.dist.cdf(q = pmin(first.pos, det) - inf.times) * TP * (1 - VE.trans*sc.vac.status)) %>%
    summarise(IPq = sum(ipq, na.rm = TRUE)/n.ind, sdIPq = sd(ipq, na.rm = TRUE), mean.cases = n()/n.ind)
  return(out)
}
