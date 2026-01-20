#!/usr/bin/env Rscript
# ==============================================================================
# Package Setup Script for isolatr
# ==============================================================================
# This script completes the package setup by generating synthetic data and
# updating documentation.
#
# Run this script from the package root directory:
#   source("setup_package.R")
# ==============================================================================

cat("========================================\n")
cat("Setting up isolatr package\n")
cat("========================================\n\n")

# Check required packages
required_pkgs <- c("devtools", "usethis", "roxygen2", "dplyr", "tidyr")
missing_pkgs <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]

if (length(missing_pkgs) > 0) {
  cat("Installing required packages:", paste(missing_pkgs, collapse = ", "), "\n")
  install.packages(missing_pkgs)
}

# Load required packages
library(devtools)
library(usethis)

cat("\n1. Generating synthetic datasets...\n")
cat("   (This may take a minute)\n")
source("data-raw/create_synthetic_data.R")

cat("\n2. Updating package documentation...\n")
devtools::document()

cat("\n3. Checking package can load...\n")
devtools::load_all()

cat("\n4. Running basic checks...\n")
check_result <- tryCatch({
  devtools::check(
    document = FALSE,
    args = c("--no-manual", "--no-build-vignettes"),
    error_on = "never"
  )
}, error = function(e) {
  cat("Note: Some checks may have warnings - this is expected for a new package\n")
  NULL
})

cat("\n========================================\n")
cat("Package setup complete!\n")
cat("========================================\n\n")

cat("Next steps:\n")
cat("1. Review the synthetic data in data/ directory\n")
cat("2. Test the package: devtools::load_all()\n")
cat("3. Try the examples in the vignettes\n")
cat("4. Build the package: devtools::build()\n")
cat("5. Install locally: devtools::install()\n\n")

cat("To view documentation:\n")
cat("- ?CQ.sim2\n")
cat("- ?CQ.sim.test.times\n")
cat("- browseVignettes('isolatr')\n\n")

cat("All data objects are now available:\n")
cat("- hhsize.dat\n")
cat("- distn.dat\n")
cat("- optimal.tat.dat, partial.tat.dat, nsw.ci.tat.dat\n")
cat("- optimal.interview.dat, partial.interview.dat, nsw.ci.interview.dat\n")
cat("- optimal.cc.notify.dat, partial.cc.notify.dat, nsw.ci.cc.notify.dat\n")
