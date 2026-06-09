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

## Examples

``` r
# create schema
schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    age = list(type = "double", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

# create dataframe
df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

# create validator object
validator <- new_validator(
  data = df,
  schema = schema
)
```
