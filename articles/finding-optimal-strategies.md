# Finding Optimal Testing Strategies

## Introduction

This vignette demonstrates a complete workflow for systematically
evaluating and identifying optimal testing strategies for isolated
individuals. While we use COVID-19 parameters as an example, the methods
apply to any infectious disease.

The workflow shows how to:

1.  Generate all possible testing schedules within constraints
2.  Evaluate each schedule in parallel for computational efficiency
3.  Identify optimal schedules for different scenarios and isolation
    durations
4.  Visualize and compare results

This approach allows policy-makers to balance test resources against
transmission reduction.

## Setup

``` r
library(isolatr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(foreach)
library(doParallel)
```

## Define Simulation Parameters

First, define the epidemiological and intervention parameters. This
example uses COVID-19 parameters, but these can be adjusted for other
diseases.

``` r
# Epidemiological parameters (COVID-19 example)
n.ind <- 100000  # Large sample for stable estimates
TP <- 1.2        # Transmission potential
k <- 0.2         # Dispersion parameter (superspreading)

# Vaccination parameters
p.vac.idx <- 0.723   # Index case vaccination probability
p.vac.sc <- 0.723    # Secondary case vaccination probability
vacc.cor <- 0.9      # Household vaccination correlation

# Vaccine effectiveness
VE.trans <- 0.4      # Against transmission
VE.inf <- 0.72       # Against infection

# Region for household sizes (or use hh_probs for custom)
region <- "NSW"

# Epidemiological distributions (COVID-19 defaults)
# For other diseases, adjust these:
inc_meanlog <- 1.63   # Incubation period meanlog
inc_sdlog <- 0.5      # Incubation period sdlog
gi_meanlog <- 1.376   # Generation interval meanlog
gi_sdlog <- 0.567     # Generation interval sdlog

# TTIQ scenarios to evaluate
the.scenarios <- c("optimal", "partial", "baseline")

# Isolation durations to evaluate
quarantine.durations <- c(14, 7)
```

### Adapting for Other Diseases

To evaluate testing strategies for influenza or another disease, modify
the parameters:

``` r
# Influenza example
TP <- 1.5
k <- 0.5
inc_meanlog <- 0.34    # ~1.4 day median
inc_sdlog <- 0.42
gi_meanlog <- 0.91     # ~2.5 day median
gi_sdlog <- 0.52
quarantine.durations <- c(7, 5)  # Shorter isolation
```

## Generate Testing Schedules

Use `test.designs()` to systematically generate all valid testing
schedules:

``` r
# Maximum possible test days
max_days <- max(quarantine.durations)

# Minimum spacing between tests (e.g., 2 days)
min.space <- 2

# Generate all schedules with 1, 2, or 3 tests
all.times3 <- test.designs(
  times = 1:max_days,
  n = 3,
  min.space = min.space,
  t1.prior.to = max_days
)

all.times2 <- test.designs(
  times = 1:max_days,
  n = 2,
  min.space = min.space,
  t1.prior.to = max_days
)

all.times1 <- test.designs(
  times = 1:max_days,
  n = 1,
  min.space = min.space,
  t1.prior.to = max_days
)

# Combine all schedules
all.times <- all.times3 %>%
  filter(Var1 <= 5) %>%
  add_row(
    all.times2 %>%
      mutate(Var3 = Inf) %>%
      filter(Var1 <= 5)
  ) %>%
  add_row(
    all.times1 %>%
      mutate(Var2 = Inf, Var3 = Inf)
  )

nn <- nrow(all.times)
print(paste("Evaluating", nn, "testing schedules"))
```

## Run Simulations for Each Scenario

Now we loop over isolation durations and TTIQ scenarios, evaluating all
testing schedules in parallel:

