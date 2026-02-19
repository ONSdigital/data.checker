#' Add a QA Entry to the validator's QA Log
#'
#' This function adds a new entry to the validator's QA log with details such as a description, type of entry, timestamp, pass status, and failing IDs.
#'
#' @param validator a `Validator` object.
#' @param description A character string describing the QA entry.
#' @param failing_ids Optional: A vector of IDs that failed the QA check. If more than 10 IDs are provided, only the first 10 are stored, with a note indicating the additional count.
#' @param outcome Optional: A logical value indicating whether the QA check passed. If not provided or invalid, defaults to `NA`.
#' @param entry_type Optional: A character string specifying the type of entry. Must be one of "info", "warning", or "error". Defaults to "info".
#'
#' @return The updated validator object with the new entry appended to its QA log.
#'
#' @export
add_qa_entry <- function(
  validator,
  description,
  failing_ids,
  outcome = NA,
  entry_type = c("info", "warning", "error")
) {

  outcome <- convert_bool_pass_fail(outcome)

  entry_type <- match.arg(entry_type)

  if(!missing(failing_ids) && !is.null(failing_ids)) {
    if (length(failing_ids) > 10) {
      failing_ids <- c(failing_ids[1:10], paste0("..."))
    }
  } else {
    failing_ids <- c()
  }

  timestamp <- format(Sys.time(), "%H:%M:%S")

  if (sum(!is.na(failing_ids)) == 0) {
    number_failing <- "N/A"
  } else {
    number_failing <- sum(!is.na(failing_ids))
  }

  entry <- list(
    timestamp = timestamp,
    description = description,
    outcome = outcome,
    failing_ids = failing_ids,
    n_failing = number_failing,
    entry_type = entry_type
  )

  validator$log <- append(validator$log, list(entry))
  return(validator)

}

convert_bool_pass_fail <- function(x) {
  pass <- ifelse(cli::is_utf8_output(), "\U0002705 pass", "pass")
  fail <- ifelse(cli::is_utf8_output(), "\U000274C fail", "fail")
  x <- ifelse(x, pass, fail)
  return(x)
}