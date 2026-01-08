# Add a custom check to the validator

This function allows you to add a custom check to the `Validator`object.

## Usage

``` r
add_check(
  validator,
  description,
  outcome,
  condition,
  type = c("error", "warning", "info"),
  rowwise = TRUE
)
```

## Arguments

- validator:

  A `Validator` object to which the custom check will be added.

- description:

  A description of the custom check.

- outcome:

  Logical vector - one value per row if rowwise, or a single value if
  not. Optional if condition is set.

- condition:

  Expression to be evaluated or logical conditions to define the custom
  check. Optional if outcome is set

- type:

  The type of the check, which can be one of "error", "warning", or
  "info".

- rowwise:

  Logical indicating whether the check should be applied row-wise, i.e.
  return a result per row. Defaults to `TRUE`. If false, the check will
  return a single logical value.

## Value

The updated `Validator` object with the custom check added.
