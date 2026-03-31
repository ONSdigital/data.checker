# Validate date formats in the schema This function checks that any date formats specified in the schema are valid and can be parsed correctly.

Validate date formats in the schema This function checks that any date
formats specified in the schema are valid and can be parsed correctly.

## Usage

``` r
validate_and_convert_date_formats(schema)
```

## Arguments

- schema:

  A list containing a `columns` element, where each column may have
  `min_date` and `max_date` fields.

## Value

The original schema if all date formats are valid. If any date format is
invalid, an error is thrown with a message indicating the issue.
