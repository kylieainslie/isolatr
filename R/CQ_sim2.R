#' Community Quarantine Simulation for Primary Close Contacts
#'
#' Simulates COVID-19 transmission from index cases to secondary cases during quarantine,
#' accounting for household structure, vaccination status, isolation timing, and
#' testing/tracing scenarios.
#'
#' @param n.ind Integer. Number of index cases (primary close contacts) to simulate.
#' @param TP Numeric. Transmission potential - the mean number of secondary cases
#'   per index case (analogous to R0 in a fully susceptible population).
#' @param k Numeric. Dispersion parameter for the negative binomial distribution
#'   of secondary cases. Lower values indicate greater overdispersion (superspreading).
#' @param p.vac.idx Numeric. Probability that an index case is vaccinated (0-1).
#' @param p.vac.sc Numeric. Probability that a secondary case is vaccinated (0-1),
#'   for non-household contacts.
#' @param vacc.cor Numeric. Correlation coefficient (0-1) for vaccination status
#'   within households. Higher values mean household members are more likely to have
#'   the same vaccination status.
#' @param VE.trans Numeric. Vaccine effectiveness against transmission (0-1).
#'   Reduces probability that a vaccinated index case transmits infection.
#' @param VE.inf Numeric. Vaccine effectiveness against infection (0-1).
#'   Reduces probability that a vaccinated secondary case becomes infected.
#' @param quarantine.duration Numeric. Duration of quarantine period in days.
#' @param the.scenario Character. TTIQ scenario name. Must be one of:
#'   "optimal", "partial", or "current_nsw_case_init".
#' @param the.state Character. Australian state or territory for household size
#'   distribution. Default is "NSW". See \code{\link{abbreviate_states}} for valid values.
#'
#' @return A data frame with one row per secondary infection (among unprotected individuals),
#'   containing the following columns:
#'   \describe{
#'     \item{i}{Index case ID (1 to n.ind)}
#'     \item{vacc.status}{Vaccination status of index case (0 or 1)}
#'     \item{inc.period}{Incubation period of index case (days)}
#'     \item{iso.time}{Time to isolation of index case (days)}
#'     \item{ncases}{Number of secondary cases from this index case}
#'     \item{hh.size}{Household size of index case}
#'     \item{inf.times}{Time of infection for this secondary case (days since index case infection)}
#'     \item{who}{Classification of infection: "preiso" (before isolation),
#'       "hh" (household member), or "postiso" (after quarantine)}
#'     \item{sc.vac.status}{Vaccination status of secondary case (0 or 1)}
#'     \item{det}{Time to passive detection for this secondary case}
#'   }
#'
#' @details
#' This function implements a stochastic simulation model of COVID-19 transmission
#' during quarantine. The model:
#' \enumerate{
#'   \item Samples individual-level characteristics (vaccination, incubation period,
#'     isolation time, household size) for each index case
#'   \item Samples the number of secondary cases from a negative binomial distribution
#'   \item Samples generation intervals (time between successive infections) from a
#'     lognormal distribution calibrated to Australian COVID-19 data
#'   \item Classifies infections as occurring before isolation, within household
#'     during quarantine, or post-quarantine
#'   \item Models household-correlated vaccination status
#'   \item Calculates passive detection times based on the TTIQ scenario
#'   \item Filters infections based on vaccine effectiveness
#' }
#'
#' The function uses the following epidemiological distributions:
#' \itemize{
#'   \item Incubation period: Lognormal(μ=1.63, σ=0.5)
#'   \item Generation interval: Lognormal(μ=1.376, σ=0.567) - Australian COVID-19 baseline
#'   \item Number of secondary cases: Negative Binomial(size=k, μ=TP)
#' }
#'
#' @note
#' \strong{Important:} This function previously included a hard-coded \code{set.seed(1)}
#' which has been removed. Users should set their own seed before calling this function
#' if reproducibility is required.
#'
#' @examples
#' \dontrun{
#' # Simulate 1000 index cases with moderate transmission
#' set.seed(42)
#' results <- CQ.sim2(
#'   n.ind = 1000,
#'   TP = 3.0,
#'   k = 0.25,
#'   p.vac.idx = 0.7,
#'   p.vac.sc = 0.7,
#'   vacc.cor = 0.8,
#'   VE.trans = 0.5,
#'   VE.inf = 0.7,
#'   quarantine.duration = 14,
#'   the.scenario = "optimal",
#'   the.state = "NSW"
#' )
#'
#' # Examine distribution of infection times
#' summary(results$who)
#' }
#'
#' @family simulation functions
#' @importFrom dplyr mutate group_by ungroup filter select case_when %>%
#' @importFrom tidyr unnest
#' @importFrom stats rbinom runif
#' @importFrom purrr rbernoulli
#' @export

