# Check Column Names against schema

This function performs checks on the column names of a `Validator`
object to ensure they follow specific naming conventions and meet schema
conditions.

## Usage

``` r
check_colnames(validator)
```

## Arguments

- validator:

  A `Validator` object containing the column names to be checked.

## Value

The updated `Validator` object with QA entries for each check.

## Details

The function performs the following checks on the column names:

- Ensures column names do not contain spaces.

- Ensures column names do not contain symbols other than underscores.

- Ensures column names do not contain uppercase letters.

For each check, a QA entry is added to the `Validator` object with
details about the check, whether it passed, and the IDs of failing
columns (if any). \# nolint: line_length_linter.
