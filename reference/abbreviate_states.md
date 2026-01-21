# Abbreviate Australian state and territory names

Converts full Australian state and territory names to their standard
abbreviations. The function accepts both full names and abbreviations as
input and returns abbreviations. This is useful for standardizing state
names in datasets.

## Usage

``` r
abbreviate_states(state_names)
```

## Arguments

- state_names:

  A character vector of Australian state or territory names. Can be
  either full names (e.g., "New South Wales") or abbreviations (e.g.,
  "NSW").

## Value

A character vector of abbreviated state/territory names. Returns NA for
unrecognized state names.

## Details

Recognized states and territories:

- Australian Capital Territory (ACT)

- New South Wales (NSW)

- Northern Territory (NT)

- Queensland (QLD)

- South Australia (SA)

- Tasmania (TAS)

- Victoria (VIC)

- Western Australia (WA)

## See also

Other state helper functions:
[`unabbreviate_states()`](unabbreviate_states.md)

## Examples

``` r
abbreviate_states("New South Wales")
#> [1] "NSW"
# Returns: "NSW"

abbreviate_states(c("Victoria", "Queensland", "NSW"))
#> [1] "VIC" "QLD" "NSW"
# Returns: c("VIC", "QLD", "NSW")
```
