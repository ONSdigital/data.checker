# data.checker

`data.checker` is a package for helping with boilerplate data checks. It
enables you to automate fundamental data checks which, while simple, can
be time-consuming to implement.

`data.checker`

- Checks data against a user supplied schema that defines what columns
  and data types are expected

- Enables user to add additional custom data checks based on multiple
  columns

- Creates exports of the results for QA

# Getting Started

## Installation

### Software requirements

To use this package, you’ll need the following software on your
computer:

1.  RStudio 2024.04.2 or later and R 4.5.0 or later
2.  GIT 2.35.3 or later

To install this R package, you will first need to clone the repository
to you local machine by running

    git clone https://github.com/ONSdigital/data.checker.git

Open the project in RStudio and in the console run:

    devtools::install()

The package will be installed in you R library.

## Setup and Usage

`data.checker` requires an input dataframe and a data schema to validate
against. A full list of checks performed by the data checker, alongside
how to include custom checks can be found [here](#custom_checks). The
schema can either be defined within the R script itself or saved to
either a JSON or YAML file to be loaded by the data checker. We
recommend that schemas be saved as either a JSON or YAML to simplify the
process of adding additional checks and column information. Once
defined, we can pass both the dataframe and schema, alongside an output
filepath and format for the report and the option for hardchecks into
the `check_and_export` function.

``` r
libary(data.checker)

df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

my_schema <- list(
  check_duplicates = TRUE,
  check_completeness = FALSE,
  columns = list(
    age = list(type = "integer", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

check_and_export(data = df,
         schema = my_schema, 
         file = "report.csv", 
         format = "csv", 
         hard_check =TRUE)
```

This will produce a `report.csv` containing the status of each of the
validation checks. With hard_check set to `TRUE`, this will mean the
code stops running if any validation checks fail. The report will still
be produced before this stop so you can view and investigate the issue
causing a fail.

# Pre-Defined and Adding Custom Checks

## Pre-Defined Checks

These checks can be included in the lists for individual columns in your
schema, depending on the data type.

| Data Type        | Check Name             | Parameter         | Check Definition                                                                                                                           |
|------------------|------------------------|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| integer / double | Minimum value          | min_val           | Checks that all values are above or equal to the minimum value                                                                             |
| integer / double | Maximum value          | max_val           | Checks that all values are below or equal to the maximum value                                                                             |
| double           | Minimum decimal places | min_decimal       | Checks that all values have more or equal amounts of decimal places                                                                        |
| double           | Maximum decimal places | max_decimal       | Checks that all values have less or equal amounts of decimal places                                                                        |
| character        | Minimum length         | min_length        | Checks that all strings have length are above or equal to the minimum length                                                               |
| character        | Maximum length         | max_length        | Checks that all strings have length below or equal to the maximum length                                                                   |
| character        | allowed strings        | allowed_strings   | Validates that entries match a set of permitted values, list or regex can be used. (Optional and can use forbidden strings instead)        |
| character        | forbidden strings      | forbidden_strings | Validates that entries do not contain a set of forbidden values, list or regex can be used. (Optional and can use allowed strings instead) |
| date / datetime  | Minimum Date           | min_date          | Checks that all dates are after the minimum date using the format “YYYY-MM-DD”                                                             |
| date / datetime  | Maximum Date           | max_date          | Checks that all dates are before the maximum date using the format “YYYY-MM-DD”                                                            |
| date/ datetime   | Minimum Datetime       | min_datetime      | Checks that all dates are after the minimum datetime. Accepted formats: Y, YM, YMD, YMDH, YMDHM and YMDHMS                                 |
| date/ datetime   | Maximum Datetime       | max_datetime      | Checks that all dates are before the maximum datetime. Accepted formats: Y, YM, YMD, YMDH, YMDHM and YMDHMS                                |
| any              | Missing values check   | allow_na          | Checks for missing or NA values in the column.                                                                                             |
| any              | Class                  | class             | Checks that column data Class matches the specified type                                                                                   |

## Adding Custom Checks

Additionally, you can write your own checks and add them to the
validator object using the `add_custom_check` function. This is
particularly useful for checks involving more than one column, which
cannot be configured using the standard template. The checks are done in
the context of the original data, meaning you can reference columns as
if they are variables in the environment (similar to tidy evaluation).
This is recommended because it guarantees the checks are done on the
correct data only. Alternatively, you can use standard evaluation (see
example below).

The example below demonstrates how to incorporate both pre-defined and
custom checks into your validation.

``` r
df <- data.frame(
  id = 1:10,
  age = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100),
  sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F")
)

schema <- list(
  check_duplicates = TRUE,
  check_completeness = FALSE,
  columns = list(
    id = list(type = "double", optional = FALSE),
    age = list(type = "double", optional = FALSE, min_val = 0),
    sex = list(type = "character", optional = FALSE, allowed_strings = c("M", "F"))
  )
)

data_check_results <- data.checker::new_validator(df, schema) |>
  data.checker::check() |>
  data.checker::add_check(description = "There are no males over 90 (tidy evaluation)", condition = !(sex == "M" & age > 90)) |>
  data.checker::add_check(description = "There are no males over 90 (standard evaluation)", condition = !(df$sex == "M" & df$age > 90))

print(data_check_results)
```

# Contributing

We always welcome contributions and suggestions to improve functionality
of our products. Feel free to open an issue using the [issue
tab](https://gitlab-app-l-01/ASAP/data.checker/-/issues). If you wish to
make a direct contribution, please fork the repository, make your
changes and raise a pull request and we can review and merge your
changes.
