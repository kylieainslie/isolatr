# Sample Interview and Notification Delays

Samples combined delays from notification to interview and from
interview to notifying close contacts.

## Usage

``` r
other.delay.samp(n, the.scenario, scenario_config = NULL)
```

## Arguments

- n:

  Integer. Number of samples to draw.

- the.scenario:

  Character. Built-in scenario name: "optimal", "partial", or
  "baseline". Ignored if scenario_config is provided.

- scenario_config:

  A scenario_config object created by
  [`create_scenario_config`](create_scenario_config.md). If provided,
  the.scenario is ignored.

## Value

Numeric vector of combined delay times in days.

## Details

This function samples two components:

- Interview delay: time from positive test to case interview

- Notification delay: time from interview to notifying close contacts

The sum of these delays is returned.
