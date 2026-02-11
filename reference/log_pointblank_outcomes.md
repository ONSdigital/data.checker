# Log pointblank validation outcomes to a validator log

This function extracts validation results from a pointblank agent and
appends them to the validator's log.

## Usage

``` r
log_pointblank_outcomes(validator)
```

## Arguments

- validator:

  A list containing a pointblank agent and a log. The agent should have
  a validation_set from a pointblank interrogation.

## Value

The updated validator list with new log entries appended.

## Details

Each entry in the log will contain the timestamp, description, outcome,
failing row indices, number of failures, and entry type for each
validation step.
