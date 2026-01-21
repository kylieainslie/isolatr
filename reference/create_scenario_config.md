# Create a Custom Scenario Configuration

Creates a configuration object for custom TTIQ
(Test-Trace-Isolate-Quarantine) scenarios with user-specified
distributions for detection times and delays.

## Usage

``` r
create_scenario_config(
  name = "custom",
  active_detection = list(type = "lognormal", meanlog = 1.2, sdlog = 0.5),
  passive_detection = list(type = "lognormal", meanlog = 1.8, sdlog = 0.6),
  test_turnaround = list(type = "gamma", shape = 2, rate = 3),
  interview_delay = list(type = "exponential", rate = 2),
  notification_delay = list(type = "exponential", rate = 1.25)
)
```

## Arguments

- name:

  Character. Name for the custom scenario.

- active_detection:

  List. Distribution for time to active detection (contact tracing).
  Must contain: type ("lognormal", "gamma", or "exponential") and
  appropriate parameters.

- passive_detection:

  List. Distribution for time to passive detection (symptoms). Must
  contain: type and appropriate parameters.

- test_turnaround:

  List. Distribution for test turnaround time. Must contain: type and
  appropriate parameters.

- interview_delay:

  List. Distribution for interview delay. Must contain: type and
  appropriate parameters.

- notification_delay:

  List. Distribution for contact notification delay. Must contain: type
  and appropriate parameters.

## Value

A list of class "scenario_config" containing the scenario specification.

## Details

Each distribution list should specify:

- For "lognormal": meanlog, sdlog

- For "gamma": shape, rate (or scale)

- For "exponential": rate

## Examples

``` r
# Create a custom scenario for a different disease
custom <- create_scenario_config(
  name = "influenza_rapid",
  active_detection = list(type = "lognormal", meanlog = 0.8, sdlog = 0.4),
  passive_detection = list(type = "lognormal", meanlog = 1.2, sdlog = 0.5),
  test_turnaround = list(type = "exponential", rate = 2),
  interview_delay = list(type = "exponential", rate = 1),
  notification_delay = list(type = "exponential", rate = 0.8)
)
```
