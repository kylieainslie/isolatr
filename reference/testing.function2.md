# Simulate Testing and Determine First Positive

Models test sensitivity over the viral load trajectory and determines
the time of first positive test result.

## Usage

``` r
testing.function2(
  test.times,
  iso.time,
  inc.period,
  the.scenario,
  test_intercept = 1.5,
  test_slope_prepeak = 2.2,
  test_slope_postpeak = 0.22
)
```

## Arguments

- test.times:

  Numeric vector. Days on which tests are administered (relative to
  start of isolation).

- iso.time:

  Numeric. Time of isolation onset.

- inc.period:

  Numeric. Incubation period for this individual.

- the.scenario:

  Character. TTIQ scenario name (currently unused but retained for API
  consistency).

- test_intercept:

  Numeric. Intercept for the logistic test sensitivity model. Default is
  1.5.

- test_slope_prepeak:

  Numeric. Slope for pre-peak (rising) viral load. Default is 2.2.

- test_slope_postpeak:

  Numeric. Slope for post-peak (declining) viral load. Default is 0.22.

## Value

Numeric. Time of first positive test, or Inf if no positive tests.

## Details

Test sensitivity is modeled using a logistic function that varies with
the timing relative to symptom onset (peak viral load):

- Pre-peak: sensitivity increases as viral load rises

- Post-peak: sensitivity decreases as viral load declines

The default parameters are calibrated to PCR testing for COVID-19. For
rapid antigen tests or other diseases, adjust the coefficients
accordingly.
