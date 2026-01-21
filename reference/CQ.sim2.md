# Isolation Simulation for Close Contacts

Simulates disease transmission from index cases to secondary cases
during isolation, accounting for household structure, vaccination
status, isolation timing, and testing/tracing scenarios. While defaults
are calibrated to COVID-19, the function can be used for any
communicable disease by adjusting the epidemiological parameters.

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
  the.state = NULL,
  region = "NSW",
  hh_probs = NULL,
  inc_meanlog = 1.63,
  inc_sdlog = 0.5,
  gi_meanlog = 1.376,
  gi_sdlog = 0.567,
  hh_transmission_prob = 0.5
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

  Numeric. Duration of quarantine/isolation period in days.

- the.scenario:

  Character. TTIQ scenario name. Must be one of: "optimal", "partial",
  "baseline", or "current_nsw_case_init" (deprecated alias for
  baseline).

- the.state:

  Character. Deprecated, use `region` instead.

- region:

  Character. Region name for household size distribution. Default is
  "NSW". See [`abbreviate_states`](abbreviate_states.md) for valid
  Australian values. Ignored if `hh_probs` is provided.

- hh_probs:

  Numeric vector. Custom household size probabilities for sizes 1-8+.
  Must sum to 1 and have length 8. If provided, `region` is ignored.

- inc_meanlog:

  Numeric. Mean of incubation period distribution on log scale. Default
  is 1.63 (COVID-19, ~5.1 day median).

- inc_sdlog:

  Numeric. SD of incubation period distribution on log scale. Default is
  0.5 (COVID-19).

- gi_meanlog:

  Numeric. Mean of generation interval distribution on log scale.
  Default is 1.376 (COVID-19, ~3.96 day median).

- gi_sdlog:

  Numeric. SD of generation interval distribution on log scale. Default
  is 0.567 (COVID-19).

- hh_transmission_prob:

  Numeric. Probability that a pre-isolation infection occurs within the
  household (vs community). Default is 0.5.

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

This function implements a stochastic simulation model of disease
transmission during isolation/quarantine. The model:

1.  Samples individual-level characteristics (vaccination, incubation
    period, isolation time, household size) for each index case

2.  Samples the number of secondary cases from a negative binomial
    distribution

3.  Samples generation intervals (time between successive infections)
    from a lognormal distribution

4.  Classifies infections as occurring before isolation, within
    household during quarantine, or post-quarantine

5.  Models household-correlated vaccination status

6.  Calculates passive detection times based on the TTIQ scenario

7.  Filters infections based on vaccine effectiveness

The function uses lognormal distributions for incubation period and
generation interval. Default parameters are calibrated to COVID-19, but
can be customized for other diseases:

- COVID-19 (default): inc_meanlog=1.63, gi_meanlog=1.376

- Influenza: inc_meanlog≈0.34, gi_meanlog≈0.91

- SARS: inc_meanlog≈1.39, gi_meanlog≈2.0

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
