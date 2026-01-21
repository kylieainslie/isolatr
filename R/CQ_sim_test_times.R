#' Evaluate Isolation Testing Strategy
#'
#' Evaluates the effectiveness of a specified testing schedule during isolation by
#' calculating the infection potential and mean number of cases that would occur
#' given the testing regime.
#'
#' @param CQ.sim.output Data frame. Output from \code{\link{CQ.sim2}}, containing
#'   simulated secondary infection data.
#' @param n.ind Integer. Number of index cases (must match the n.ind used in CQ.sim2).
#' @param test.times Numeric vector. Days on which tests are administered (relative
#'   to start of quarantine). For example, c(1, 3, 6) means tests on days 1, 3, and 6.
#' @param TP Numeric. Transmission potential - should match value used in CQ.sim2.
#' @param VE.trans Numeric. Vaccine effectiveness against transmission (0-1).
#'   Must match the value used in \code{\link{CQ.sim2}}.
#' @param the.scenario Character. TTIQ scenario name: "optimal", "partial", or "baseline".
#' @param scenario_config A scenario_config object. If provided, overrides the.scenario.
#' @param gi_meanlog Numeric. Generation interval meanlog. Default 1.376 (COVID-19).
#' @param gi_sdlog Numeric. Generation interval sdlog. Default 0.567 (COVID-19).
#' @param test_intercept Numeric. Test sensitivity intercept. Default 1.5.
#' @param test_slope_prepeak Numeric. Test sensitivity slope pre-peak. Default 2.2.
#' @param test_slope_postpeak Numeric. Test sensitivity slope post-peak. Default 0.22.
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
#' This function models the impact of a testing schedule on transmission during isolation.
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
#'   TP = 3.0,
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
CQ.sim.test.times <- function(CQ.sim.output, n.ind, test.times, TP, VE.trans, the.scenario,
                              scenario_config = NULL, gi_meanlog = 1.376, gi_sdlog = 0.567,
                              test_intercept = 1.5, test_slope_prepeak = 2.2,
                              test_slope_postpeak = 0.22) {

  out <- CQ.sim.output %>%
    group_by(i) %>%
    mutate(first.pos = testing.function2(
      test.times = test.times, iso.time = iso.time,
      inc.period = inc.period, the.scenario = the.scenario,
      test_intercept = test_intercept,
      test_slope_prepeak = test_slope_prepeak,
      test_slope_postpeak = test_slope_postpeak
    )) %>%
    mutate(first.pos = first.pos +
             test.turnaround.samp(n = 1, the.scenario = the.scenario, scenario_config = scenario_config) +
             other.delay.samp(n = 1, the.scenario = the.scenario, scenario_config = scenario_config)) %>%
    ungroup() %>%
    filter(who == "preiso" |
             who == "hh" & inf.times < first.pos |
             who == "postiso" & is.infinite(first.pos)) %>%
    mutate(ipq = gi.dist.cdf(q = pmin(first.pos, det) - inf.times,
                             meanlog = gi_meanlog, sdlog = gi_sdlog) *
             TP * (1 - VE.trans * sc.vac.status)) %>%
    summarise(IPq = sum(ipq, na.rm = TRUE) / n.ind,
              sdIPq = sd(ipq, na.rm = TRUE),
              mean.cases = n() / n.ind)

  return(out)
}
