# Convert complex types to the correct types and classes

This function modifies a schema by converting column types to their
corresponding R classes.

## Usage

``` r
types_to_classes(schema)
```

## Arguments

- schema:

  A list containing a `columns` element, where each column is a list
  with a `type` field.

## Value

The modified schema with updated `type` and `class` fields for each
column.
