# ==============================================================================
# Create Synthetic Datasets for isolatr Package
# ==============================================================================
# This script generates synthetic data that matches the structure and
# statistical properties of the real datasets, but contains no actual data.
# Run this script to generate the package data objects.
# ==============================================================================

library(dplyr)
library(tidyr)

set.seed(42)  # For reproducibility

# ==============================================================================
# 1. HOUSEHOLD SIZE DATA BY STATE
# ==============================================================================
# Based on Australian census data structure
# Proportions for household sizes 1-8+ by state

states <- c("New South Wales", "Victoria", "Queensland", "South Australia",
            "Western Australia", "Tasmania", "Northern Territory",
            "Australian Capital Territory", "Other Territories", "Total")

# Generate realistic household size distributions
# Generally: 1-person (10-14%), 2-person (25-29%), 3-person (18-20%),
# 4-person (23-25%), 5-person (11-13%), 6-8+ (declining)

generate_hh_distribution <- function() {
  # Sample from realistic ranges
  p1 <- runif(1, 0.097, 0.135)
  p2 <- runif(1, 0.245, 0.310)
  p3 <- runif(1, 0.170, 0.197)
  p4 <- runif(1, 0.206, 0.287)
  p5 <- runif(1, 0.103, 0.135)
  p6 <- runif(1, 0.039, 0.070)
  p7 <- runif(1, 0.011, 0.035)
  p8 <- 1 - sum(p1, p2, p3, p4, p5, p6, p7)

  c(p1, p2, p3, p4, p5, p6, p7, p8)
}

hhsize_matrix <- sapply(states, function(s) generate_hh_distribution())

hhsize.dat <- data.frame(
  number = 1:8,
  hhsize_matrix
)

# Clean column names
colnames(hhsize.dat) <- c("number", states)

print("Household size data created:")
print(head(hhsize.dat))

# ==============================================================================
# 2. TTIQ SCENARIO DISTRIBUTION DATA
# ==============================================================================
# Time to passive and active detection for each scenario

n_samples <- 10000

# Optimal scenario: Fast detection
optimal_passive <- rlnorm(n_samples, meanlog = 1.8, sdlog = 0.6)  # ~median 6 days
optimal_active <- rlnorm(n_samples, meanlog = 1.2, sdlog = 0.5)   # ~median 3.3 days

# Partial scenario: Moderate delays
partial_passive <- rlnorm(n_samples, meanlog = 2.2, sdlog = 0.7)  # ~median 9 days
partial_active <- rlnorm(n_samples, meanlog = 1.6, sdlog = 0.6)   # ~median 5 days

# NSW case-initiated scenario: Baseline performance
nsw_passive <- rlnorm(n_samples, meanlog = 2.0, sdlog = 0.65)     # ~median 7.4 days
nsw_active <- rlnorm(n_samples, meanlog = 1.5, sdlog = 0.55)      # ~median 4.5 days

distn.dat <- bind_rows(
  data.frame(
    scenario = "optimal",
    time_to_passive = optimal_passive,
    time_to_active = optimal_active
  ),
  data.frame(
    scenario = "partial",
    time_to_passive = partial_passive,
    time_to_active = partial_active
  ),
  data.frame(
    scenario = "current_nsw_case_init",
    time_to_passive = nsw_passive,
    time_to_active = nsw_active
  )
)

print("Distribution data created:")
print(distn.dat %>% group_by(scenario) %>%
        summarise(
          median_passive = median(time_to_passive),
          median_active = median(time_to_active)
        ))

# ==============================================================================
# 3. TEST TURNAROUND TIME DATA
# ==============================================================================
# Sampled test turnaround times for each scenario

n_tat_samples <- 100000

# Optimal: Fast turnaround (mostly <1 day)
optimal.tat.dat <- rgamma(n_tat_samples, shape = 2, rate = 3)  # ~mean 0.67 days

# Partial: Moderate delays
partial.tat.dat <- rgamma(n_tat_samples, shape = 2, rate = 1)  # ~mean 2 days

# NSW: Baseline
nsw.ci.tat.dat <- rgamma(n_tat_samples, shape = 2.5, rate = 1.5)  # ~mean 1.67 days

print("Test turnaround time data created:")
print(paste("Optimal median:", round(median(optimal.tat.dat), 2), "days"))
print(paste("Partial median:", round(median(partial.tat.dat), 2), "days"))
print(paste("NSW median:", round(median(nsw.ci.tat.dat), 2), "days"))

# ==============================================================================
# 4. INTERVIEW DELAY DATA
# ==============================================================================
# Cumulative probabilities for interview delays (in days)

create_interview_cdf <- function(median_delay) {
  # Create CDF for delays from 0 to 10 days
  days <- 0:10
  # Use exponential-like distribution
  cdf <- pexp(days, rate = 1/median_delay)
  data.frame(delay = days, cum_prob = cdf)
}

optimal.interview.dat <- create_interview_cdf(median_delay = 0.5)
partial.interview.dat <- create_interview_cdf(median_delay = 1.5)
nsw.ci.interview.dat <- create_interview_cdf(median_delay = 1.0)

print("Interview delay data created:")
print(paste("Optimal 50th percentile:",
            optimal.interview.dat$delay[which.min(abs(optimal.interview.dat$cum_prob - 0.5))]))

# ==============================================================================
# 5. CONTACT NOTIFICATION DELAY DATA
# ==============================================================================
# Cumulative probabilities for close contact notification delays

create_notify_cdf <- function(median_delay) {
  days <- 0:15
  cdf <- pexp(days, rate = 1/median_delay)
  data.frame(delay = days, cum_prob = cdf)
}

optimal.cc.notify.dat <- create_notify_cdf(median_delay = 0.8)
partial.cc.notify.dat <- create_notify_cdf(median_delay = 2.5)
nsw.ci.cc.notify.dat <- create_notify_cdf(median_delay = 1.5)

print("Contact notification delay data created")

# ==============================================================================
# SAVE ALL DATASETS
# ==============================================================================

usethis::use_data(hhsize.dat, overwrite = TRUE)
usethis::use_data(distn.dat, overwrite = TRUE)
usethis::use_data(optimal.tat.dat, overwrite = TRUE)
usethis::use_data(partial.tat.dat, overwrite = TRUE)
usethis::use_data(nsw.ci.tat.dat, overwrite = TRUE)
usethis::use_data(optimal.interview.dat, overwrite = TRUE)
usethis::use_data(partial.interview.dat, overwrite = TRUE)
usethis::use_data(nsw.ci.interview.dat, overwrite = TRUE)
usethis::use_data(optimal.cc.notify.dat, overwrite = TRUE)
usethis::use_data(partial.cc.notify.dat, overwrite = TRUE)
usethis::use_data(nsw.ci.cc.notify.dat, overwrite = TRUE)

cat("\n✓ All synthetic datasets created and saved to data/\n")
cat("✓ Total of 11 data objects created\n")
cat("\nNext steps:\n")
cat("1. Document the datasets in R/data.R\n")
cat("2. Run devtools::document() to update documentation\n")
cat("3. Run devtools::load_all() to test the package\n")
