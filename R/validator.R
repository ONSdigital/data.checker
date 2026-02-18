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
#' @return The exported validation results.
#' @export
check_and_export <- function(data, schema, file, format, hard_check = FALSE) {
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
#' @return An object of class `Validator`.
#'
#' @export
new_validator <- function(data, schema) {
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
    schema <- types_to_classes(schema)  # Convert complex types to correct types and classes


    validator <- list("schema" = schema)
  }

  if ("data.frame" %in% class(data)) {
    validator$data <- data
  } else {
    stop("Data must be a data frame.")
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

  validator$agent <- create_pointblank_agent(validator$data, validator$schema)

  return(validator)
}


#' create_pointblank_agent
#'
#' creates pointblank agent with validation steps based on schema column types. Can be
#' appended for boilerplate checks.
#'
#' @param data A data frame to validate against the schema.
#' @param schema A schema object that defines the validation rules, including column types.
#'
#' @return A pointblank agent object with validation steps based on the schema.
#'
#' @export
create_pointblank_agent <- function(data, schema){
  agent <- pointblank::create_agent(tbl = data)
  int_columns <- c()
  factor_columns <- c()
  numeric_columns <- c()
  date_columns <- c()
  logical_columns <- c()
  char_columns <- c()
  for (col in names(schema$columns)) {
    col_info <- schema$columns[[col]]
    if (col_info$type == "integer") {
      int_columns <- c(int_columns, col)
    } else if (col_info$type == "factor") {
      factor_columns <- c(factor_columns, col)
    } else if (col_info$type == "double") {
      numeric_columns <- c(numeric_columns, col)
    } else if (col_info$type == "date") {
      date_columns <- c(date_columns, col)
    } else if (col_info$type == "logical") {
      logical_columns <- c(logical_columns, col)
    } else if (col_info$type == "character") {
      char_columns <- c(char_columns, col)
    }
  }

  agent <- agent |>
    pointblank::col_is_integer(columns = eval(int_columns)) |>
    pointblank::col_is_date(columns = eval(date_columns)) |>
    pointblank::col_is_logical(columns = eval(logical_columns)) |>
    pointblank::col_is_numeric(columns = eval(numeric_columns)) |>
    pointblank::col_is_factor(columns = eval(factor_columns)) |>
    pointblank::col_is_character(columns = eval(char_columns))

  return(agent)
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

  validator <- check_colnames(validator) |>
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
