# Validate a Validator Object

This function runs the full suite of validation checks on a `Validator`
object.

## Usage

``` r
check(validator, ...)
```

## Arguments

- validator:

  An object of class `Validator` to be validated.

- ...:

  Additional arguments (currently unused).

## Value

The validated `Validator` object if all checks pass. If any check fails,
an error is thrown.
