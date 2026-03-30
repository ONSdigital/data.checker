#' Validate data against a schema and output results
#'
#' This function validates data against a given schema, performs checks,
#' and exports the validation results to a specified file in a given format.
#'
#' @param data The data to be validated.
#' @param schema The schema to validate against.
#' @param file The file path where the validation results will be exported.
#' @param format The format in which the validation results will be exported.
#' @param hard_check logical. Optional - FALSE by default. If TRUE, raises an error if there are any failed checks. Otherwise, raises a warning.
#' @param backseries A previous version of the data to check against (optional).
#' @return The exported validation results.
#' @export
check_and_export <- function(data, schema, file, format, hard_check = FALSE, backseries = NULL) {
  validator <- new_validator(data, schema) |>
    check() |>
    export(file = file, format = format) |>
    hard_checks_status(hard_check = hard_check)
}

#' Validator Constructor
#'
#' Creates a `Validator` object to validate data against a given schema.
#' @param data A data frame to validate against the schema.
#' @param schema A schema object that defines the validation rules.
#' @param backseries A previous version of the data to check against (optional).
#' @return An object of class `Validator`.
#'
#' @export
new_validator <- function(data, schema, backseries = NULL) {
  if (is.character(schema)) {
    if (grepl("\\.json$", schema)) {
      schema <- jsonlite::fromJSON(schema)
    } else if (grepl("\\.ya?ml$", schema)) {
      schema <- yaml::read_yaml(schema)
    } else if (grepl("\\.toml$", schema)) {
      schema <- tomledit::from_toml(tomledit::read_toml(schema))
    } else {
      stop("Unsupported file format. Only .json, .yaml/.yml, and .toml are allowed.")
    }
  } else if (typeof(schema) != "list") {
    stop("Schema must be a list or a file path to a JSON/YAML schema.")
  }

  if (is_valid_schema(schema)) {
    schema <- validate_and_convert_date_formats(schema) # check date formats are correct
    schema <- types_to_classes(schema)  # Convert complex types to correct types and classes
    is_column_contents_valid(schema) # checks max and min values are valid
    validator <- list("schema" = schema)
  }

  if ("data.frame" %in% class(data)) {
    validator$data <- data
  } else {
    stop("Data must be a data frame.")
  }

  if ("backseries" %in% names(validator$schema)) {
    if (!is.null(backseries)) {
      if ("data.frame" %in% class(backseries)) {
        validator$backseries <- backseries
      } else {
        stop("Backseries must be a data frame.")
      }
    } else {
      stop("Backseries is required by the schema but not provided.")
    }
  }

  validator$log <- list()  # Initialize an empty log for validation results

  class(validator) <- "Validator"

  info <- paste0(
    "Date: ", Sys.Date(), "\n",
    paste0(names(Sys.info()), ": ", Sys.info(), collapse = "\n"), "\n",
    "R version : ", version$version.string, "\n",
    "data.checker version: ", as.character(utils::packageVersion("data.checker")), "\n"
  )

  validator <- add_qa_entry(
    validator,
    description = info,
    outcome = NA,
    entry_type = "info"
  )

  validator$agent <- pointblank::create_agent(tbl = validator$data)

  return(validator)
}

#' Check column contents valid
#' 
#' This wrapper calls is_valid_column_values for each column in the schema 
#' 
#' @param schema the validator schema 
#' 
#' @return `TRUE` if all column values are valid, otherwise an error is raised.
is_column_contents_valid <- function(schema) {
  for (col in names(schema$columns)) {
    is_valid_column_values(schema$columns[[col]], col)
  }
  return(TRUE)
}

#' Validate a Validator Object
#'
#' This function runs the full suite of validation checks on a `Validator` object.
#'
#' @param validator An object of class `Validator` to be validated.
#' @param ... Additional arguments (currently unused).
#'
#' @return The validated `Validator` object if all checks pass. If any check fails, an error is thrown.
#'
#' @export
check <- function(validator, ...) {
  # Ensure the object is a Validator
  if (!inherits(validator, "Validator")) {
    stop("The object must be of class 'Validator'.")
  }

  validator <- check_schema_contents_against_df(validator) |>
    check_colnames() |>
    check_types() |>
    check_column_contents()

  if (validator$schema$check_duplicates) {
    validator <- check_duplicates(validator)
  }

  if (validator$schema$check_completeness) {
    validator <- check_completeness(validator)
  }

  return(validator)
}

