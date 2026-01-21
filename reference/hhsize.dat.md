# Household Size Distribution by Australian State

Synthetic data representing the proportion of households of each size
(1-8+ persons) for each Australian state and territory. Based on the
structure of Australian census data but containing synthetic values.

## Usage

``` r
hhsize.dat
```

## Format

A data frame with 8 rows and 11 columns:

- number:

  Household size (1 to 8, where 8 represents 8+ persons)

- New South Wales:

  Proportion of households of this size in NSW

- Victoria:

  Proportion of households of this size in Victoria

- Queensland:

  Proportion of households of this size in Queensland

- South Australia:

  Proportion of households of this size in SA

- Western Australia:

  Proportion of households of this size in WA

- Tasmania:

  Proportion of households of this size in Tasmania

- Northern Territory:

  Proportion of households of this size in NT

- Australian Capital Territory:

  Proportion of households of this size in ACT

- Other Territories:

  Proportion of households for other territories

- Total:

  Overall proportion across all of Australia

## Source

Synthetic data generated to match the structure of Australian census
data

## Details

This synthetic dataset is used by internal functions to sample realistic
household sizes when simulating quarantine scenarios.

The proportions are probability mass functions (sum to 1.0 for each
state). To use for sampling, these are converted to cumulative
distributions.

## Examples

``` r
# View household size distribution for NSW
hhsize.dat[, c("number", "New South Wales")]
#>   number New South Wales
#> 1      1      0.13176263
#> 2      2      0.30590990
#> 3      3      0.17772577
#> 4      4      0.27326626
#> 5      5      0.12353586
#> 6      6      0.05509197
#> 7      7      0.02867812
#> 8      8     -0.09597051

# Calculate mean household size for Victoria
weighted.mean(hhsize.dat$number, hhsize.dat$Victoria)
#> [1] 3.110345
```
