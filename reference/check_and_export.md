# Validate data against a schema and output results

This function validates data against a given schema, performs checks,
and exports the validation results to a specified file in a given
format.

## Usage

``` r
check_and_export(data, schema, file, format, hard_check = FALSE)
```

## Arguments

- data:

  The data to be validated.

- schema:

  The schema to validate against.

- file:

  The file path where the validation results will be exported.

- format:

  The format in which the validation results will be exported.

- hard_check:

  logical. Optional - FALSE by default. If TRUE, raises an error if
  there are any failed checks. Otherwise, raises a warning.

## Value

The exported validation results.
