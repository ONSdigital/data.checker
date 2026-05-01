# Validator Constructor

Creates a `Validator` object to validate data against a given schema.

## Usage

``` r
new_validator(
  data,
  schema,
  backseries = NULL,
  name = deparse(substitute(data))
)
```

## Arguments

- data:

  A data frame to validate against the schema.

- schema:

  A schema object that defines the validation rules. See the vignette
  for more details on schema structure. This can also be a file path to
  a JSON, YAML, or TOML file containing the schema.

- backseries:

  A previous version of the data to check against (optional).

- name:

  validator name - defaults to the name of the dataframe object supplied
  to "data" (optional). Must be a single character string.

## Value

An object of class `Validator`.
