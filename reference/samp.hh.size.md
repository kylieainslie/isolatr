# Sample Household Sizes

Draws n household sizes from a specified distribution using inverse
transform sampling.

## Usage

``` r
samp.hh.size(n, region = NULL, hh_probs = NULL)
```

## Arguments

- n:

  Integer. Number of samples to draw.

- region:

  Character. Region name for built-in household size distribution. For
  Australian states, see [`abbreviate_states`](abbreviate_states.md) for
  valid values. Ignored if `hh_probs` is provided.

- hh_probs:

  Numeric vector. Custom household size probabilities for sizes 1-8+.
  Must sum to 1 and have length 8. If provided, `region` is ignored.

## Value

Integer vector of length n containing household sizes (1-8).

## Details

If `hh_probs` is provided, it should be a vector of 8 probabilities
corresponding to household sizes 1, 2, 3, 4, 5, 6, 7, and 8+ persons.

## Examples

``` r
# Using built-in Australian data
samp.hh.size(100, region = "NSW")
#>   [1] 4 3 1 4 1 1 4 3 4 4 3 4 1 5 2 2 4 2 1 2 4 4 4 2 4 3 3 1 2 1 5 1 2 2 3 2 1
#>  [38] 3 2 5 1 2 4 4 4 1 3 4 4 1 4 4 4 4 1 2 2 2 4 3 3 4 2 2 2 4 2 2 2 2 4 2 5 3
#>  [75] 2 4 5 1 3 1 4 1 2 2 2 4 2 4 3 2 3 4 5 2 2 4 1 3 2 3

# Using custom UK-like distribution
uk_probs <- c(0.28, 0.35, 0.18, 0.12, 0.05, 0.015, 0.004, 0.001)
samp.hh.size(100, hh_probs = uk_probs)
#>   [1] 5 1 4 1 3 3 3 1 4 2 2 3 1 2 2 2 2 3 5 1 3 1 1 3 1 3 1 1 5 4 2 3 1 3 1 2 1
#>  [38] 1 1 2 1 2 3 3 1 6 2 1 1 3 2 2 3 1 4 2 2 3 2 1 2 4 3 2 1 1 3 1 1 1 2 1 2 2
#>  [75] 3 4 2 6 5 6 2 1 5 2 2 1 1 1 2 1 1 3 3 2 3 1 1 1 4 1
```