CQ.sim2 <- function(n.ind, TP, k, p.vac.idx, p.vac.sc, vacc.cor, VE.trans, VE.inf, quarantine.duration, the.scenario, the.state = "NSW"){

  # set.seed(1)  # Removed - users should set seed externally if needed
  # tic <- Sys.time()
  out <- data.frame("i" = 1:n.ind) %>%
    mutate(vacc.status = rbinom(n.ind, size = 1, prob = p.vac.idx), #) %>%
           inc.period = inc.period.samp(n.ind), #) %>%
           iso.time = iso.time.samp(n.ind, the.scenario), #) %>%
           ncases = ncases.samp(n.ind, TP, k), # ) %>%
           hh.size = samp.hh.size(n.ind, the.state)) %>% # individual-level details
    group_by(i) %>%
    mutate(inf.times = list(gi.dist.samp(ncases))) %>%
    unnest(inf.times) %>%
    # mutate(preiso = inf.times < iso.time,
    #        hh = inf.times > iso.time & inf.times < iso.time + quarantine.duration,
    #        postiso = inf.times > iso.time + quarantine.duration) %>%
    # group_by(i, hh) %>%
    # mutate(nh = row_number())
    mutate(who.original = case_when(
      inf.times < iso.time ~ "preiso",
      inf.times > iso.time & inf.times < iso.time + quarantine.duration ~ "hh",
      inf.times > iso.time + quarantine.duration ~ "postiso"
    )) %>%
    # # randomly sample preiso's to be hh instead
    mutate(who.new = hh.infections.pre.or.postiso(inf.times = inf.times, who = who.original, hh.size = hh.size, p = 0.5)) %>%
    group_by(i, who.new) %>%
    mutate(hh.counter = case_when(
      who.new == "hh" ~ row_number(),
      TRUE ~ 100L)) %>%
    ungroup() %>%
    mutate(keep.row = case_when(
      who.new == "hh" & who.original == "hh" & hh.counter >= hh.size ~ 0,
      TRUE ~ 1
    )) %>%
    filter(keep.row==1) %>%
    mutate(who = case_when(
      hh.counter >= hh.size ~ who.original,
      TRUE ~ who.new
    )) %>%
    select(-who.original, -who.new, -hh.counter, -keep.row) %>%
    group_by(i) %>%
    mutate(sc.vac.status = case_when(
      who == "hh" ~ cor.binary(n = n(), corr = vacc.cor, idx.vac.status = vacc.status),
      TRUE ~ rbernoulli(n = n(), p = p.vac.sc)
    )) %>%
    mutate(det = passive.detection(inf.times, the.scenario)) %>%
    ungroup() %>%
    mutate(unprotected = runif(n()) < (1 - VE.trans*vacc.status)*(1 - VE.inf*sc.vac.status)) %>%
    filter(unprotected) %>% select(-unprotected)
  # (toc <- Sys.time() - tic)
  # Break here as this is where the test.times comes in

  return(out)
}
