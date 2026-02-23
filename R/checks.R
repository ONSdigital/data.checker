#' Check for duplicate rows
#'
#' @param validator `Validator` object
#'
#' @return NULL
#' @export
check_duplicates <- function(validator) {
  cols <- validator$schema$duplicates_cols
  if (is.null(cols)) {
    cols <- colnames(validator$data)
  }

  validator$agent <- pointblank::rows_distinct(
    validator$agent,
    columns = tidyselect::all_of(cols),
    label = "There are no duplicated rows"
  ) |> pointblank::interrogate()

  validator <- log_pointblank_outcomes(validator)

  return(validator)
}


#' Check dataset for missing columns
#'
#' @param validator data `Validator` object
#'
#' @return NULL
#' @export
check_completeness <- function(validator) {
  cols <- validator$schema$completeness_cols

  if (is.null(cols)) {
    cols <- colnames(validator$data)
  }

  validator$agent <- pointblank::specially(
    validator$agent,
    label = "There are no missing rows based on specified columns",
    fn = function(x) {
      nrow(
        dplyr::anti_join(
          tidyr::expand(x, !!!rlang::syms(cols)),
          dplyr::distinct(x, !!!rlang::syms(cols))
        )
      ) == 0
    }) |> pointblank::interrogate()

  validator <- log_pointblank_outcomes(validator)

  return(validator)
}



#' Check Decimal Places in Numeric Columns
#'
#' This function calculates the number of decimal places in a numeric vector.
#' @param x A numeric vector.
#' @return A vector of the same length as `x`, indicating the number of decimal
#' places for each element. If an element is `NA`, it returns `NA`.
#'
#' @export
decimal_places <- function(x) {
  ifelse(is.na(x), NA, nchar(sub("^[^.]*\\.?", "", as.character(x))))
}

#' Check Column Contents against schema and checks
#'
#' This function performs checks on the columns of `Validator$data` to ensure they meet the
#' specified schema conditions and checks.
#'
#' @param validator A `Validator` object containing the column names to be checked.
#'
#' @return The updated `Validator` object with QA entries for each check.
#'
#' @export
check_column_contents <- function(validator) {
  for (i in names(validator$data)) {
    if (i %in% names(validator$schema$columns)) {
      validator <- run_checks(validator, i)
    }
  }
  if (nrow(validator$agent$validation_set) > 0) {
    validator$agent <- validator$agent |> pointblank::interrogate( progress = FALSE)
    validator <- log_pointblank_outcomes(validator)
  }

  # validator <- log_pointblank_outcomes(validator)


  return(validator)
}

#' Run column checks
#'
#' To be used by check_column_contents - not intended to be run separately.
#'
#' @param validator `Validator` object passed from check_column_contents.
#' @param i column index
#'
#' @return validator object

