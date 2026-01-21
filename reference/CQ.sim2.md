# Community Quarantine Simulation for Primary Close Contacts

Simulates COVID-19 transmission from index cases to secondary cases
during quarantine, accounting for household structure, vaccination
status, isolation timing, and testing/tracing scenarios.

## Usage

``` r
CQ.sim2(
  n.ind,
  TP,
  k,
  p.vac.idx,
  p.vac.sc,
  vacc.cor,
  VE.trans,
  VE.inf,
  quarantine.duration,
  the.scenario,
  the.state = "NSW"
)
```

## Arguments

- n.ind:

  Integer. Number of index cases (primary close contacts) to simulate.

- TP:

  Numeric. Transmission potential - the mean number of secondary cases
  per index case (analogous to R0 in a fully susceptible population).

- k:

  Numeric. Dispersion parameter for the negative binomial distribution
  of secondary cases. Lower values indicate greater overdispersion
  (superspreading).

- p.vac.idx:

  Numeric. Probability that an index case is vaccinated (0-1).

- p.vac.sc:

  Numeric. Probability that a secondary case is vaccinated (0-1), for
  non-household contacts.

- vacc.cor:

  Numeric. Correlation coefficient (0-1) for vaccination status within
  households. Higher values mean household members are more likely to
  have the same vaccination status.

- VE.trans:

  Numeric. Vaccine effectiveness against transmission (0-1). Reduces
  probability that a vaccinated index case transmits infection.

- VE.inf:

  Numeric. Vaccine effectiveness against infection (0-1). Reduces
  probability that a vaccinated secondary case becomes infected.

- quarantine.duration:

  Numeric. Duration of quarantine period in days.

- the.scenario:

  Character. TTIQ scenario name. Must be one of: "optimal", "partial",
  or "current_nsw_case_init".

- the.state:

  Character. Australian state or territory for household size
  distribution. Default is "NSW". See
  [`abbreviate_states`](abbreviate_states.md) for valid values.

## Value

A data frame with one row per secondary infection (among unprotected
individuals), containing the following columns:

- i:

  Index case ID (1 to n.ind)

- vacc.status:

  Vaccination status of index case (0 or 1)

- inc.period:

  Incubation period of index case (days)

- iso.time:

  Time to isolation of index case (days)

- ncases:

  Number of secondary cases from this index case

- hh.size:

  Household size of index case

- inf.times:

  Time of infection for this secondary case (days since index case
  infection)

- who:

  Classification of infection: "preiso" (before isolation), "hh"
  (household member), or "postiso" (after quarantine)

- sc.vac.status:

  Vaccination status of secondary case (0 or 1)

- det:

  Time to passive detection for this secondary case

## Details

This function implements a stochastic simulation model of COVID-19
transmission during quarantine. The model:

1.  Samples individual-level characteristics (vaccination, incubation
    period, isolation time, household size) for each index case

2.  Samples the number of secondary cases from a negative binomial
    distribution

3.  Samples generation intervals (time between successive infections)
    from a lognormal distribution calibrated to Australian COVID-19 data

4.  Classifies infections as occurring before isolation, within
    household during quarantine, or post-quarantine

5.  Models household-correlated vaccination status

6.  Calculates passive detection times based on the TTIQ scenario

7.  Filters infections based on vaccine effectiveness

The function uses the following epidemiological distributions:

- Incubation period: Lognormal(μ=1.63, σ=0.5)

- Generation interval: Lognormal(μ=1.376, σ=0.567) - Australian COVID-19
  baseline

- Number of secondary cases: Negative Binomial(size=k, μ=TP)

## Note

**Important:** This function previously included a hard-coded
`set.seed(1)` which has been removed. Users should set their own seed
before calling this function if reproducibility is required.

## See also

Other simulation functions: [`CQ.sim.notest()`](CQ.sim.notest.md),
[`CQ.sim.test.times()`](CQ.sim.test.times.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Simulate 1000 index cases with moderate transmission
set.seed(42)
results <- CQ.sim2(
  n.ind = 1000,
  TP = 3.0,
  k = 0.25,
  p.vac.idx = 0.7,
  p.vac.sc = 0.7,
  vacc.cor = 0.8,
  VE.trans = 0.5,
  VE.inf = 0.7,
  quarantine.duration = 14,
  the.scenario = "optimal",
  the.state = "NSW"
)

# Examine distribution of infection times
summary(results$who)
} # }
```
