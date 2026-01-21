# Test Turnaround Times - NSW Case-Initiated Scenario

Synthetic data representing test turnaround times under NSW baseline
conditions.

## Usage

``` r
nsw.ci.tat.dat
```

## Format

A numeric vector of length 100,000 containing turnaround times in days.

## Source

Synthetic data generated from gamma distribution

## Details

Represents NSW case-initiated testing performance with median around
1.5-2 days. Used by internal sampling functions when scenario is
"current_nsw_case_init".

## Examples

``` r
summary(nsw.ci.tat.dat)
#>     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#>  0.00666  0.89479  1.45199  1.66708  2.21131 12.72067 
```
