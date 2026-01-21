#' Evaluate Isolation Without Active Testing
#'
#' Evaluates isolation effectiveness when relying solely on passive detection
#' (symptom-based detection) without any active testing schedule. This serves as
#' a baseline comparison for testing strategies.
#'
#' @param CQ.sim.output Data frame. Output from \code{\link{CQ.sim2}}, containing
#'   simulated secondary infection data.
#' @param n.ind Integer. Number of index cases (must match the n.ind used in CQ.sim2).
#' @param TP Numeric. Transmission potential - should match value used in CQ.sim2.
#' @param VE.trans Numeric. Vaccine effectiveness against transmission (0-1).
#'   Must match the value used in \code{\link{CQ.sim2}}.
#' @param the.scenario Character. TTIQ scenario name: "optimal", "partial", or "baseline".
#' @param scenario_config A scenario_config object. If provided, overrides the.scenario.
#' @param gi_meanlog Numeric. Generation interval meanlog. Default 1.376 (COVID-19).
#' @param gi_sdlog Numeric. Generation interval sdlog. Default 0.567 (COVID-19).
#'
#' @return A single-row data frame with the following columns:
#'   \describe{
#'     \item{IPq}{Infection Potential in Quarantine - mean number of secondary
#'       infections per index case that occur before passive detection}
#'     \item{sdIPq}{Standard deviation of infection potential across index cases}
#'     \item{mean.cases}{Mean number of undetected secondary cases per index case}
#'   }
#'
#' @details
#' This function evaluates a no-testing scenario where infected individuals are
#' only detected when they develop symptoms (passive detection). This provides
#' a baseline for comparing the effectiveness of active testing strategies.
#'
#' The function:
#' \enumerate{
#'   \item Samples time to passive detection for each case
#'   \item Adds test turnaround time (time from symptom onset to confirmation)
#'   \item Filters infections occurring before detection
#'   \item Calculates infection potential based on remaining infectious period
#' }
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
#' # Evaluate isolation without testing
#' baseline <- CQ.sim.notest(
#'   CQ.sim.output = sim_results,
#'   n.ind = 1000,
#'   TP = 3.0,
#'   VE.trans = 0.5,
#'   the.scenario = "optimal"
#' )
#'
#' print(baseline)
#' }
#'
#' @seealso \code{\link{CQ.sim2}}, \code{\link{CQ.sim.test.times}}
#' @family simulation functions
#' @importFrom dplyr %>% group_by ungroup mutate filter summarise
#' @export
CQ.sim.notest <- function(CQ.sim.output, n.ind, TP, VE.trans, the.scenario,
                          scenario_config = NULL, gi_meanlog = 1.376, gi_sdlog = 0.567) {

  out <- CQ.sim.output %>%
    group_by(i) %>%
    mutate(first.pos = passive.detection.only(n = n(), the.scenario = the.scenario,
                                               scenario_config = scenario_config)) %>%
    mutate(first.pos = first.pos + test.turnaround.samp(n = n(), the.scenario = the.scenario,
                                                        scenario_config = scenario_config)) %>%
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
