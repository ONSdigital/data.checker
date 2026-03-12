# Flag outliers based on Interquartile Range (IQR). Outliers are flagged if they are below Q1 - (mulitplier \* IQR) or above Q3 + (multiplier \* IQR).

Flag outliers based on Interquartile Range (IQR). Outliers are flagged
if they are below Q1 - (mulitplier \* IQR) or above Q3 + (multiplier \*
IQR).

## Usage

``` r
iqr_bounds(x, multiplier = 1.5)
```

## Arguments

- x:

  A numeric vector.

- multiplier:

  A numeric value to multiply the IQR by (default is 1.5).

## Value

A vector the same size as `x`, with `TRUE` for values that are outliers
and `FALSE` otherwise
