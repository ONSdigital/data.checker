# Check Column Types and Classes

This function checks the types and classes of the columns in the data
against the schema defined in the `Validator` object.

## Usage

``` r
check_types(validator)
```

## Arguments

- validator:

  A `Validator` object containing the data and schema to check against.
  The schema should define the expected `type` and optionally the
  `class` for each column.

## Value

The updated `Validator` object with quality assurance (QA) entries added
for type and class checks. Each QA entry includes a description,
pass/fail status, and any failing column IDs.
