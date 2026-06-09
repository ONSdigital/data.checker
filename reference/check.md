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

## Examples

``` r
# create schema
schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    age = list(type = "double", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

# create dataframe
df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

# create validator object
validator <- new_validator(
  data = df,
  schema = schema
)
# validate the data
validator <- check(validator)
```
