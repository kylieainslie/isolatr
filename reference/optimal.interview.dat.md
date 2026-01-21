# Interview Delay Distribution - Optimal Scenario

Cumulative distribution function for time to interview index cases under
optimal conditions.

## Usage

``` r
optimal.interview.dat
```

## Format

A data frame with 11 rows and 2 columns:

- delay:

  Numeric. Days from case detection to interview completion (0-10)

- cum_prob:

  Numeric. Cumulative probability (0-1)

## Source

Synthetic data from exponential CDF

## Details

Used for inverse transform sampling in internal delay functions. Fast
interviews with median ~0.5 days.
