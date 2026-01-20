# ==============================================================================
# COMPREHENSIVE ROXYGEN2 DOCUMENTATION GUIDE FOR ISOLATR PACKAGE
# ==============================================================================
# This file contains templates for adding documentation to all functions
# Copy and paste the relevant sections to update each R file
# ==============================================================================

# ------------------------------------------------------------------------------
# SAMPLING FUNCTIONS
# ------------------------------------------------------------------------------

#' Sample Generation Intervals
#'
#' Draws random samples from the generation interval distribution - the time between
#' successive infections in a transmission chain.
#'
#' @param n Integer. Number of samples to draw.
#'
#' @return Numeric vector of length n containing generation interval times (in days).
#'
#' @details
#' Generation intervals are sampled from a lognormal distribution with parameters
#' calibrated to Australian COVID-19 transmission data:
#' \itemize{
#'   \item Log-mean (μ): 1.376
#'   \item Log-standard deviation (σ): 0.567
#' }
#'
#' This corresponds to a median generation interval of approximately 3.96 days.
#'
#' @examples
#' # Sample 100 generation intervals
#' gi <- gi.dist.samp(100)
#' summary(gi)
#'
#' @seealso \code{\link{gi.dist.cdf}}, \code{\link{inc.period.samp}}
#' @family sampling functions
#' @importFrom stats rlnorm
#' @export
# gi.dist.samp()

# ------------------------------------------------------------------------------

#' Generation Interval Cumulative Distribution Function
#'
#' Computes the cumulative distribution function (CDF) for the generation interval
#' distribution at specified quantiles.
#'
#' @param q Numeric vector. Quantiles at which to evaluate the CDF.
#'
#' @return Numeric vector of same length as q containing CDF values (probabilities).
#'
#' @details
#' Uses the same lognormal distribution as \code{\link{gi.dist.samp}}:
#' \itemize{
#'   \item Log-mean (μ): 1.376
#'   \item Log-standard deviation (σ): 0.567
#' }
#'
#' @examples
#' # Probability that generation interval is less than 5 days
#' gi.dist.cdf(5)
#'
#' # CDF at multiple quantiles
#' gi.dist.cdf(c(1, 3, 5, 7, 10))
#'
#' @seealso \code{\link{gi.dist.samp}}
#' @family sampling functions
#' @importFrom stats plnorm
#' @export
# gi.dist.cdf()

# ------------------------------------------------------------------------------

#' Sample Incubation Periods
#'
#' Draws random samples from the COVID-19 incubation period distribution - the time
#' from exposure to symptom onset.
#'
#' @param n Integer. Number of samples to draw.
#'
#' @return Numeric vector of length n containing incubation periods (in days).
#'
#' @details
#' Incubation periods are sampled from a lognormal distribution fitted to COVID-19 data:
#' \itemize{
#'   \item Log-mean (μ): 1.63
#'   \item Log-standard deviation (σ): 0.5
#' }
#'
#' This corresponds to a median incubation period of approximately 5.1 days.
#'
#' @examples
#' # Sample 100 incubation periods
#' inc <- inc.period.samp(100)
#' summary(inc)
#'
#' @seealso \code{\link{gi.dist.samp}}
#' @family sampling functions
#' @importFrom stats rlnorm
#' @export
# inc.period.samp()

# ------------------------------------------------------------------------------

#' Sample Number of Secondary Cases
#'
#' Draws random samples from a negative binomial distribution to model the number
#' of secondary infections from each index case, accounting for overdispersion
#' (superspreading events).
#'
#' @param n Integer. Number of samples to draw.
#' @param TP Numeric. Transmission potential - the mean number of secondary cases.
#' @param k Numeric. Dispersion parameter. Lower values indicate greater overdispersion
#'   (more superspreading). Typical values range from 0.1 to 1.0.
#'
#' @return Integer vector of length n containing number of secondary cases.
#'
#' @details
#' The negative binomial distribution is parameterized with:
#' \itemize{
#'   \item size = k (dispersion parameter)
#'   \item mu = TP (mean)
#' }
#'
#' When k is small, the distribution has high variance, reflecting the observed
#' pattern of COVID-19 transmission where most cases generate few or no secondary
#' cases, but occasional superspreading events generate many.
#'
#' @examples
#' # Sample with moderate superspreading (k=0.25)
#' cases <- ncases.samp(n = 1000, TP = 3.0, k = 0.25)
#' table(cases)
#'
#' # Compare with less overdispersion (k=1.0)
#' cases2 <- ncases.samp(n = 1000, TP = 3.0, k = 1.0)
#' table(cases2)
#'
#' @family sampling functions
#' @importFrom stats rnbinom
#' @export
# ncases.samp()

# ------------------------------------------------------------------------------

