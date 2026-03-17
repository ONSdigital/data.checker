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
  ) |> pointblank::interrogate(progress = FALSE)

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
    }) |> pointblank::interrogate(progress = FALSE)

  validator <- log_pointblank_outcomes(validator)

  return(validator)
}


#' Flag outliers based on Interquartile Range (IQR).
#' Outliers are flagged if they are below Q1 - (mulitplier * IQR) or above Q3 + (multiplier * IQR).
#' @param x A numeric vector.
#' @param multiplier A numeric value to multiply the IQR by (default is 1.5).
#' @return A vector the same size as `x`, with `TRUE` for values that are outliers and `FALSE` otherwise
#'
#' @export
iqr_bounds <- function(x, multiplier = 1.5) {
  iqr <- stats::IQR(x, na.rm = TRUE)
  lower = stats::quantile(x, 0.25, na.rm = TRUE) - (multiplier * iqr)
  upper = stats::quantile(x, 0.75, na.rm = TRUE) + (multiplier * iqr)

  return(x < lower | x > upper)
}

#' Check Z Score of Numeric Columns
#'
#' This function calculates the maximum z-score for a numeric column.
#' @param x A numeric vector.
#' @return A vector of the same length as `x`, indicating the z-score for each element.
#'
#' @export
z_score <- function(x) {
  z_scores <- (x - mean(x, na.rm = TRUE)) / stats::sd(x, na.rm = TRUE)
  return(z_scores)
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
#' @param i_col column index
#'
#' @return validator object

run_checks <- function(validator, i_col) {
  # Unpack all column configurations into functions scope

  list2env(validator$schema$columns[[i_col]], env = environment())
  # Store names of loaded variables
  loaded_vars <- names(validator$schema$columns[[i_col]])

  if (exists("allow_na") && !allow_na) {
    validator <- add_check(validator, sprintf("Column %s contains no missing values", i_col), !is.na(validator$data[[i_col]]))
  }

  if (exists("allow_duplicates") && !allow_duplicates) {
    validator <- add_check(validator, sprintf("column %s contains no duplicate values", i_col), !duplicated(validator$data[[i_col]]))
  }

  if (type == "double" | type == "integer") {
    if (is.character(class) && length(class) == 1 && class == "factor") {
      if (exists("expected_levels")) {
        validator$agent <- pointblank::col_vals_in_set(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          set = expected_levels,
          label = sprintf("Column %s contains expected factor levels", i_col)
        )
      }

    } else if (is.character(class) && length(class) == 1 && class == "Date") {
      if (exists("min_date")) {
        validator$agent <- pointblank::col_vals_gte(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          value = lubridate::ymd(min_date),
          label = sprintf("Column %s: dates are after %s", i_col, min_date),
          na_pass = TRUE
        )
      }
      if (exists("max_date")) {
        validator$agent <- pointblank::col_vals_lte(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          value = lubridate::ymd(max_date),
          label = sprintf("Column %s: dates are before %s", i_col, max_date),
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
          columns = tidyselect::all_of(i_col),
          value = min_datetime,
          label = sprintf("Column %s: datetimes are after %s", i_col, min_datetime),
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
          columns = tidyselect::all_of(i_col),
          value = max_datetime,
          label = sprintf("Column %s: datetimes are before %s", i_col, max_datetime),
          na_pass = TRUE
        )
      }
    }

    if (exists("min_val")) {
      validator$agent <- pointblank::col_vals_gte(
        validator$agent,
        columns = tidyselect::all_of(i_col),
        value = min_val,
        label = sprintf("Column %s: values are above or equal to %s", i_col, min_val),
        na_pass = TRUE
      )

    }

    if (exists("max_val")) {
      validator$agent <- pointblank::col_vals_lte(
        validator$agent,
        columns = tidyselect::all_of(i_col),
        value = max_val,
        label = sprintf("Column %s: values are below or equal to %s", i_col, max_val),
        na_pass = TRUE
      )
    }

    if (exists("iqr_check")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(!iqr_bounds(.data[[!!i_col]], multiplier = !!iqr_check)),
        label = sprintf("Column %s: values are not outliers based on IQR bounds with multiplier %s", i_col, iqr_check),
        na_pass = TRUE
      )
    }

    if (exists("max_z_score")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(abs(z_score(.data[[!!i_col]])) <= !!max_z_score),
        label = sprintf("Column %s: Absolute z-score below or equal to %s", i_col, max_z_score),
        na_pass = TRUE
      )
    }

  } else if (type == "character") {
    if (exists("min_string_length")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(nchar(.data[[!!i_col]]) >= !!min_string_length),
        label = sprintf("Column %s: string length above or equal to %s", i_col, min_string_length),
        na_pass = TRUE
      )
    }
    if (exists("max_string_length")) {
      validator$agent <- pointblank::col_vals_expr(
        validator$agent,
        expr = rlang::expr(nchar(.data[[!!i_col]]) <= !!max_string_length),
        label = sprintf("Column %s: string length below or equal to %s", i_col, max_string_length),
        na_pass = TRUE
      )
    }

    if (exists("forbidden_strings")) {
      if (is.character(forbidden_strings) && length(forbidden_strings) > 1) {
        validator$agent <- pointblank::col_vals_not_in_set(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          set = forbidden_strings,
          label = sprintf("Column %s does not contain forbidden strings", i_col)
        )
      } else if (is.character(forbidden_strings) && length(forbidden_strings) == 1) {
        validator$agent <- pointblank::col_vals_expr(
          validator$agent,
          expr = rlang::expr(!stringr::str_detect(.data[[!!i_col]], !!forbidden_strings)),
          label = sprintf("Column %s does not contain forbidden characters", i_col),
          na_pass = TRUE
        )
      }
    }

    if (exists("allowed_strings")) {
      if (is.character(allowed_strings) && length(allowed_strings) == 1) {
        validator$agent <- pointblank::col_vals_regex(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          regex = allowed_strings,
          label = sprintf("Column %s only contains allowed strings", i_col),
          na_pass = TRUE
        )
      } else if (is.character(allowed_strings) && length(allowed_strings) > 1) {
        validator$agent <- pointblank::col_vals_in_set(
          validator$agent,
          columns = tidyselect::all_of(i_col),
          set = allowed_strings,
          label = sprintf("Column %s only contains allowed strings", i_col)
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
  validator$agent <- pointblank::specially(validator$agent,
    fn = function(x) stringr::str_detect(colnames(x), "[^a-zA-Z0-9_]", negate = T),
    label = "Column names contain no symbols other than underscores."
  )

  # Check if column names contains capital letters
  validator$agent <- pointblank::specially(validator$agent,
    fn = function(x) stringr::str_detect(colnames(x), "[A-Z]", negate = T),
    label = "Column names contain no capital letters."
  )

  # Extract mandatory columns from the schema
  mandatory_columns <- validator$schema$columns[sapply(validator$schema$columns, function(x) !x$optional)] |> names()

  if (length(mandatory_columns) == 0) {
    stop("No mandatory columns specified in the schema. Please specify at least one mandatory column.")
  }

  # Check if all mandatory columns are present
  validator$agent <- pointblank::specially(validator$agent,
    fn = function(x) length(dplyr::setdiff(mandatory_columns, colnames(x))) == 0,
    label = "All mandatory columns are present."
  )

  # Extract unexpected columns
  unexpected_columns <- setdiff(names(validator$data), names(validator$schema$columns))
  unexpected_columns <- paste0("^(", paste(unexpected_columns, collapse = "|"), ")$")

  # Check that there are no expected columns
  validator$agent <- pointblank::specially(validator$agent,
    fn = function(x) stringr::str_detect(colnames(x), unexpected_columns, negate = TRUE),
    label = "There are no unexpected columns."
  )

  validator$agent <- pointblank::interrogate(validator$agent, progress = FALSE)
  validator <- log_pointblank_outcomes(validator)

  # Remove optional columns from schema if they do not exist in the data
  optional_columns <- names(validator$schema$columns)[sapply(validator$schema$columns, function(x) x$optional)]
  remove_cols <- setdiff(optional_columns, names(validator$data))
  validator$schema$columns <- validator$schema$columns[!names(validator$schema$columns) %in% remove_cols]
  validator <- add_qa_entry(validator,
                            description = "Removed schema information for optional columns that aren't in the data",
                            outcome = NA,
                            failing_ids = NA,
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
  schema_types <- schema_types[!sapply(schema_types, is.null)]  # drop any missing schema entries

  validator$agent <- pointblank::specially(
    validator$agent,
    label = "Correct column types",
    fn = function(x) {
      incorrect_types <- names(schema_types)[vapply(
        names(schema_types),
        function(nm) schema_types[[nm]] != typeof(x[[nm]]),
        logical(1)
      )]

      length(incorrect_types) == 0
    }
  )
  # Check column classes
  schema_classes <- lapply(
    validator$schema$columns,
    function(col) if ("class" %in% names(col)) col[["class"]] else NULL
  )
  schema_classes <- schema_classes[!vapply(schema_classes, is.null, logical(1))] # drop any missing schema entries

  validator$agent <- pointblank::specially(
    validator$agent,
    label = "Correct column classes",
    fn = function(x) {
      incorrect_classes <- names(schema_classes)[vapply(
        names(schema_classes),
        function(nm) {
          expected <- schema_classes[[nm]]
          actual <- class(x[[nm]])

          # expected can be length > 1; require identical class vector
          !identical(actual, expected)
        },
        logical(1)
      )]

      length(incorrect_classes) == 0
    }
  )

  if (nrow(validator$agent$validation_set) > 0) {
    validator$agent <- validator$agent |> pointblank::interrogate( progress = FALSE)
    validator <- log_pointblank_outcomes(validator)
  }
  return(validator)
}

# Utility function to convert expression to function for use in pointblank specially
expr_to_fun <- function() {
  as.function(alist(df=, exp =, {rlang::eval_tidy(exp, data=df)}))
}

#' Add a custom check to the validator
#'
#' This function allows you to add a custom check to the `Validator`object.
#'
#' @param validator A `Validator` object to which the custom check will be added.
#' @param description A description of the custom check.
#' @param condition Expression to be evaluated or logical conditions to define the custom check. Optional if outcome is set
#'
#' @return The updated `Validator` object with the custom check added.
#' @export
add_check <- function(validator, description, condition) {

  condition <-rlang::enquo(condition)
  fun <- expr_to_fun()

  validator$agent <- pointblank::specially(
    validator$agent,
    label = "description",
    fn = function(x) fun(df=x, exp=rlang::enquo(condition))
  ) |> pointblank::interrogate(progress = FALSE)

  validator <- log_pointblank_outcomes(validator)

  return(validator)
}

#' Add a custom check to the validator
#'
#' This function allows you to add a custom check outcomes to the validator log. The outcomes must be a logical vector.
#'
#' @param validator A `Validator` object to which the custom check will be added.
#' @param description A description of the custom check.
#' @param outcome Logical vector indicating the result of the check (TRUE/FALSE).
#' Outcome must be logical.
#' @param type The type of the check, can be "error", "warning", or "note".
#'
#' @return The updated `Validator` object with the custom check added.
#' @export
add_check_custom <- function(validator, description, outcome, type = c("error", "warning", "note")) {
  if (!is.logical(outcome)) {
    stop("Outcome must be a logical value (TRUE/FALSE)")
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

#' Check schema contents against the data frame provided
#'
#' This function checks that the contents of the schema are consistent with the data frame provided.
#' It checks for unused schema entries, incompatible schema entries, and that any columns specified
#' in the schema are present in the data frame.
#'
#' @param validator A `Validator` object containing the data and schema to check against.
#' @return The updated `Validator` object with QA entries added for any issues found in the schema.
#' @export
check_schema_contents_against_df <- function(validator) {
  valid_schema_entries = c("type", "allowed_strings", "forbidden_strings","optional","allow_na","class")
  max_min_cols <- c("val", "string_length", "date", "datetime")
    for (entry in max_min_cols) {
      valid_schema_entries <- c(valid_schema_entries, paste0("max_", entry), paste0("min_", entry))
    }

  for (col in names(validator$schema$columns)) {
    column_schema = validator$schema$columns[[col]]
    if ("allowed_strings" %in% names(column_schema) && "forbidden_strings" %in% names(column_schema)) {
      validator$schema$columns[[col]] <- column_schema[!names(column_schema) %in% c("forbidden_strings")]
      message = paste0("Column ", col, " allowed_strings and forbidden_strings cannot both be present. Using allowed_strings only.")
      validator <-add_qa_entry(
        validator = validator,
        description = message,
        outcome = NA,
        entry_type = "warning"
      )
  }

  unused_entries <- c()
  for (entry in names(column_schema)) {
    if (!entry %in% valid_schema_entries) {
      unused_entries <- c(unused_entries,entry)
    }
  }
  if (length(unused_entries) > 0) {
    validator <-add_qa_entry(
      validator = validator,
      description = paste0("Column ", col, " unused schema entries: ", paste(unused_entries, collapse = ", ")),
      outcome = NA,
      entry_type = "warning"
    )
  }
  }

  for (name_col in c("completeness_cols", "duplicate_cols")) {
  if (name_col %in% names(validator$schema)) {
    if (!(all(validator$schema[[name_col]] %in% colnames(validator$data)))) {
      stop(paste0("All columns specified in ", name_col, " must be present in the data."))
    }
  }
  }
  return(validator)
}
