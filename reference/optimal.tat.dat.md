# Test Turnaround Times - Optimal Scenario

Synthetic data representing test turnaround times (from sample
collection to result notification) under optimal TTIQ conditions.

## Usage

``` r
optimal.tat.dat
```

## Format

A numeric vector of length 100,000 containing turnaround times in days.

## Source

Synthetic data generated from gamma distribution

## Details

Represents fast testing with most results returned within 1 day. Used by
internal sampling functions when scenario is "optimal".

## Examples

``` r
# Summary statistics
summary(optimal.tat.dat)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#> 0.00171 0.32044 0.55967 0.66682 0.89871 4.84410 
median(optimal.tat.dat)
#> [1] 0.559668
```