#' Sample Household Sizes
#'
#' Draws random household sizes from the empirical distribution for a specified
#' Australian state or territory.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.state Character. Australian state or territory abbreviation or full name.
#'   See \code{\link{abbreviate_states}} for valid values.
#'
#' @return Integer vector of length n containing household sizes (1 to 8+).
#'
#' @details
#' Uses inverse transform sampling from state-specific household size distributions
#' derived from Australian census data. The distribution accounts for variation in
#' household structure across different states and territories.
#'
#' @examples
#' # Sample 100 household sizes for NSW
#' hh <- samp.hh.size(100, "NSW")
#' table(hh)
#'
#' # Compare with Victoria
#' hh_vic <- samp.hh.size(100, "Victoria")
#' table(hh_vic)
#'
#' @seealso \code{\link{hhsizes}}
#' @family sampling functions
#' @importFrom stats runif
#' @export
# samp.hh.size()

# ------------------------------------------------------------------------------

#' Sample Time to Isolation
#'
#' Samples the time from infection to isolation for index cases under a specified
#' TTIQ (Test, Trace, Isolate, Quarantine) scenario.
#'
#' @param n.ind Integer. Number of samples to draw.
#' @param the.scenario Character. TTIQ scenario name: "optimal", "partial",
#'   or "current_nsw_case_init".
#'
#' @return Numeric vector of length n.ind containing times to isolation (in days).
#'
#' @details
#' Samples from scenario-specific empirical distributions representing different
#' levels of TTIQ system performance. The scenarios reflect:
#' \itemize{
#'   \item optimal: Rapid contact tracing and testing
#'   \item partial: Moderate delays in tracing and testing
#'   \item current_nsw_case_init: NSW baseline performance
#' }
#'
#' @examples
#' \dontrun{
#' # Sample isolation times under optimal TTIQ
#' iso_times <- iso.time.samp(1000, "optimal")
#' summary(iso_times)
#' }
#'
#' @family sampling functions
#' @export
# iso.time.samp()

# ------------------------------------------------------------------------------

#' Sample Test Turnaround Times
#'
#' Samples the time from test administration to result notification under a
#' specified TTIQ scenario.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. TTIQ scenario name: "optimal", "partial",
#'   or "current_nsw_case_init".
#'
#' @return Numeric vector of length n containing turnaround times (in days).
#'
#' @details
#' Samples from scenario-specific empirical distributions of test processing and
#' reporting delays. These delays include laboratory processing time and
#' administrative reporting time.
#'
#' @examples
#' \dontrun{
#' # Sample turnaround times
#' tat <- test.turnaround.samp(100, "optimal")
#' summary(tat)
#' }
#'
#' @family sampling functions
#' @export
# test.turnaround.samp()

# ------------------------------------------------------------------------------

#' Sample Other Delays
#'
#' Samples additional delays in the TTIQ process, including interview time and
#' close contact notification time.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. TTIQ scenario name: "optimal", "partial",
#'   or "current_nsw_case_init".
#'
#' @return Numeric vector of length n containing total delay times (in days).
#'
#' @details
#' Combines two delay components:
#' \enumerate{
#'   \item Interview delay: Time to conduct case interview
#'   \item Notification delay: Time to notify and quarantine close contacts
#' }
#'
#' Uses inverse transform sampling from scenario-specific cumulative probability
#' distributions.
#'
#' @examples
#' \dontrun{
#' # Sample other delays
#' delays <- other.delay.samp(100, "optimal")
#' summary(delays)
#' }
#'
#' @family sampling functions
#' @importFrom stats runif
#' @export
# other.delay.samp()

# ------------------------------------------------------------------------------
# DETECTION FUNCTIONS
# ------------------------------------------------------------------------------

#' Calculate Passive Detection Times
#'
#' Calculates the time at which infected individuals would be detected through
#' passive surveillance (symptom-based detection) rather than active testing.
#'
#' @param inf.times Numeric vector. Times of infection (days).
#' @param the.scenario Character. TTIQ scenario name.
#'
#' @return Numeric vector of same length as inf.times containing detection times.
#'
#' @details
#' Adds scenario-specific time-to-passive-detection (symptom onset and reporting)
#' to the infection times. This represents detection through healthcare-seeking
#' behavior rather than contact tracing or testing.
#'
#' @examples
#' \dontrun{
#' # Calculate detection times for infections occurring on days 1-5
#' inf_times <- 1:5
#' det_times <- passive.detection(inf_times, "optimal")
#' }
#'
#' @family detection functions
#' @export
# passive.detection()

# ------------------------------------------------------------------------------

