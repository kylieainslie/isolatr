# Generation Interval Cumulative Distribution Function

Returns the CDF of the lognormal generation interval distribution.

## Usage

``` r
gi.dist.cdf(q, meanlog = 1.376, sdlog = 0.567)
```

## Arguments

- q:

  Numeric vector. Quantiles (time values in days).

- meanlog:

  Numeric. Mean of the distribution on the log scale. Default is 1.376
  (COVID-19 estimate).

- sdlog:

  Numeric. Standard deviation of the distribution on the log scale.
  Default is 0.567 (COVID-19 estimate).

## Value

Numeric vector of cumulative probabilities.

## Details

Used to calculate the proportion of secondary transmissions that would
have occurred by a given time point. This is used in calculating
infection potential.

## Examples

``` r
# Probability of transmission within 5 days (COVID-19)
gi.dist.cdf(5)
#> [1] 0.6597229

# Probability of transmission within 3 days (Influenza)
gi.dist.cdf(3, meanlog = 0.91, sdlog = 0.52)
#> [1] 0.6415915
```
