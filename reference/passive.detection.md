# Calculate Passive Detection Times

Calculates detection times for infected individuals via passive
surveillance (symptom-based detection and healthcare seeking).

## Usage

``` r
passive.detection(inf.times, the.scenario, scenario_config = NULL)
```

## Arguments

- inf.times:

  Numeric vector. Infection times for secondary cases.

- the.scenario:

  Character. Built-in scenario name: "optimal", "partial", or
  "baseline". Ignored if scenario_config is provided.

- scenario_config:

  A scenario_config object created by
  [`create_scenario_config`](create_scenario_config.md). If provided,
  the.scenario is ignored.

## Value

Numeric vector of detection times (infection time + detection delay).

## Details

Passive detection represents symptom-based detection where individuals
seek healthcare due to illness. The delay from infection to detection
depends on incubation period and healthcare-seeking behavior.
