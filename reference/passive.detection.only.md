# Sample Time to Passive Detection

Draws n samples of time to passive detection (symptom-based) for the
specified TTIQ scenario or custom configuration.

## Usage

``` r
passive.detection.only(n, the.scenario, scenario_config = NULL)
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

Numeric vector of passive detection times in days.