#' Check if the schema is valid
#'
#' @param schema A list to validate.
#'
#' @return `TRUE` if the schema is a valid named list, otherwise `FALSE`.
#'
#' @export
is_valid_schema <- function(schema) {
  # Check if the input is a list
  if (!is.list(schema)) {
    stop("Schema must be a list.")
  }

  # Check if all elements in the list are named
  if (is.null(names(schema)) || any(names(schema) == "")) {
    stop("Schema must be a named list.")
  }

  if (!"columns" %in% names(schema)) {
    stop("Schema must contain a 'columns' element.")
  } else if (!"check_duplicates" %in% names(schema)) {
    stop("Schema must contain a 'check_duplicates' element")
  } else if (!"check_completeness" %in% names(schema)) {
    stop("Schema must contain a 'check_completeness' element")
  }
  return(TRUE)
}

#' Check that max values are not less than min values in column schema
#' 
#' This function checks that for any column schema, the max values 
#' (e.g., max_string_length, max_date) are not less than the corresponding min values 
#' (e.g., min_string_length, min_date). If any such inconsistency is found, an error 
#' is raised with a descriptive message.
#' 
#' @param column_schema A list representing the schema for a specific column, which may contain max and min value specifications.
#' @param col_name The name of the column being checked, used for error messages.
#' @return `TRUE` if all max values are greater than or equal to their corresponding min values, otherwise an error is raised.
#' @export
is_valid_column_values <- function(column_schema, col_name){
  max_min_cols <- c("val", "string_length", "date", "datetime")
  for (col in max_min_cols) {
    max_col <- paste0("max_", col)
    min_col <- paste0("min_", col)
    if (max_col %in% names(column_schema) && min_col %in% names(column_schema)) {
      if (column_schema[[max_col]] < column_schema[[min_col]] & typeof(column_schema[[max_col]]) == typeof(column_schema[[min_col]])) {
        stop(paste0("Column ", col_name, " ", max_col, " cannot be less than ", min_col, "."))
      }
      else if (typeof(column_schema[[max_col]]) != typeof(column_schema[[min_col]])) {
        stop(paste0("Column ", col_name, " ", max_col, " and ", min_col, " must be of the same type."))
      }
    }
  }    
}

#' Convert complex types to the correct types and classes
#'
#' This function modifies a schema by converting column types to their corresponding R classes.
#'
#' @param schema A list containing a `columns` element, where each column is a list with a `type` field.
#' @return The modified schema with updated `type` and `class` fields for each column.
#' @export
types_to_classes <- function(schema) {
  schema$columns <- lapply(schema$columns, function(col) {
    if (col$type == "factor") {
      col$type <- "integer"
      col$class <- "factor"
    } else if (col$type == "Date" | col$type == "date") {
      col$type <- "double"
      col$class <- "Date"
    } else if (col$type == "datetime" | col$type == "time") {
      col$type <- "double"
      col$class <- c("POSIXct", "POSIXt")
    }

    return(col)
  })

  return(schema)
}

#' Validate date formats in the schema
#' This function checks that any date formats specified in the schema are valid and can be parsed correctly.
#
#' @param schema A list containing a `columns` element, where each column may have `min_date` and `max_date` fields.
#' @return The original schema if all date formats are valid. If any date format is invalid, an error is thrown with a message indicating the issue.
#' @export
validate_and_convert_date_formats <- function(schema){
   schema$columns <- lapply(schema$columns, function(col) {
    if (exists("min_date", where = col)) {
      col$min_date <-tryCatch(lubridate::ymd(col$min_date), warning = function(w) "invalid")
      # if warning raises, dtype becomes character, otherwise its double
      if (typeof(col$min_date) == "character") {
        stop(sprintf("Invalid date format for min_date in column '%s' use Year Month Day format", col))
      }
    }
    if (exists("max_date", where = col)) {
      col$max_date <-tryCatch(lubridate::ymd(col$max_date), warning = function(w) "invalid")
      # if warning raises, dtype becomes character, otherwise its double
      if (typeof(col$max_date) == "character") {
        stop(sprintf("Invalid date format for max_date in column '%s', use Year Month Day format", col))
      }
    }
    return(col)
  })

  return(schema)
}