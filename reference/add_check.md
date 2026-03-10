# Add a custom check to the validator

This function allows you to add a custom check to the `Validator`object.

## Usage

``` r
add_check(validator, description, condition)
```

## Arguments

- validator:

  A `Validator` object to which the custom check will be added.

- description:

  A description of the custom check.

- condition:

  Expression to be evaluated or logical conditions to define the custom
  check. Optional if outcome is set

## Value

The updated `Validator` object with the custom check added.
