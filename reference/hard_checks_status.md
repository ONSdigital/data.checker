# Check the status of errors and warnings in the validator log

This function raises errors or warnings if any checks flagged as error
or warnings fail.

## Usage

``` r
hard_checks_status(validator, hard_check)
```

## Arguments

- validator:

  A `Validator` object to check the log.

- hard_check:

  A logical value indicating whether to perform hard checks (default is
  TRUE).

  Warning if there are any warnings or errors in the log when
  `hard_check` is FALSE. Error if there are any errors and `hard_check`
  is TRUE.
