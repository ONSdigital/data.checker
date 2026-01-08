# Add a QA Entry to the validator's QA Log

This function adds a new entry to the validator's QA log with details
such as a description, type of entry, timestamp, pass status, and
failing IDs.

## Usage

``` r
add_qa_entry(
  validator,
  description,
  failing_ids,
  outcome = NA,
  entry_type = c("info", "warning", "error")
)
```

## Arguments

- validator:

  a `Validator` object.

- description:

  A character string describing the QA entry.

- failing_ids:

  Optional: A vector of IDs that failed the QA check. If more than 10
  IDs are provided, only the first 10 are stored, with a note indicating
  the additional count.

- outcome:

  Optional: A logical value indicating whether the QA check passed. If
  not provided or invalid, defaults to `NA`.

- entry_type:

  Optional: A character string specifying the type of entry. Must be one
  of "info", "warning", or "error". Defaults to "info".

## Value

The updated validator object with the new entry appended to its QA log.
