# Check Decimal Places in Numeric Columns

This function calculates the number of decimal places in a numeric
vector.

## Usage

``` r
decimal_places(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A vector of the same length as `x`, indicating the number of decimal
places for each element. If an element is `NA`, it returns `NA`.
