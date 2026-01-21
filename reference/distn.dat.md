# TTIQ Scenario Detection Time Distributions

Synthetic data containing time to detection (passive and active) for
different Test-Trace-Isolate-Quarantine (TTIQ) scenarios. Each scenario
represents a different level of public health system performance.

## Usage

``` r
distn.dat
```

## Format

A data frame with 30,000 rows and 3 columns:

- scenario:

  Character. TTIQ scenario name: "optimal", "partial", or
  "current_nsw_case_init"

- time_to_passive:

  Numeric. Time (days) from infection to passive detection
  (symptom-based detection and healthcare seeking)

- time_to_active:

  Numeric. Time (days) from index case infection to isolation of close
  contacts via contact tracing

## Source

Synthetic data generated from lognormal distributions with
scenario-specific parameters

## Details

Three scenarios are included:

- optimal:

  Fast contact tracing and testing with minimal delays

- partial:

  Moderate delays in tracing and testing processes

- current_nsw_case_init:

  NSW baseline performance (case-initiated tracing)

This dataset is sampled by internal detection and timing functions when
modeling quarantine scenarios.

## Examples

``` r
# Compare median detection times across scenarios
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
distn.dat %>%
  group_by(scenario) %>%
  summarise(
    median_passive = median(time_to_passive),
    median_active = median(time_to_active)
  )
#> # A tibble: 3 × 3
#>   scenario              median_passive median_active
#>   <chr>                          <dbl>         <dbl>
#> 1 current_nsw_case_init           7.37          4.49
#> 2 optimal                         6.03          3.33
#> 3 partial                         9.10          4.99
```
