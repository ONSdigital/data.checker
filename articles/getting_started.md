# Data checker

`data.checker` is a package for helping with boilerplate data checks. It
enables you to automate fundamental data checks which, while simple, can
be time-consuming to implement.

`data.checker`

- Checks data against a user supplied schema that defines what columns
  and data types are expected

- Enables user to add additional custom data checks based on multiple
  columns

- Creates exports of the results for QA

## The basics

Initialising the data checker is simple. All you need to supply are a
dataset and a schema. The schema is a named list that tells the data
checker what sorts of columns and values to expect.

### Example dataset:

``` r
library(data.checker)

df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

df
#>   age sex
#> 1  10   M
#> 2  11   F
#> 3  13   M
#> 4  15   F
#> 5  22   M
#> 6  34   F
#> 7  80   M
```

### Example schema:

``` r
schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    age = list(type = "integer", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

schema
#> $check_duplicates
#> [1] FALSE
#> 
#> $check_completeness
#> [1] FALSE
#> 
#> $columns
#> $columns$age
#> $columns$age$type
#> [1] "integer"
#> 
#> $columns$age$optional
#> [1] FALSE
#> 
#> 
#> $columns$sex
#> $columns$sex$type
#> [1] "character"
#> 
#> $columns$sex$optional
#> [1] FALSE
```

### Initialising the data checker

Running the `new_validator` function will create a `Validator` object.

``` r
validator <- data.checker::new_validator(
  data = df,
  schema = schema
)
```

``` r
print(validator)
#>  System information                                                                                                                                                                                                     
#>  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>  Date: 2025-01-01
#> sysname: Windows
#> release: 10 x64
#> version: 
#> nodename: 
#> machine: 
#> login: username
#> user: username
#> effective_user: username
#> udomain: 
#> R version : R version 4.5.1 (2025-06-13 ucrt)
#> data.checker version: 0.0.0.9000  
#> 
#> 
```

The `Validator` object logs system information which can be exported
along with the QA log, meaning you have a comprehensive record of what
was done, when and on what systems. Printing the `Validator` object will
show you the current QA log.

### Running checks

The `check` function will run the full suite of checks on your
`Validator` object and add them to the log.

``` r
check_results <- data.checker::check(validator)

print(check_results)
#>  System information                                                                                                                                                                                                     
#>  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>  Date: 2025-01-01
#> sysname: Windows
#> release: 10 x64
#> version: 
#> nodename: 
#> machine: 
#> login: username
#> user: username
#> effective_user: username
#> udomain: 
#> R version : R version 4.5.1 (2025-06-13 ucrt)
#> data.checker version: 0.0.0.9000  
#> 
#>  Timestamp   Description                                                               Outcome   Failing Ids   n Failing   Entry Type 
#> ----------  ------------------------------------------------------------------------  --------  ------------  ----------  -----------
#> 16:59:45    Column names contain no symbols other than underscores.                   ✅ pass                 N/A         warning    
#> 16:59:45    Column names contain no upper case letters.                               ✅ pass                 N/A         warning    
#> 16:59:45    All mandatory columns are present.                                        ✅ pass                 N/A         error      
#> 16:59:45    There are no unexpected columns.                                          ✅ pass                 N/A         error      
#> 16:59:45    Removed schema information for optional columns that aren't in the data                           N/A         info       
#> 16:59:45    Correct column types                                                      ❌ fail   age           1           error      
#> 16:59:45    Correct column classes                                                    ✅ pass                 N/A         error
```

### Exporting your log

The `export` function will export your log in html, csv, yaml or json.
We strongly recommend exporting these automated QA logs along with your
outputs so you have a record of which automated checks were done and
what they found.

``` r
data.checker::export(check_results, file = "example.html", format = "html")
```

Alternatively, you can use the `validate` function to run the full
process.

``` r
data.checker::check_and_export(df, schema, file = "example.html", format = "html", hard_check = FALSE)
```

## Setting up the schema

The schema has certain mandatory and optional fields.

### Mandatory fields

`check_duplicates`: TRUE or FALSE. If TRUE, the dataset will be checked
for duplicate rows. `check_completeness`: TRUE or FALSE. If TRUE, the
dataset will be checked to ensure there is at least one row for all
combinations of factors. `columns`: a list of column names with an entry
for each column.

For each column, you should include a type (“character”, “integer”,
“double”, “logical”). You also need an “optional” setting (TRUE or
FALSE) if TRUE the checker will raise an error if the column is missing.
If FALSE the checker data will not raise an error if it’s missing.

