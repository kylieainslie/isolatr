# Evaluate Isolation Without Active Testing

Evaluates isolation effectiveness when relying solely on passive
detection (symptom-based detection) without any active testing schedule.
This serves as a baseline comparison for testing strategies.

## Usage

``` r
CQ.sim.notest(
  CQ.sim.output,
  n.ind,
  TP,
  VE.trans,
  the.scenario,
  scenario_config = NULL,
  gi_meanlog = 1.376,
  gi_sdlog = 0.567
)
```

## Arguments

- CQ.sim.output:

  Data frame. Output from [`CQ.sim2`](CQ.sim2.md), containing simulated
  secondary infection data.

- n.ind:

  Integer. Number of index cases (must match the n.ind used in CQ.sim2).

- TP:

  Numeric. Transmission potential - should match value used in CQ.sim2.

- VE.trans:

  Numeric. Vaccine effectiveness against transmission (0-1). Must match
  the value used in [`CQ.sim2`](CQ.sim2.md).

- the.scenario:

  Character. TTIQ scenario name: "optimal", "partial", or "baseline".

- scenario_config:

  A scenario_config object. If provided, overrides the.scenario.

- gi_meanlog:

  Numeric. Generation interval meanlog. Default 1.376 (COVID-19).

- gi_sdlog:

  Numeric. Generation interval sdlog. Default 0.567 (COVID-19).

## Value

A single-row data frame with the following columns:

- IPq:

  Infection Potential in Quarantine - mean number of secondary
  infections per index case that occur before passive detection

- sdIPq:

  Standard deviation of infection potential across index cases

- mean.cases:

  Mean number of undetected secondary cases per index case

## Details

This function evaluates a no-testing scenario where infected individuals
are only detected when they develop symptoms (passive detection). This
provides a baseline for comparing the effectiveness of active testing
strategies.

The function:

1.  Samples time to passive detection for each case

2.  Adds test turnaround time (time from symptom onset to confirmation)

3.  Filters infections occurring before detection

4.  Calculates infection potential based on remaining infectious period

## See also

[`CQ.sim2`](CQ.sim2.md), [`CQ.sim.test.times`](CQ.sim.test.times.md)

Other simulation functions:
[`CQ.sim.test.times()`](CQ.sim.test.times.md), [`CQ.sim2()`](CQ.sim2.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# First, run the simulation
set.seed(42)
sim_results <- CQ.sim2(
  n.ind = 1000, TP = 3.0, k = 0.25,
  p.vac.idx = 0.7, p.vac.sc = 0.7, vacc.cor = 0.8,
  VE.trans = 0.5, VE.inf = 0.7,
  quarantine.duration = 14,
  the.scenario = "optimal"
)

# Evaluate isolation without testing
baseline <- CQ.sim.notest(
  CQ.sim.output = sim_results,
  n.ind = 1000,
  TP = 3.0,
  VE.trans = 0.5,
  the.scenario = "optimal"
)

print(baseline)
} # }
```
