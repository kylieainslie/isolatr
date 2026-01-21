# Evaluate Quarantine Testing Strategy

Evaluates the effectiveness of a specified testing schedule during
quarantine by calculating the infection potential and mean number of
cases that would occur given the testing regime.

## Usage

``` r
CQ.sim.test.times(CQ.sim.output, n.ind, test.times, VE.trans, the.scenario)
```

## Arguments

- CQ.sim.output:

  Data frame. Output from [`CQ.sim2`](CQ.sim2.md), containing simulated
  secondary infection data.

- n.ind:

  Integer. Number of index cases (must match the n.ind used in CQ.sim2).

- test.times:

  Numeric vector. Days on which tests are administered (relative to
  start of quarantine). For example, c(1, 3, 6) means tests on days 1,
  3, and 6.

- VE.trans:

  Numeric. Vaccine effectiveness against transmission (0-1). Must match
  the value used in [`CQ.sim2`](CQ.sim2.md).

- the.scenario:

  Character. TTIQ scenario name. Must be one of: "optimal", "partial",
  or "current_nsw_case_init".

## Value

A single-row data frame with the following columns:

- IPq:

  Infection Potential in Quarantine - mean number of secondary
  infections per index case that occur before detection via testing or
  symptoms

- sdIPq:

  Standard deviation of infection potential across index cases

- mean.cases:

  Mean number of undetected secondary cases per index case

## Details

This function models the impact of a testing schedule on transmission
during quarantine. For each index case, it:

1.  Determines the time of first positive test using an internal testing
    function

2.  Adds test turnaround time and other delays (interview, notification)

3.  Filters secondary infections that occur before detection

4.  Calculates infection potential for each undetected case

The infection potential (IPq) represents the expected number of tertiary
infections from undetected secondary cases, accounting for:

- Generation interval distribution

- Time remaining until detection

- Transmission potential (TP)

- Vaccine effectiveness against transmission

Lower IPq values indicate more effective testing strategies.

## See also

[`CQ.sim2`](CQ.sim2.md), [`CQ.sim.notest`](CQ.sim.notest.md)

Other simulation functions: [`CQ.sim.notest()`](CQ.sim.notest.md),
[`CQ.sim2()`](CQ.sim2.md)

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

# Evaluate a testing strategy: test on days 1, 3, and 6
evaluation <- CQ.sim.test.times(
  CQ.sim.output = sim_results,
  n.ind = 1000,
  test.times = c(1, 3, 6),
  VE.trans = 0.5,
  the.scenario = "optimal"
)

print(evaluation)
} # }
```