You can also optionally define a class if you want it to be checked.
There are three special types you can choose - “Date”, “datetime” and
“factor”. In R, these are implemented as a specific combination of types
and classes, but the data checker simplifies this for you by setting up
those parts of the schema for you.

### Optional checks:

Optional checks can be applied to each column depending on the column
type. In the scheme, these should form part of the `columns` list.

- all types:
  - allow_na (TRUE/FALSE): checks if there are any missing values
  - class (character vector of any length): checks class of column
- integer/double checks:
  - min_val (numeric): minimum value
  - max_val (numeric): maximum value
  - min_decimal (double only, numeric): minimum number of decimal places
  - max_decimal (double only, numeric): maximum number of decimal places
- character checks:
  - min_length (numeric): minimum number of characters
  - max_length (numeric): maximum number of characters
  - allowed strings (character): either a list of allowed strings or a
    regular expression (see regular expression guide below)
  - forbidden_strings (character): either a list of forbidden strings or
    a regular expression
- Date checks:
  - min_date (character): minimum date using the format “YYYY-MM-DD”,
    e.g. “2025-08-19”
  - max_date (character): maximum date using the format “YYYY-MM-DD”,
    e.g. “2025-08-19”
- datetime checks:
  - min_datetime (character): minimum time using the format “YYYY-MM-DD
    HH-MM-SS”. Datetime is more flexible than Date, meaning the hour,
    minute and second parts are optional. It will accept the formats: Y,
    YM, YMD, YMDH, YMDHM and YMDHMS.
  - max_datetime (character): same format as min_datetime

### Loading from file

Schema objects can get pretty large and clutter your code. You should
also avoid needing to edit your code every time you want to change your
schema. Instead, you can create your schema as a yaml or json file
instead. You can then supply `new_validator` with the file path, and the
package will do the rest.

``` r
df <- data.frame(
  id = 1:10,
  age = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100),
  sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F"),
  country = factor(
    c("England", "England", "Wales", "Scotland", "Wales", "England", "Northern Ireland", "Wales", "Scotland", "Northern Ireland"),
    levels = c("England", "Scotland", "Wales", "Northern Ireland")),
  date = lubridate::ymd(c(
    "2021-01-01",
    "2021-02-01",
    "2021-02-01",
    "2021-03-01",
    "2021-03-01",
    "2021-03-01",
    "2021-04-01",
    "2021-04-01",
    "2021-04-01",
    "2021-05-01"
  ))
)

data_check_results <- data.checker::new_validator(schema = "example_schema.yaml", data = df) |> 
  data.checker::check()
```

``` r
print(data_check_results)
#>  System information                                                                                                                                                                                                     
#>  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>  Date: 2025-01-01
#> sysname: Windows
#> release: 10 x64
#> version: 
#> nodename: 
#> machine: 
#> login: username
#> user: username
#> effective_user: username
#> udomain: 
#> R version : R version 4.5.1 (2025-06-13 ucrt)
#> data.checker version: 0.0.0.9000  
#> 
#>  Timestamp   Description                                                               Outcome   Failing Ids   n Failing   Entry Type 
#> ----------  ------------------------------------------------------------------------  --------  ------------  ----------  -----------
#> 16:59:45    Column names contain no symbols other than underscores.                   ✅ pass                 N/A         warning    
#> 16:59:45    Column names contain no upper case letters.                               ✅ pass                 N/A         warning    
#> 16:59:45    All mandatory columns are present.                                        ✅ pass                 N/A         error      
#> 16:59:45    There are no unexpected columns.                                          ✅ pass                 N/A         error      
#> 16:59:45    Removed schema information for optional columns that aren't in the data                           N/A         info       
#> 16:59:45    Correct column types                                                      ✅ pass                 N/A         error      
#> 16:59:45    Correct column classes                                                    ✅ pass                 N/A         error      
#> 16:59:45    Column id contains no missing values                                      ✅ pass                 N/A         error      
#> 16:59:45    Column id: values are above or equal to 0                                 ✅ pass                 N/A         error      
#> 16:59:45    Column id: values are below or equal to 1000                              ✅ pass                 N/A         error      
#> 16:59:45    Column age contains no missing values                                     ✅ pass                 N/A         error      
#> 16:59:45    Column age: values are above or equal to 0                                ✅ pass                 N/A         error      
#> 16:59:45    Column age: values are below or equal to 120                              ✅ pass                 N/A         error      
#> 16:59:45    Column age: decimal places above or equal to 0                            ✅ pass                 N/A         error      
#> 16:59:45    Column age: decimal places below or equal to 2                            ✅ pass                 N/A         error      
#> 16:59:45    Column sex contains no missing values                                     ✅ pass                 N/A         error      
#> 16:59:45    Column sex only contains allowed strings                                  ✅ pass                 N/A         error      
#> 16:59:45    Column country contains no missing values                                 ✅ pass                 N/A         error      
#> 16:59:45    Column date contains no missing values                                    ✅ pass                 N/A         error      
#> 16:59:45    Column date: dates are after 2020-01-01                                   ✅ pass                 N/A         error      
#> 16:59:45    Column date: dates are before 2023-12-31                                  ✅ pass                 N/A         error
```

