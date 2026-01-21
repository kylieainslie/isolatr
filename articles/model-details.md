# Model Details and Methodology

## Overview

This vignette provides an in-depth explanation of the mathematical and
statistical models underlying the **isolatr** package. Understanding
these details will help you:

- Interpret results correctly
- Choose appropriate parameter values
- Assess model limitations
- Extend or modify the model for your needs

## Conceptual Model

The simulation models the following process:

1.  **Index case infection**: An individual (primary close contact) is
    exposed to COVID-19
2.  **Incubation period**: Time from exposure to symptom onset
3.  **Contact tracing**: Index case is identified and quarantined
4.  **Household transmission**: Potential spread within household during
    quarantine
5.  **Testing schedule**: Active testing may detect infection early
6.  **Passive detection**: Symptom development leads to healthcare
    seeking
7.  **Onwards transmission**: Undetected infections may cause tertiary
    cases

The key question: **How many tertiary infections occur from undetected
secondary cases?**

## Mathematical Formulation

### Transmission Model

The number of secondary cases from index case $i$ follows a negative
binomial distribution:

$$n_{cases,i} \sim \text{NegBin}(k,TP)$$

where: - $TP$ = transmission potential (mean) - $k$ = dispersion
parameter (smaller = more overdispersion/superspreading)

### Generation Interval

Time from infection of index case to infection of secondary case $j$:

$$GI_{ij} \sim \text{LogNormal}(\mu = 1.376,\sigma = 0.567)$$

This gives median GI ≈ 3.96 days, calibrated to Australian COVID-19
data.

### Incubation Period

Time from infection to symptom onset for index case $i$:

$$IP_{i} \sim \text{LogNormal}(\mu = 1.63,\sigma = 0.5)$$

Median IP ≈ 5.1 days.

### Household Structure

Household size for index case $i$ in state $s$:

$$HH_{i,s} \sim F_{s}(h)$$

where $F_{s}(h)$ is the empirical CDF of household sizes in state $s$,
derived from Australian census data.

### Vaccination Model

Index case vaccination status:

$$V_{i} \sim \text{Bernoulli}\left( p_{vac,idx} \right)$$

Secondary case vaccination (household members):

$$V_{ij} \sim \begin{cases}
{\text{CorrelatedBinary}\left( V_{i},\rho \right)} & \text{if household member} \\
{\text{Bernoulli}\left( p_{vac,sc} \right)} & \text{otherwise}
\end{cases}$$

where $\rho$ is the household vaccination correlation.

### Vaccine Effectiveness

Probability of infection given exposure:

$$P\left( \text{infection} \mid \text{exposure} \right) = \left( 1 - VE_{trans} \cdot V_{i} \right) \cdot \left( 1 - VE_{inf} \cdot V_{j} \right)$$

where: - $VE_{trans}$ = vaccine effectiveness against transmission
(reduces infectiousness) - $VE_{inf}$ = vaccine effectiveness against
infection (reduces susceptibility)

## Infection Classification

Secondary infections are classified based on timing relative to
isolation:

- **Pre-isolation** ($t_{inf} < t_{iso}$): Occur before index case is
  quarantined
- **Household** ($t_{iso} \leq t_{inf} < t_{iso} + Q_{duration}$): Occur
  during quarantine to household members
- **Post-quarantine** ($t_{inf} \geq t_{iso} + Q_{duration}$): Occur
  after quarantine ends

A proportion of pre-isolation and post-quarantine infections are
randomly reassigned to household (with probability 0.5), up to the
household size limit. This accounts for uncertainty in exact infection
timing.

## Testing Model

### Test Sensitivity

Test sensitivity varies with viral load, which changes over the
infection course. We model sensitivity using a logistic function:

Let $C$ = time of peak viral load (days before symptom onset):
$$C = \min(IP,3.5) \cdot U(0,1)$$

where $U(0,1)$ is uniform random variable.

Time since infection at test $t$: $$s_{t} = t_{iso} + t - 1 - IP - C$$

where $t$ is test day (relative to isolation start).

Test sensitivity:
$$P\left( \text{positive} \mid \text{infected},t \right) = \begin{cases}
\frac{1}{1 + \exp\left( - \left( 1.5 + 2.2s_{t} \right) \right)} & {{\text{if}\mspace{6mu}}s_{t} < 0{\mspace{6mu}\text{(pre-peak)}}} \\
\frac{1}{1 + \exp\left( - \left( 1.5 - 0.22s_{t} \right) \right)} & {{\text{if}\mspace{6mu}}s_{t} \geq 0{\mspace{6mu}\text{(post-peak)}}}
\end{cases}$$

Pre-peak: sensitivity increases as viral load rises Post-peak:
sensitivity decreases as viral load declines

### Time to First Positive Test

For testing schedule
$\mathbf{t} = \left( t_{1},t_{2},\ldots,t_{n} \right)$:

