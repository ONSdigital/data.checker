# Validator Constructor

Creates a `Validator` object to validate data against a given schema.

## Usage

``` r
new_validator(data, schema, backseries = NULL)
```

## Arguments

- data:

  A data frame to validate against the schema.

- schema:

  A schema object that defines the validation rules.

- backseries:

  A previous version of the data to check against (optional).

## Value

An object of class `Validator`.