### Custom checks

You can write your own checks using the `add_custom_check` function.
This is particularly useful for checks involving more than one column,
which cannot be configured using the standard template. The checks are
done in the context of the original data, meaning you can reference
columns as if they are variables in the environment (similar to tidy
evaluation). This is recommended because it guarantees the checks are
done on the correct data only. Alternatively, you can use standard
evaluation (see example below).

``` r
df <- data.frame(
  id = 1:10,
  age = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100),
  sex = c("M", "F", "M", "F", "M", "F", "M", "F", "M", "F")
)

schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    id = list(type = "double", optional = FALSE),
    age = list(type = "double", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

data_check_results <- data.checker::new_validator(df, schema) |>
  data.checker::check() |>
  data.checker::add_check(description = "There are no males over 90 (tidy evaluation)", condition = !(sex == "M" & age > 90)) |>
  data.checker::add_check(description = "There are no males over 90 (standard evaluation)", condition = !(df$sex == "M" & df$age > 90))
```

``` r
data_check_results <- anonymise_validator(data_check_results)
```

``` r
print(data_check_results)
#>  System information                                                                                                                                                                                                     
#>  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>  Date: 2025-01-01
#> sysname: Windows
#> release: 10 x64
#> version: 
#> nodename: 
#> machine: 
#> login: username
#> user: username
#> effective_user: username
#> udomain: 
#> R version : R version 4.5.1 (2025-06-13 ucrt)
#> data.checker version: 0.0.0.9000  
#> 
#>  Timestamp   Description                                                               Outcome   Failing Ids   n Failing   Entry Type 
#> ----------  ------------------------------------------------------------------------  --------  ------------  ----------  -----------
#> 16:59:45    Column names contain no symbols other than underscores.                   ✅ pass                 N/A         warning    
#> 16:59:45    Column names contain no upper case letters.                               ✅ pass                 N/A         warning    
#> 16:59:45    All mandatory columns are present.                                        ✅ pass                 N/A         error      
#> 16:59:45    There are no unexpected columns.                                          ✅ pass                 N/A         error      
#> 16:59:45    Removed schema information for optional columns that aren't in the data                           N/A         info       
#> 16:59:45    Correct column types                                                      ❌ fail   id            1           error      
#> 16:59:45    Correct column classes                                                    ✅ pass                 N/A         error      
#> 16:59:45    There are no males over 90 (tidy evaluation)                              ✅ pass                 N/A         error      
#> 16:59:45    There are no males over 90 (standard evaluation)                          ✅ pass                 N/A         error
```

### Custom log entries

You can choose to add your own entries to the QA log using the
`add_qa_entry` function. The function expects a datachecker object as
the first argument and a description. You can also optionally add:

- `failing_ids`: a vector containing the columns/rows that failed the
  checks
- `outcome`: TRUE/FALSE for passing/failing checks or NA if you want to
  leave the field blank. Defaults to NA
- `entry_type`: either “info”, “warning” or “error”. Info = neutral log
  record, warning = something is wrong but could be safely ignored,
  error something is wrong that is likely to break your code. Defaults
  to “info”.

``` r
df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

schema <- list(
  check_completeness = FALSE,
  check_duplicates = FALSE,
  columns = list(
    age = list(type = "integer", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

validator <- data.checker::new_validator(df, schema)

validator <- data.checker::add_qa_entry(
  validator, 
  description = "Example custom log entry",
  entry_type = "info"
)
```

``` r
validator <- anonymise_validator(validator)
```

``` r
print(validator)
#>  System information                                                                                                                                                                                                     
#>  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>  Date: 2025-01-01
#> sysname: Windows
#> release: 10 x64
#> version: 
#> nodename: 
#> machine: 
#> login: username
#> user: username
#> effective_user: username
#> udomain: 
#> R version : R version 4.5.1 (2025-06-13 ucrt)
#> data.checker version: 0.0.0.9000  
#> 
#>  Timestamp   Description                Outcome   Failing Ids   n Failing   Entry Type 
#> ----------  -------------------------  --------  ------------  ----------  -----------
#> 16:59:46    Example custom log entry                           N/A         info
```
