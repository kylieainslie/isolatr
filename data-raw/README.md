# Synthetic Data Generation

This directory contains scripts for generating synthetic datasets used in the isolatr package.

## Important Note

**All datasets in this package are synthetic.** They are designed to match the structure and statistical characteristics of real epidemiological data, but contain no actual observational data.

This approach allows the package to:
- Function correctly for demonstration and testing
- Be shared publicly without data privacy concerns
- Provide realistic examples for users

## Generating the Data

To regenerate the synthetic datasets:

```r
source("data-raw/create_synthetic_data.R")
```

This will create 11 data objects and save them to the `data/` directory:

1. **hhsize.dat** - Household size distributions by Australian state
2. **distn.dat** - Detection time distributions for TTIQ scenarios
3. **optimal.tat.dat** - Test turnaround times (optimal)
4. **partial.tat.dat** - Test turnaround times (partial)
5. **nsw.ci.tat.dat** - Test turnaround times (NSW case-initiated)
6. **optimal.interview.dat** - Interview delay CDF (optimal)
7. **partial.interview.dat** - Interview delay CDF (partial)
8. **nsw.ci.interview.dat** - Interview delay CDF (NSW)
9. **optimal.cc.notify.dat** - Contact notification delay CDF (optimal)
10. **partial.cc.notify.dat** - Contact notification delay CDF (partial)
11. **nsw.ci.cc.notify.dat** - Contact notification delay CDF (NSW)

## Data Characteristics

### Household Sizes
- Realistic proportions for 1-8+ person households
- State-specific variation
- Based on typical Australian demographic patterns

### TTIQ Scenarios
- **Optimal**: Fast detection and tracing
- **Partial**: Moderate delays
- **Current NSW case-initiated**: Baseline performance

### Distributions Used
- Detection times: Lognormal distributions
- Turnaround times: Gamma distributions
- Delays: Exponential CDFs for inverse transform sampling

## Using Real Data

If you have access to real TTIQ data and permission to use it:

1. Modify `create_synthetic_data.R` to load your data
2. Ensure data format matches the structure documented in `R/data.R`
3. Rerun the script to generate .rda files
4. Update documentation if structure differs

## Questions

For questions about the synthetic data generation process, please open an issue at:
https://github.com/kylieainslie/isolatr/issues