run_checks <- function(validator, i) {
  # Unpack all column configurations into functions scope

  list2env(validator$schema$columns[[i]], env = environment())
  # Store names of loaded variables
  loaded_vars <- names(validator$schema$columns[[i]])

  if (exists("allow_na") && !allow_na) {
    validator <- add_check(validator, sprintf("Column %s contains no missing values", i), !is.na(validator$data[[i]]), type = "error")
  }

  if (exists("allow_duplicates") && !allow_duplicates) {
    validator <- add_check(validator, sprintf("column %s contains no duplicate values", i), !duplicated(validator$data[[i]], type = "error"))
  }

  if (type == "double" | type == "integer") {
    if (is.character(class) && length(class) == 1 && class == "factor") {
      if (exists("expected_levels")) {
        validator$agent <- pointblank::col_vals_in_set(
          validator$agent,
          columns = tidyselect::all_of(i),
          set = expected_levels,
          label = sprintf("Column %s contains expected factor levels", i)
        )
      }

    } else if (is.character(class) && length(class) == 1 && class == "Date") {
      if (exists("min_date")) {
        validator$agent <- pointblank::col_vals_gte(
          validator$agent,
          columns = tidyselect::all_of(i),
          value = lubridate::ymd(min_date),
          label = sprintf("Column %s: dates are after %s", i, min_date),
          na_pass = TRUE
        )
      }
      if (exists("max_date")) {
        validator$agent <- pointblank::col_vals_lte(
          validator$agent,
          columns = tidyselect::all_of(i),
          value = lubridate::ymd(max_date),
          label = sprintf("Column %s: dates are before %s", i, max_date),
          na_pass = TRUE
        )
      }

    } else if (is.character(class) && all(class %in% c("POSIXct", "POSIXt", "POSIXlt"))) {
      if (exists("min_datetime")) {
        min_datetime <- lubridate::parse_date_time(
          min_datetime,
          orders = c("y", "ym", "ymd", "ymd H", "ymd HM", "ymd HMS")
        )
        validator$agent <- pointblank::col_vals_gte(
          validator$agent,
          columns = tidyselect::all_of(i),
          value = min_datetime,
          label = sprintf("Column %s: datetimes are after %s", i, min_datetime),
          na_pass = TRUE
        )
      }
      if (exists("max_datetime")) {
        max_datetime <- lubridate::parse_date_time(
          max_datetime,
          orders = c("y", "ym", "ymd", "ymd H", "ymd HM", "ymd HMS")
        )
        validator$agent <- pointblank::col_vals_lte(
          validator$agent,
          columns = tidyselect::all_of(i),
          value = max_datetime,
          label = sprintf("Column %s: datetimes are before %s", i, max_datetime),
          na_pass = TRUE
        )
      }
    }

    if (exists("min_val")) {
      validator$agent <- pointblank::col_vals_gte(
        validator$agent,
        columns = tidyselect::all_of(i),
        value = min_val,
        label = sprintf("Column %s: values are above or equal to %s", i, min_val),
        na_pass = TRUE
      )

    }

    if (exists("max_val")) {
      validator$agent <- pointblank::col_vals_lte(
        validator$agent,
        columns = tidyselect::all_of(i),
        value = max_val,
        label = sprintf("Column %s: values are below or equal to %s", i, max_val),
        na_pass = TRUE
      )
    }

    if (exists("min_decimal")) {
      validator$agent <-pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(decimal_places(.data[[!!i]]) >= !!min_decimal),
        label = sprintf("Column %s: decimal places above or equal to %s", i, min_decimal),
        na_pass = TRUE
      )
    }

    if (exists("max_decimal")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(decimal_places(.data[[!!i]]) <= !!max_decimal),
        label = sprintf("Column %s: decimal places below or equal to %s", i, max_decimal),
        na_pass = TRUE
      )
    }
  } else if (type == "character") {
    if (exists("min_string_length")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(nchar(.data[[!!i]]) >= !!min_string_length),
        label = sprintf("Column %s: string length above or equal to %s", i, min_string_length),
        na_pass = TRUE
      )
    }
    if (exists("max_string_length")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(nchar(.data[[!!i]]) <= !!max_string_length),
        label = sprintf("Column %s: string length below or equal to %s", i, max_string_length),
        na_pass = TRUE
      )
    }

    if (exists("forbidden_strings")) {
      if (is.character(forbidden_strings) && length(forbidden_strings) > 1) {
        validator$agent <- pointblank::col_vals_not_in_set(
          validator$agent,
          columns = tidyselect::all_of(i),
          set = forbidden_strings,
          label = sprintf("Column %s does not contain forbidden strings", i)
        )
      } else if (is.character(forbidden_strings) && length(forbidden_strings) == 1) {
        validator$agent <- pointblank::col_vals_expr(
          validator$agent,
          expr = rlang::expr(!stringr::str_detect(.data[[!!i]], !!forbidden_strings)),
          label = sprintf("Column %s does not contain forbidden characters", i),
          na_pass = TRUE
        )
      }
    }

    if (exists("allowed_strings")) {
      if (is.character(allowed_strings) && length(allowed_strings) == 1) {
        validator$agent <- pointblank::col_vals_regex(
          validator$agent,
          columns = tidyselect::all_of(i),
          regex = allowed_strings,
          label = sprintf("Column %s only contains allowed strings", i),
          na_pass = TRUE
        )
      } else if (is.character(allowed_strings) && length(allowed_strings) > 1) {
        validator$agent <- pointblank::col_vals_in_set(
          validator$agent,
          columns = tidyselect::all_of(i),
          set = allowed_strings,
          label = sprintf("Column %s only contains allowed strings", i)
        )
      }
    }
  }
  return(validator)
}



