# ==============================================================================
# DATASET DOCUMENTATION FOR ISOLATR PACKAGE
# ==============================================================================
# This file documents all data objects included in the package

#' Household Size Distribution by Australian State
#'
#' Synthetic data representing the proportion of households of each size (1-8+ persons)
#' for each Australian state and territory. Based on the structure of Australian
#' census data but containing synthetic values.
#'
#' @format A data frame with 8 rows and 11 columns:
#' \describe{
#'   \item{number}{Household size (1 to 8, where 8 represents 8+ persons)}
#'   \item{New South Wales}{Proportion of households of this size in NSW}
#'   \item{Victoria}{Proportion of households of this size in Victoria}
#'   \item{Queensland}{Proportion of households of this size in Queensland}
#'   \item{South Australia}{Proportion of households of this size in SA}
#'   \item{Western Australia}{Proportion of households of this size in WA}
#'   \item{Tasmania}{Proportion of households of this size in Tasmania}
#'   \item{Northern Territory}{Proportion of households of this size in NT}
#'   \item{Australian Capital Territory}{Proportion of households of this size in ACT}
#'   \item{Other Territories}{Proportion of households for other territories}
#'   \item{Total}{Overall proportion across all of Australia}
#' }
#'
#' @details
#' This synthetic dataset is used by internal functions
#' to sample realistic household sizes when simulating quarantine scenarios.
#'
#' The proportions are probability mass functions (sum to 1.0 for each state).
#' To use for sampling, these are converted to cumulative distributions.
#'
#' @source Synthetic data generated to match the structure of Australian census data
#' @examples
#' # View household size distribution for NSW
#' hhsize.dat[, c("number", "New South Wales")]
#'
#' # Calculate mean household size for Victoria
#' weighted.mean(hhsize.dat$number, hhsize.dat$Victoria)
"hhsize.dat"

#' TTIQ Scenario Detection Time Distributions
#'
#' Synthetic data containing time to detection (passive and active) for different
#' Test-Trace-Isolate-Quarantine (TTIQ) scenarios. Each scenario represents a
#' different level of public health system performance.
#'
#' @format A data frame with 30,000 rows and 3 columns:
#' \describe{
#'   \item{scenario}{Character. TTIQ scenario name: "optimal", "partial", or "current_nsw_case_init"}
#'   \item{time_to_passive}{Numeric. Time (days) from infection to passive detection
#'     (symptom-based detection and healthcare seeking)}
#'   \item{time_to_active}{Numeric. Time (days) from index case infection to
#'     isolation of close contacts via contact tracing}
#' }
#'
#' @details
#' Three scenarios are included:
#' \describe{
#'   \item{optimal}{Fast contact tracing and testing with minimal delays}
#'   \item{partial}{Moderate delays in tracing and testing processes}
#'   \item{current_nsw_case_init}{NSW baseline performance (case-initiated tracing)}
#' }
#'
#' This dataset is sampled by internal detection and timing functions
#' when modeling quarantine scenarios.
#'
#' @source Synthetic data generated from lognormal distributions with scenario-specific parameters
#' @examples
#' # Compare median detection times across scenarios
#' library(dplyr)
#' distn.dat %>%
#'   group_by(scenario) %>%
#'   summarise(
#'     median_passive = median(time_to_passive),
#'     median_active = median(time_to_active)
#'   )
"distn.dat"

#' Test Turnaround Times - Optimal Scenario
#'
#' Synthetic data representing test turnaround times (from sample collection to
#' result notification) under optimal TTIQ conditions.
#'
#' @format A numeric vector of length 100,000 containing turnaround times in days.
#'
#' @details
#' Represents fast testing with most results returned within 1 day. Used by
#' internal sampling functions when scenario is "optimal".
#'
#' @source Synthetic data generated from gamma distribution
#' @examples
#' # Summary statistics
#' summary(optimal.tat.dat)
#' median(optimal.tat.dat)
"optimal.tat.dat"

#' Test Turnaround Times - Partial Scenario
#'
#' Synthetic data representing test turnaround times under moderate delay conditions.
#'
#' @format A numeric vector of length 100,000 containing turnaround times in days.
#'
#' @details
#' Represents moderate testing delays with median around 2 days. Used by
#' internal sampling functions when scenario is "partial".
#'
#' @source Synthetic data generated from gamma distribution
#' @examples
#' summary(partial.tat.dat)
"partial.tat.dat"

#' Test Turnaround Times - NSW Case-Initiated Scenario
#'
#' Synthetic data representing test turnaround times under NSW baseline conditions.
#'
#' @format A numeric vector of length 100,000 containing turnaround times in days.
#'
#' @details
#' Represents NSW case-initiated testing performance with median around 1.5-2 days.
#' Used by internal sampling functions when scenario is "current_nsw_case_init".
#'
#' @source Synthetic data generated from gamma distribution
#' @examples
#' summary(nsw.ci.tat.dat)
"nsw.ci.tat.dat"

#' Interview Delay Distribution - Optimal Scenario
#'
#' Cumulative distribution function for time to interview index cases under
#' optimal conditions.
#'
#' @format A data frame with 11 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days from case detection to interview completion (0-10)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' Used for inverse transform sampling in internal delay functions.
#' Fast interviews with median ~0.5 days.
#'
#' @source Synthetic data from exponential CDF
"optimal.interview.dat"

#' Interview Delay Distribution - Partial Scenario
#'
#' Cumulative distribution function for time to interview index cases under
#' moderate delay conditions.
#'
#' @format A data frame with 11 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days (0-10)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' Moderate interview delays with median ~1.5 days.
#'
#' @source Synthetic data from exponential CDF
"partial.interview.dat"

#' Interview Delay Distribution - NSW Case-Initiated Scenario
#'
#' Cumulative distribution function for time to interview index cases under
#' NSW baseline conditions.
#'
#' @format A data frame with 11 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days (0-10)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' NSW case-initiated interview delays with median ~1.0 day.
#'
#' @source Synthetic data from exponential CDF
"nsw.ci.interview.dat"

#' Close Contact Notification Delay - Optimal Scenario
#'
#' Cumulative distribution function for time to notify and quarantine close
#' contacts under optimal conditions.
#'
#' @format A data frame with 16 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days from interview to contact notification (0-15)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' Fast contact notification with median ~0.8 days.
#'
#' @source Synthetic data from exponential CDF
"optimal.cc.notify.dat"

#' Close Contact Notification Delay - Partial Scenario
#'
#' Cumulative distribution function for time to notify and quarantine close
#' contacts under moderate delay conditions.
#'
#' @format A data frame with 16 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days (0-15)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' Moderate notification delays with median ~2.5 days.
#'
#' @source Synthetic data from exponential CDF
"partial.cc.notify.dat"

#' Close Contact Notification Delay - NSW Case-Initiated Scenario
#'
#' Cumulative distribution function for time to notify and quarantine close
#' contacts under NSW baseline conditions.
#'
#' @format A data frame with 16 rows and 2 columns:
#' \describe{
#'   \item{delay}{Numeric. Days (0-15)}
#'   \item{cum_prob}{Numeric. Cumulative probability (0-1)}
#' }
#'
#' @details
#' NSW notification delays with median ~1.5 days.
#'
#' @source Synthetic data from exponential CDF
"nsw.ci.cc.notify.dat"
