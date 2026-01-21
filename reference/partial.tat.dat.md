# Test Turnaround Times - Partial Scenario

Synthetic data representing test turnaround times under moderate delay
conditions.

## Usage

``` r
partial.tat.dat
```

## Format

A numeric vector of length 100,000 containing turnaround times in days.

## Source

Synthetic data generated from gamma distribution

## Details

Represents moderate testing delays with median around 2 days. Used by
internal sampling functions when scenario is "partial".

## Examples

``` r
summary(partial.tat.dat)
#>      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
#>  0.001551  0.958734  1.675577  1.999593  2.686503 16.002011 
```
