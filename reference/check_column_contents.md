# Check Column Contents against schema and checks

This function performs checks on the columns of `Validator$data` to
ensure they meet the specified schema conditions and checks.

## Usage

``` r
check_column_contents(validator)
```

## Arguments

- validator:

  A `Validator` object containing the column names to be checked.

## Value

The updated `Validator` object with QA entries for each check.
