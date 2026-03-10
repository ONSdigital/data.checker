# Add a custom check to the validator

This function allows you to add a custom check outcomes to the validator
log. The outcomes must be a logical vector.

## Usage

``` r
add_check_custom(
  validator,
  description,
  outcome,
  type = c("error", "warning", "note")
)
```

## Arguments

- validator:

  A `Validator` object to which the custom check will be added.

- description:

  A description of the custom check.

- outcome:

  Logical vector indicating the result of the check (TRUE/FALSE).
  Outcome must be logical.

- type:

  The type of the check, can be "error", "warning", or "note".

## Value

The updated `Validator` object with the custom check added.