``` r
results_list <- list()

for (hq.d in quarantine.durations) {
  for (ts in the.scenarios) {

    cat(paste("\nEvaluating", ts, "scenario with", hq.d, "day isolation\n"))

    # For 7-day isolation, filter out schedules that extend beyond day 7
    if (hq.d == 7 && ncol(all.times) == 3) {
      all.times_filtered <- all.times %>%
        select(-Var3) %>%
        distinct() %>%
        filter(Var1 <= hq.d & (Var2 <= hq.d | is.infinite(Var2)))
      nn <- nrow(all.times_filtered)
    } else {
      all.times_filtered <- all.times
    }

    # Step 1: Run base simulation (once per scenario/duration combination)
    set.seed(1)  # For reproducibility
    CQ.output <- CQ.sim2(
      n.ind = n.ind,
      TP = TP,
      k = k,
      p.vac.idx = p.vac.idx,
      p.vac.sc = p.vac.sc,
      vacc.cor = vacc.cor,
      VE.trans = VE.trans,
      VE.inf = VE.inf,
      quarantine.duration = hq.d,
      the.scenario = ts,
      region = region,
      inc_meanlog = inc_meanlog,
      inc_sdlog = inc_sdlog,
      gi_meanlog = gi_meanlog,
      gi_sdlog = gi_sdlog
    )

    # Step 2: Evaluate all testing schedules in parallel
    cl <- makeCluster(4)  # Use 4 cores (adjust based on your machine)
    registerDoParallel(cl)

    tic <- Sys.time()

    output <- foreach(
      i = 1:nn,
      .combine = rbind,
      .packages = c("tidyverse", "isolatr")
    ) %dopar% {
      CQ.sim.test.times(
        CQ.sim.output = CQ.output,
        n.ind = n.ind,
        test.times = all.times_filtered[i, ] %>% as.numeric(),
        TP = TP,
        VE.trans = VE.trans,
        the.scenario = ts,
        gi_meanlog = gi_meanlog,
        gi_sdlog = gi_sdlog
      )
    }

    toc <- Sys.time() - tic
    cat(paste("Completed in", round(toc, 2), attr(toc, "units"), "\n"))

    stopCluster(cl)

    # Combine schedules with results
    results <- cbind(all.times_filtered, output) %>%
      mutate(
        scenario = ts,
        q.duration = hq.d
      )

    results_list[[paste(ts, hq.d, sep = "_")]] <- results
  }
}

# Combine all results
all_results <- bind_rows(results_list)
```

## Process and Analyze Results

``` r
# Clean up column names
colnames_base <- c("t1", "t2", "t3")
if (ncol(all.times) <= 3) {
  colnames(all_results)[1:3] <- colnames_base[1:3]
}

# Add number of tests
all_results <- all_results %>%
  mutate(
    t2 = case_when(
      is.na(t2) ~ Inf,
      TRUE ~ t2
    ),
    t3 = case_when(
      is.na(t3) ~ Inf,
      TRUE ~ t3
    )
  ) %>%
  mutate(n.tests = 3 - is.infinite(t2) - is.infinite(t3))

# Identify optimal schedules
optimal_schedules <- all_results %>%
  group_by(scenario, q.duration, n.tests) %>%
  filter(IPq == min(IPq)) %>%
  mutate(TT = paste0("(", t1, ",", t2, ",", t3, ")")) %>%
  mutate(TT = gsub(pattern = ",Inf", replacement = "", x = TT)) %>%
  select(scenario, q.duration, n.tests, TT, IPq, sdIPq, mean.cases)

print(optimal_schedules)
```

## Visualizations

### 1. Optimal Strategies Bar Plot

``` r
optimal_schedules %>%
  mutate(
    scenario = factor(
      scenario,
      levels = c("optimal", "baseline", "partial"),
      labels = c("Optimal delays", "Baseline delays", "Partial delays"),
      ordered = TRUE
    )
  ) %>%
  mutate(
    q.duration = factor(
      q.duration,
      levels = c("14", "7"),
      labels = c("14-days", "7-days"),
      ordered = TRUE
    )
  ) %>%
  ggplot() +
  aes(x = TT, y = IPq, fill = as.factor(n.tests)) +
  geom_col(position = position_dodge(preserve = "single")) +
  scale_x_discrete("Test Strategy") +
  scale_y_continuous("IPq (Infection Potential in Isolation)") +
  scale_fill_discrete("Number of Tests") +
  facet_grid(q.duration ~ scenario, scales = "free_x") +
  theme_minimal() +
  theme(
    text = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )
```

### 2. Scatter Plot: Test Timing vs IPq

For each number of tests, visualize how test timing affects IPq:

``` r
# Identify optimal schedules for highlighting
the.opt <- all_results %>%
  mutate(id = row_number()) %>%
  mutate(
    q.duration = factor(
      q.duration,
      levels = c("7", "14"),
      labels = c("7-day", "14-day"),
      ordered = TRUE
    )
  ) %>%
  group_by(q.duration, scenario, n.tests) %>%
  filter(IPq == min(IPq)) %>%
  pivot_longer(cols = t1:t3) %>%
  filter(is.finite(value))

# Plot for 3-test schedules
plot.the.scenario <- "optimal"

all_results %>%
  filter(scenario == plot.the.scenario, n.tests == 3) %>%
  mutate(id = row_number()) %>%
  mutate(
    q.duration = factor(
      q.duration,
      levels = c("7", "14"),
      labels = c("7-day", "14-day"),
      ordered = TRUE
    )
  ) %>%
  pivot_longer(cols = t1:t3) %>%
  ggplot() +
  aes(x = value, y = IPq, group = id) +
  geom_line(alpha = 0.1) +
  geom_point(aes(colour = name), alpha = 0.6) +
  geom_point(
    data = the.opt %>% filter(scenario == plot.the.scenario, n.tests == 3),
    aes(x = value, y = IPq, group = id),
    size = 3,
    colour = "black"
  ) +
  geom_line(
    data = the.opt %>% filter(scenario == plot.the.scenario, n.tests == 3),
    aes(x = value, y = IPq, group = id),
    size = 1,
    colour = "black"
  ) +
  scale_y_continuous("IPq") +
  scale_x_continuous("Test day", breaks = seq(1, 14, by = 1)) +
  facet_grid(q.duration ~ .) +
  scale_colour_manual(
    "Test Number",
    values = c("darkviolet", "green4", "darkorange"),
    labels = c("1", "2", "3")
  ) +
  theme_minimal() +
  theme(legend.position = "top")
```

