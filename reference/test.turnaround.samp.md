# Sample Test Turnaround Times

Draws n samples from the test turnaround time distribution for the
specified TTIQ scenario or custom configuration.

## Usage

``` r
test.turnaround.samp(n, the.scenario, scenario_config = NULL)
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

Numeric vector of test turnaround times in days.

## Details

Test turnaround time is the delay from sample collection to result
notification. This varies by testing capacity and scenario.