1.  Calculate sensitivity $p_{i}$ at each test time $t_{i}$
2.  Simulate test results:
    $R_{i} \sim \text{Bernoulli}\left( p_{i} \right)$
3.  First positive test: $t_{first} = \min\{ t_{i}:R_{i} = 1\}$ (or
    $\infty$ if all negative)
4.  Add turnaround time: $t_{first} + T_{TAT}$
5.  Add other delays: $t_{first} + T_{TAT} + T_{other}$

where: - $T_{TAT}$ = test turnaround time (scenario-specific) -
$T_{other}$ = interview + notification delays (scenario-specific)

## Detection Model

### Passive Detection

Time to detection through symptoms (without active testing):

$$T_{passive,ij} = t_{inf,ij} + D_{passive}$$

where $D_{passive}$ is sampled from scenario-specific empirical
distribution representing: - Time from infection to symptom onset - Time
from symptoms to healthcare seeking - Time from healthcare seeking to
confirmation

### Active Detection (Contact Tracing)

Time from index case infection to isolation:

$$T_{iso,i} = D_{active}$$

where $D_{active}$ is sampled from scenario-specific distribution
representing: - Time to index case detection - Time to interview index
case - Time to identify and notify close contacts - Time to quarantine
close contacts

## Infection Potential Calculation

For each undetected secondary infection $j$ from index case $i$, the
infection potential is:

$$IP_{ij} = F_{GI}\left( \min\left( t_{detect,ij},t_{passive,ij} \right) - t_{inf,ij} \right) \cdot TP \cdot \left( 1 - VE_{trans} \cdot V_{j} \right)$$

where: - $F_{GI}$ = CDF of generation interval distribution -
$t_{detect,ij}$ = time of detection (via testing or symptoms) -
$t_{inf,ij}$ = time of infection - The CDF term represents the
proportion of onwards transmission that would occur before detection

Total Infection Potential in Quarantine (IPq):

$$IPq = \frac{1}{n_{ind}}\sum\limits_{i = 1}^{n_{ind}}\sum\limits_{j \in \text{undetected}}IP_{ij}$$

## Scenario-Specific Distributions

Each TTIQ scenario has empirical distributions for:

1.  **Time to isolation** (active detection)
2.  **Time to passive detection**
3.  **Test turnaround time**
4.  **Interview delay**
5.  **Notification delay**

These distributions are derived from: - **optimal**: Best-case
assumptions (rapid tracing, fast testing) - **partial**: Moderate
delays - **current_nsw_case_init**: NSW empirical data

The distributions are stored as: - Sampled values (for turnaround
times) - Cumulative probabilities (for inverse transform sampling)

## Key Assumptions

### Included in Model

1.  Household-correlated vaccination
2.  Overdispersed transmission (superspreading)
3.  Time-varying test sensitivity
4.  Scenario-specific detection delays
5.  State-specific household structures
6.  Vaccine effectiveness against transmission and infection

### Not Included in Model

1.  Waning vaccine effectiveness over time
2.  Variant-specific parameters
3.  Age structure
4.  Compliance with quarantine
5.  Re-infection or prior immunity
6.  Test specificity (false positives)
7.  Behavioral changes after testing

## Model Validation

The model parameters are calibrated to:

- **Generation interval**: Australian COVID-19 contact tracing data
- **Incubation period**: Systematic reviews of COVID-19 studies
- **Household sizes**: Australian census data
- **Detection delays**: NSW TTIQ system data

Test sensitivity curves are based on published PCR sensitivity over the
infection course.

## Uncertainty and Sensitivity

Sources of uncertainty:

1.  **Parameter uncertainty**: Epidemiological parameters have
    confidence intervals
2.  **Stochastic uncertainty**: Random variation in simulation
3.  **Model structure**: Simplifying assumptions

To quantify uncertainty:

- Run multiple simulations with different random seeds
- Vary key parameters (TP, k, VE) within plausible ranges
- Compare results across TTIQ scenarios

## Limitations

1.  **Simplified household transmission**: Assumes random mixing within
    households
2.  **No between-household heterogeneity**: All households in a state
    use same size distribution
3.  **Deterministic viral load trajectory**: Peak time is random but
    shape is fixed
4.  **No test specificity**: Assumes no false positives
5.  **Perfect quarantine compliance**: Assumes isolation is complete
    when prescribed
6.  **No serial interval variation**: Uses same distribution for all
    transmission pairs

## References

Generation interval parameterization: \> \[Reference to Australian
COVID-19 study\]

Incubation period: \> \[Reference to systematic review\]

Household size data: \> Australian Bureau of Statistics. Census 2021.

Test sensitivity modeling: \> \[Reference to PCR sensitivity study\]

## See Also

- [`vignette("quick-start-guide")`](../articles/quick-start-guide.md)
  for basic usage
- [`?CQ.sim2`](../reference/CQ.sim2.md) for function documentation
- `vignette("testing-strategies")` for strategy comparison methods