### 3. Efficiency Analysis

Identify schedules that perform within 2% of optimal:

``` r
near_optimal <- all_results %>%
  group_by(scenario, q.duration, n.tests) %>%
  arrange(IPq) %>%
  mutate(efficiency = IPq / min(IPq)) %>%
  filter(efficiency <= 1.02) %>%
  mutate(
    T1 = paste0(min(t1), "-", max(t1)),
    T2 = paste0(min(t2), "-", max(t2)),
    T3 = paste0(min(t3), "-", max(t3))
  ) %>%
  mutate(
    T2 = gsub("Inf-Inf", "-", T2),
    T3 = gsub("Inf-Inf", "-", T3)
  ) %>%
  select(scenario, q.duration, n.tests, T1, T2, T3, efficiency) %>%
  distinct() %>%
  arrange(desc(q.duration), desc(n.tests))

print(near_optimal)
```

This shows the range of test timings that achieve near-optimal
performance, providing flexibility for implementation.

## Key Insights

From this systematic evaluation, we can derive several insights:

1.  **Optimal test timing varies by scenario**: Faster TTIQ systems
    allow later first tests
2.  **Test spacing matters**: Tests should be strategically spaced to
    capture infections at different stages
3.  **Diminishing returns**: Adding a 3rd test provides smaller marginal
    benefit than adding a 2nd
4.  **Robustness**: Multiple schedules often perform nearly as well as
    the single optimum
5.  **Disease-specific**: Optimal timing depends on incubation period
    and generation interval

## Comparing Different Isolation Policies

You can extend this framework to compare alternative policies, such as
differential isolation by vaccination status:

``` r
# Example: 7-day isolation for vaccinated, 14-day for unvaccinated
# This requires running separate simulations for each group
# See inst/examples/ for full implementation
```

## Exporting Results

``` r
# Save optimal schedules
write.csv(
  optimal_schedules,
  "optimal_testing_schedules.csv",
  row.names = FALSE
)

# Save near-optimal ranges
write.csv(
  near_optimal,
  "near_optimal_testing_ranges.csv",
  row.names = FALSE
)
```

## Computational Considerations

For large-scale evaluations:

- **Parallelization** reduces runtime dramatically (4 cores ≈ 4x
  speedup)
- **Sample size** (n.ind): 100,000 provides stable estimates; 10,000
  faster for exploration
- **Number of schedules**: Grows combinatorially with max days and tests
- **Memory**: Each simulation stores detailed secondary infection data

Typical runtime: ~30-60 minutes for complete analysis (all scenarios x
durations) with 4 cores.

## Adapting for Other Diseases

The key considerations when adapting this analysis for other diseases:

1.  **Adjust epidemiological parameters**: incubation period, generation
    interval
2.  **Modify isolation durations**: shorter for diseases with faster
    dynamics
3.  **Update test sensitivity**: different tests have different
    performance curves
4.  **Consider transmission patterns**: diseases with less household
    transmission may need different strategies

### Example: Influenza Analysis

``` r
# Run the same workflow with influenza parameters
# Key changes:
# - Shorter isolation periods (5-7 days)
# - Earlier optimal test times (due to shorter generation interval)
# - Consider rapid antigen test performance
```

## Next Steps

- See [`vignette("model-details")`](../articles/model-details.md) for
  understanding how IPq is calculated
- See
  [`vignette("quick-start-guide")`](../articles/quick-start-guide.md)
  for basic usage
- Adapt this workflow for your own epidemic parameters and constraints

## References

This workflow can be applied to:

- Pandemic preparedness planning
- Real-time policy evaluation during outbreaks
- Comparing testing strategies across different diseases
- Optimizing resource allocation for testing programs

For parallel computing in R: \>
[`?foreach`](https://rdrr.io/pkg/foreach/man/foreach.html),
`?doParallel`
