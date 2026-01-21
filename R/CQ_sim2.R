#' Isolation Simulation for Close Contacts
#'
#' Simulates disease transmission from index cases to secondary cases during isolation,
#' accounting for household structure, vaccination status, isolation timing, and
#' testing/tracing scenarios. While defaults are calibrated to COVID-19, the function
#' can be used for any communicable disease by adjusting the epidemiological parameters.
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
#' @param quarantine.duration Numeric. Duration of quarantine/isolation period in days.
#' @param the.scenario Character. TTIQ scenario name. Must be one of:
#'   "optimal", "partial", "baseline", or "current_nsw_case_init" (deprecated alias for baseline).
#' @param the.state Character. Deprecated, use \code{region} instead.
#' @param region Character. Region name for household size distribution.
#'   Default is "NSW". See \code{\link{abbreviate_states}} for valid Australian values.
#'   Ignored if \code{hh_probs} is provided.
#' @param hh_probs Numeric vector. Custom household size probabilities for sizes 1-8+.
#'   Must sum to 1 and have length 8. If provided, \code{region} is ignored.
#' @param inc_meanlog Numeric. Mean of incubation period distribution on log scale.
#'   Default is 1.63 (COVID-19, ~5.1 day median).
#' @param inc_sdlog Numeric. SD of incubation period distribution on log scale.
#'   Default is 0.5 (COVID-19).
#' @param gi_meanlog Numeric. Mean of generation interval distribution on log scale.
#'   Default is 1.376 (COVID-19, ~3.96 day median).
#' @param gi_sdlog Numeric. SD of generation interval distribution on log scale.
#'   Default is 0.567 (COVID-19).
#' @param hh_transmission_prob Numeric. Probability that a pre-isolation infection
#'   occurs within the household (vs community). Default is 0.5.
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
#' This function implements a stochastic simulation model of disease transmission
#' during isolation/quarantine. The model:
#' \enumerate{
#'   \item Samples individual-level characteristics (vaccination, incubation period,
#'     isolation time, household size) for each index case
#'   \item Samples the number of secondary cases from a negative binomial distribution
#'   \item Samples generation intervals (time between successive infections) from a
#'     lognormal distribution
#'   \item Classifies infections as occurring before isolation, within household
#'     during quarantine, or post-quarantine
#'   \item Models household-correlated vaccination status
#'   \item Calculates passive detection times based on the TTIQ scenario
#'   \item Filters infections based on vaccine effectiveness
#' }
#'
#' The function uses lognormal distributions for incubation period and generation
#' interval. Default parameters are calibrated to COVID-19, but can be customized
#' for other diseases:
#' \itemize{
#'   \item COVID-19 (default): inc_meanlog=1.63, gi_meanlog=1.376
#'   \item Influenza: inc_meanlog≈0.34, gi_meanlog≈0.91
#'   \item SARS: inc_meanlog≈1.39, gi_meanlog≈2.0
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
#' @importFrom dplyr mutate group_by ungroup filter select case_when n %>%
#' @importFrom tidyr unnest
#' @importFrom stats rbinom runif
#' @importFrom purrr rbernoulli
#' @export

CQ.sim2 <- function(n.ind, TP, k, p.vac.idx, p.vac.sc, vacc.cor, VE.trans, VE.inf,
                    quarantine.duration, the.scenario, the.state = NULL, region = "NSW",
                    hh_probs = NULL, inc_meanlog = 1.63, inc_sdlog = 0.5,
                    gi_meanlog = 1.376, gi_sdlog = 0.567, hh_transmission_prob = 0.5) {


  # Handle deprecated the.state parameter

  if (!is.null(the.state)) {
    warning("'the.state' is deprecated. Use 'region' instead.", call. = FALSE)
    region <- the.state
  }

  # Handle deprecated scenario name

  if (the.scenario == "current_nsw_case_init") {
    the.scenario <- "baseline"
  }

  # set.seed(1)  # Removed - users should set seed externally if needed
  # tic <- Sys.time()
  out <- data.frame("i" = 1:n.ind) %>%
    mutate(vacc.status = rbinom(n.ind, size = 1, prob = p.vac.idx),
           inc.period = inc.period.samp(n.ind, meanlog = inc_meanlog, sdlog = inc_sdlog),
           iso.time = iso.time.samp(n.ind, the.scenario),
           ncases = ncases.samp(n.ind, TP, k),
           hh.size = samp.hh.size(n.ind, region = region, hh_probs = hh_probs)) %>%
    group_by(i) %>%
    mutate(inf.times = list(gi.dist.samp(ncases, meanlog = gi_meanlog, sdlog = gi_sdlog))) %>%
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
    mutate(who.new = hh.infections.pre.or.postiso(inf.times = inf.times, who = who.original, hh.size = hh.size, p = hh_transmission_prob)) %>%
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