#' Check Column Names against schema
#'
#' This function performs checks on the column names of a `Validator` object to ensure they follow specific naming conventions and
#' meet schema conditions.
#'
#' @param validator A `Validator` object containing the column names to be checked.
#'
#' @details
#' The function performs the following checks on the column names:
#' - Ensures column names do not contain spaces.
#' - Ensures column names do not contain symbols other than underscores.
#' - Ensures column names do not contain uppercase letters.
#'
#' For each check, a QA entry is added to the `Validator` object with details about the check, whether it passed, and the IDs of failing columns (if any). # nolint: line_length_linter.
#'
#' @return The updated `Validator` object with QA entries for each check.
#'
#' @export
check_colnames <- function(validator) {

  # Check if column names contains symbols other than underscores
  failing_ids <- names(validator$data)[grepl("[^a-zA-Z0-9_]", names(validator$data))]
  validator <- add_qa_entry(validator,
                            description = "Column names contain no symbols other than underscores.",
                            outcome = length(failing_ids) == 0,
                            failing_ids = failing_ids,
                            entry_type = "warning")

  # Check if column names contains capital letters
  failing_ids <- names(validator$data)[grepl("[A-Z]", names(validator$data))]
  validator <- add_qa_entry(validator,
                            description = "Column names contain no upper case letters.",
                            outcome = length(failing_ids) == 0,
                            failing_ids = failing_ids,
                            entry_type = "warning")

  # Extract mandatory columns from the schema
  mandatory_columns <- validator$schema$columns[sapply(validator$schema$columns, function(x) !x$optional)]

  # Check if all mandatory columns are present
  missing_columns <- setdiff(names(mandatory_columns), names(validator$data))
  validator <- add_qa_entry(validator,
                            description = "All mandatory columns are present.",
                            outcome = length(missing_columns) == 0,
                            failing_ids = missing_columns,
                            entry_type = "error")

  # Check that there are no expected columns
  unexpected_columns <- setdiff(names(validator$data), names(validator$schema$columns))
  validator <- add_qa_entry(validator,
                            description = "There are no unexpected columns.",
                            outcome = length(unexpected_columns) == 0,
                            failing_ids = unexpected_columns,
                            entry_type = "error")

  # Remove optional columns from schema if they do not exist in the data
  optional_columns <- names(validator$schema$columns)[sapply(validator$schema$columns, function(x) x$optional)]
  remove_cols <- setdiff(optional_columns, names(validator$data))
  validator$schema$columns <- validator$schema$columns[!names(validator$schema$columns) %in% remove_cols]
  validator <- add_qa_entry(validator,
                            description = "Removed schema information for optional columns that aren't in the data",
                            outcome = NA,
                            failing_ids = unexpected_columns,
                            entry_type = "info")

  return(validator)
}

