# Export Validator Log

This function exports the log of a `Validator` object to a file in the
specified format.

## Usage

``` r
# S3 method for class 'Validator'
export(validator, file, format = c("yaml", "json", "html", "csv"))
```

## Arguments

- validator:

  A `Validator` object containing the log to be exported.

- file:

  A string specifying the file path where the log will be exported. The
  file extension must match the specified format.

- format:

  A string specifying the format of the output file. Supported formats
  are `"yaml"`, `"json"`, `"html"`, and `"csv"`.

## Value

Writes the log to the specified file. No value is returned.
