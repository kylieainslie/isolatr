# Expand abbreviated state names to full names

Converts Australian state and territory abbreviations to their full
names. The function accepts both abbreviations and full names as input
and returns full names. This is useful for creating readable output and
reports.

## Usage

``` r
unabbreviate_states(state_names)
```

## Arguments

- state_names:

  A character vector of Australian state or territory names. Can be
  either abbreviations (e.g., "NSW") or full names (e.g., "New South
  Wales").

## Value

A character vector of full state/territory names. Returns NA for
unrecognized state names.

## Details

Recognized states and territories:

- ACT (Australian Capital Territory)

- NSW (New South Wales)

- NT (Northern Territory)

- QLD (Queensland)

- SA (South Australia)

- TAS (Tasmania)

- VIC (Victoria)

- WA (Western Australia)

## See also

Other state helper functions:
[`abbreviate_states()`](abbreviate_states.md)

## Examples

``` r
unabbreviate_states("NSW")
#> [1] "New South Wales"
# Returns: "New South Wales"

unabbreviate_states(c("VIC", "QLD", "Australian Capital Territory"))
#> [1] "Victoria"                     "Queensland"                  
#> [3] "Australian Capital Territory"
# Returns: c("Victoria", "Queensland", "Australian Capital Territory")
```
