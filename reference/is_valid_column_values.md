# Check that max values are not less than min values in column schema

This function checks that for any column schema, the max values (e.g.,
max_string_length, max_date) are not less than the corresponding min
values (e.g., min_string_length, min_date). If any such inconsistency is
found, an error is raised with a descriptive message.

## Usage

``` r
is_valid_column_values(column_schema, col_name)
```

## Arguments

- column_schema:

  A list representing the schema for a specific column, which may
  contain max and min value specifications.

- col_name:

  The name of the column being checked, used for error messages.

## Value

`TRUE` if all max values are greater than or equal to their
corresponding min values, otherwise an error is raised.