#' Sample Passive Detection Time
#'
#' Samples the time to passive detection (symptom-based) for newly infected
#' individuals, without reference to their infection time.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. TTIQ scenario name.
#'
#' @return Numeric vector of length n containing times to passive detection.
#'
#' @details
#' Samples from the scenario-specific distribution of time from infection to
#' symptom-based detection. This is used in no-testing scenarios.
#'
#' @examples
#' \dontrun{
#' passive_times <- passive.detection.only(100, "optimal")
#' summary(passive_times)
#' }
#'
#' @seealso \code{\link{passive.detection}}, \code{\link{active.detection.only}}
#' @family detection functions
#' @export
# passive.detection.only()

# ------------------------------------------------------------------------------

#' Sample Active Detection Time
#'
#' Samples the time to active detection (contact tracing) for close contacts
#' under a specified TTIQ scenario.
#'
#' @param n Integer. Number of samples to draw.
#' @param the.scenario Character. TTIQ scenario name.
#'
#' @return Numeric vector of length n containing times to active detection.
#'
#' @details
#' Samples from the scenario-specific distribution representing the time from
#' index case infection to identification and quarantine of close contacts
#' through active contact tracing.
#'
#' @examples
#' \dontrun{
#' active_times <- active.detection.only(100, "optimal")
#' summary(active_times)
#' }
#'
#' @seealso \code{\link{passive.detection.only}}
#' @family detection functions
#' @export
# active.detection.only()

# ------------------------------------------------------------------------------
# TESTING FUNCTIONS
# ------------------------------------------------------------------------------

#' Simulate Testing Schedule and First Positive Result
#'
#' Models test sensitivity over the viral load trajectory and determines the time
#' of first positive test result for a testing schedule.
#'
#' @param test.times Numeric vector. Days on which tests are administered
#'   (relative to isolation start).
#' @param iso.time Numeric. Time from infection to isolation (days).
#' @param inc.period Numeric. Incubation period (days).
#' @param the.scenario Character. TTIQ scenario name.
#'
#' @return Numeric. Time of first positive test result, or Inf if no tests are positive.
#'
#' @details
#' Test sensitivity is modeled using a logistic function that varies with viral load:
#' \itemize{
#'   \item Pre-peak viral load: Sensitivity increases with time
#'   \item Post-peak viral load: Sensitivity decreases with time
#' }
#'
#' The peak is assumed to occur between 3.5 days before symptom onset and symptom onset.
#'
#' @examples
#' \dontrun{
#' # Test on days 1, 3, and 6 of quarantine
#' first_pos <- testing.function2(
#'   test.times = c(1, 3, 6),
#'   iso.time = 4.5,
#'   inc.period = 5.1,
#'   the.scenario = "optimal"
#' )
#' }
#'
#' @seealso \code{\link{the.test.prob}}
#' @family testing functions
#' @importFrom stats runif
#' @export
# testing.function2()

# ------------------------------------------------------------------------------

#' Calculate Test Sensitivity Probabilities
#'
#' Computes the probability of a positive test result at each specified test time,
#' based on viral load dynamics.
#'
#' @param test.times Numeric vector. Days on which tests are administered.
#' @param iso.time Numeric. Time from infection to isolation (days).
#' @param inc.period Numeric. Incubation period (days).
#'
#' @return Numeric vector of same length as test.times containing test sensitivity
#'   probabilities (0-1).
#'
#' @details
#' Uses the same viral load model as \code{\link{testing.function2}}, but returns
#' probabilities rather than simulating test results.
#'
#' @examples
#' \dontrun{
#' # Get sensitivity probabilities for tests on days 1, 3, and 6
#' probs <- the.test.prob(
#'   test.times = c(1, 3, 6),
#'   iso.time = 4.5,
#'   inc.period = 5.1
#' )
#' }
#'
#' @seealso \code{\link{testing.function2}}
#' @family testing functions
#' @export
# the.test.prob()

# ------------------------------------------------------------------------------
# HELPER FUNCTIONS
# ------------------------------------------------------------------------------

#' Generate Correlated Binary Outcomes
#'
#' Creates correlated binary (0/1) outcomes for household members based on the
#' index case's value and a specified correlation coefficient.
#'
#' @param n Integer. Number of household members.
#' @param corr Numeric. Correlation coefficient (0-1). Higher values mean stronger
#'   correlation between index and household members.
#' @param idx.vac.status Integer. Vaccination status of index case (0 or 1).
#'
#' @return Logical vector of length n indicating vaccination status of each
#'   household member.
#'
#' @details
#' This function is used to model household-correlated vaccination status, reflecting
#' the empirical observation that household members tend to have similar vaccination
#' behavior.
#'
#' With probability \code{corr}, a household member has the same status as the index.
#' With probability \code{1-corr}, they have the opposite status.
#'
#' @examples
#' # Generate vaccination status for 3 household members
#' # Index is vaccinated (1), with 80% correlation
#' cor.binary(n = 3, corr = 0.8, idx.vac.status = 1)
#'
#' @family helper functions
#' @importFrom stats runif
#' @export
# cor.binary()

