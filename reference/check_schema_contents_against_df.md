# Check schema contents against the data frame provided

This function checks that the contents of the schema are consistent with
the data frame provided. It checks for unused schema entries,
incompatible schema entries, and that any columns specified in the
schema are present in the data frame.

## Usage

``` r
check_schema_contents_against_df(validator)
```

## Arguments

- validator:

  A `Validator` object containing the data and schema to check against.

## Value

The updated `Validator` object with QA entries added for any issues
found in the schema.