#' Check Column Types and Classes
#'
#' This function checks the types and classes of the columns in the data against the schema
#' defined in the `Validator` object.
#'
#' @param validator A `Validator` object containing the data and schema to check against. The schema
#' should define the expected `type` and optionally the `class` for each column.
#'
#' @return The updated `Validator` object with quality assurance (QA) entries added for type and
#' class checks. Each QA entry includes a description, pass/fail status, and any failing column IDs.
#'
#' @export
check_types <- function(validator) {
  # Check column types
  schema_types <- lapply(validator$schema$columns, `[[`, "type")

  incorrect_types <- sapply(names(schema_types), function(x) {
    if (schema_types[[x]] != typeof(validator$data[[x]])) {
      return(x)
    }
  }) |> unlist() |> unname()

  if (length(incorrect_types) == 0) {
    validator <- add_qa_entry(
      validator,
      description = "Correct column types",
      outcome = TRUE,
      entry_type = "error"
    )
  } else {
    validator <- add_qa_entry(
      validator,
      description = "Correct column types",
      outcome = FALSE,
      failing_ids = incorrect_types,
      entry_type = "error"
    )
  }
  # Check column classes
  schema_classes <- lapply(validator$schema$columns, function(col) if ("class" %in% names(col)) col[["class"]])
  schema_classes <- schema_classes[!sapply(schema_classes, is.null)]  # Remove NULL entries

  incorrect_classes <- sapply(names(schema_classes), function(x) {
    # Check if all classes match (including multi-class objects)
    if (all(class(validator$data[[x]]) != schema_classes[[x]])) {
      return(x)
    }
  }) |> unlist() |> unname()

  if (length(incorrect_classes) > 0) {
    validator <- add_qa_entry(
      validator,
      description = "Correct column classes",
      outcome = FALSE,
      failing_ids = incorrect_classes,
      entry_type = "error"
    )
  } else {
    validator <- add_qa_entry(
      validator,
      description = "Correct column classes",
      outcome = TRUE,
      entry_type = "error"
    )
  }

  return(validator)
}

#' Add a custom check to the validator
#'
#' This function allows you to add a custom check to the `Validator`object.
#'
#' @param validator A `Validator` object to which the custom check will be added.
#' @param description A description of the custom check.
#' @param outcome Logical vector - one value per row if rowwise, or a single value if not. Optional if condition is set.
#' @param condition Expression to be evaluated or logical conditions to define the custom check. Optional if outcome is set
#' @param type The type of the check, which can be one of "error", "warning", or "info".
#' @param rowwise Logical indicating whether the check should be applied row-wise, i.e. return a result per row. Defaults to `TRUE`. If false, the check will return a single logical value.
#'
#' @return The updated `Validator` object with the custom check added.
#' @export
add_check <- function(validator, description, outcome, condition, type = c("error", "warning", "info"), rowwise = TRUE) {
  if (missing(outcome)) {
    outcome <- rlang::eval_tidy(substitute(condition), data = validator$data)
  }

  if (rowwise) {
    validator <- add_qa_entry(
      validator,
      description = description,
      failing_ids = which(!outcome),
      outcome = length(which(!outcome)) == 0,
      entry_type = match.arg(type)
    )
  } else {
    validator <- add_qa_entry(
      validator,
      description = description,
      outcome = outcome,
      entry_type = match.arg(type)
    )
  }

  return(validator)
}

#' Check the status of errors and warnings in the validator log
#'
#' This function raises errors or warnings if any checks flagged as error or warnings fail.
#'
#' @param validator A `Validator` object to check the log.
#' @param hard_check A logical value indicating whether to perform hard checks (default is TRUE).
#'
#' Warning if there are any warnings or errors in the log when `hard_check` is FALSE.
#' Error if there are any errors and `hard_check` is TRUE.
#' @export
hard_checks_status <- function(validator, hard_check){

  # intitalising error and warning counters
  error_counter <- 0
  warning_counter <- 0
  for (entry in validator$log) {
    if (entry$entry_type == "error" && (entry$outcome == "\U000274C fail" || entry$outcome == "fail")) {
      error_counter <- error_counter + 1
    }
    else if (entry$entry_type == "warning" && (entry$outcome == "\U000274C fail" || entry$outcome == "fail")) {
      warning_counter <- warning_counter + 1
    }
  }
  if (warning_counter > 0) {
    warning(sprintf("Soft checks failed: %d warning(s) found, see log output for more details", warning_counter))
  }

  if (hard_check && error_counter > 0) {
    stop(sprintf("Hard checks failed: %d error(s) found, see log output for more details", error_counter))
  }
  else if (!hard_check && error_counter > 0) {
    warning(sprintf("Soft checks failed: %d error(s) found, see log output for more details", error_counter))
  }


}