# ------------------------------------------------------------------------------

#' Reassign Pre/Post-Isolation Infections to Household
#'
#' Reallocates a proportion of infections classified as pre-isolation or post-isolation
#' to household infections, up to the household size limit.
#'
#' @param inf.times Numeric vector. Times of infection (days).
#' @param who Character vector. Infection classification: "preiso", "hh", or "postiso".
#' @param hh.size Integer. Household size.
#' @param p Numeric. Probability (0-1) that a pre/post-isolation infection is
#'   reassigned to household.
#'
#' @return Character vector of same length as who with updated classifications.
#'
#' @details
#' This function accounts for the empirical observation that some infections occurring
#' just before or after the official isolation period may actually be household
#' transmissions. The reassignment is random with probability p, constrained by
#' household size.
#'
#' @family helper functions
#' @export
# hh.infections.pre.or.postiso()

# ------------------------------------------------------------------------------

#' Get Household Size Distribution
#'
#' Retrieves the cumulative distribution of household sizes for a specified
#' Australian state or territory.
#'
#' @param the.state Character. Australian state or territory name (full or abbreviated).
#'
#' @return Named numeric vector containing cumulative proportions for household
#'   sizes 1 through 8+.
#'
#' @details
#' Accesses state-specific household size data from Australian census and returns
#' the cumulative distribution function, used for inverse transform sampling in
#' \code{\link{samp.hh.size}}.
#'
#' @examples
#' \dontrun{
#' # Get NSW household size CDF
#' nsw_hh <- hhsizes("NSW")
#' plot(1:length(nsw_hh), nsw_hh, type = "s",
#'      xlab = "Household Size", ylab = "Cumulative Probability")
#' }
#'
#' @seealso \code{\link{samp.hh.size}}, \code{\link{unabbreviate_states}}
#' @family helper functions
#' @export
# hhsizes()

# ------------------------------------------------------------------------------

#' Convert Data Frame to Named Vector
#'
#' Converts a two-column data frame to a named vector, using the first column as
#' names and the second column as values.
#'
#' @param df Data frame with at least 2 columns. First column will become names,
#'   second column will become values.
#'
#' @return Named vector where names are from column 1 (as characters) and values
#'   are from column 2.
#'
#' @examples
#' df <- data.frame(state = c("NSW", "VIC", "QLD"),
#'                  value = c(0.32, 0.26, 0.20))
#' to.named.vector(df)
#' # Returns: NSW=0.32, VIC=0.26, QLD=0.20
#'
#' @family helper functions
#' @importFrom dplyr pull
#' @export
# to.named.vector()

# ------------------------------------------------------------------------------

#' Generate Testing Schedule Designs
#'
#' Generates all valid testing schedules given constraints on number of tests,
#' minimum spacing between tests, and timing relative to quarantine start.
#'
#' @param times Integer. Number of tests in the schedule.
#' @param n Integer. Maximum day on which tests can occur.
#' @param min.space Integer. Minimum number of days between consecutive tests.
#' @param t1.prior.to Integer. Latest day on which the first test can occur.
#'
#' @return Matrix where each row represents a valid testing schedule.
#'
#' @details
#' This function is useful for evaluating multiple testing strategies and finding
#' optimal schedules. Constraints ensure that:
#' \itemize{
#'   \item Tests are spaced appropriately
#'   \item First test occurs early enough
#'   \item All tests fit within quarantine period
#' }
#'
#' @examples
#' # Generate all 3-test schedules within 14 days
#' # with at least 2 days between tests and first test by day 2
#' designs <- test.designs(times = 3, n = 14, min.space = 2, t1.prior.to = 2)
#' head(designs)
#'
#' @family helper functions
#' @export
# test.designs()

# ------------------------------------------------------------------------------

#' Filter Secondary Infections by Vaccine Effectiveness
#'
#' Applies vaccine effectiveness against transmission and infection to filter
#' which secondary infections occur.
#'
#' @param inf.times Numeric vector. Times of infection.
#' @param vacc.status Integer vector. Index case vaccination status (0 or 1).
#' @param sc.vac.status Integer vector. Secondary case vaccination status (0 or 1).
#'
#' @return Filtered data based on vaccine protection.
#'
#' @details
#' Models the combined effect of vaccination of both the index case (reducing
#' transmission) and secondary case (reducing susceptibility).
#'
#' @family helper functions
#' @export
# sec.inf.vac()

# ==============================================================================
# END OF DOCUMENTATION GUIDE
# ==============================================================================
