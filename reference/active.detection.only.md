# Sample Time to Active Detection

Draws n samples of time to active detection (contact tracing) for the
specified TTIQ scenario or custom configuration.

## Usage

``` r
active.detection.only(n, the.scenario, scenario_config = NULL)
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

Numeric vector of active detection times in days.
