#' Export Validator Log
#'
#' This function exports the log of a `Validator` object to a file in the specified format.
#'
#' @param object A `Validator` object containing the log to be exported.
#' @param file A string specifying the file path where the log will be exported.
#'   The file extension must match the specified format.
#' @param format A string specifying the format of the output file.
#'   Supported formats are `"yaml"`, `"json"`, `"html"`, and `"csv"`.
#' @param ... Additional arguments passed to specific methods.
#'
#' @return Writes the log to the specified file. No value is returned.

#' @export
export.Validator <- function(object, file, format = c("yaml", "json", "html", "csv"), ...) {


  format <- match.arg(format)

  file_extension <- tools::file_ext(file)

  if (file_extension != format) {
    stop(sprintf("File extension '.%s' does not match the requested format '%s'.", file_extension, format))
  }

  if (format == "yaml") {
    yaml::write_yaml(object$log, file)
  } else if (format == "json") {
    jsonlite::write_json(object$log, file, pretty = TRUE)
  } else if (format == "html") {
    html_content <- log_html(object$log)
    writeLines(html_content, file)
  } else if (format == "csv") {
    log_table <- log_to_table(object$log)
    log_table$Outcome <- gsub("[^\x20-\x7F]", "", log_table$Outcome)
    utils::write.csv(log_table, file, row.names = FALSE)
  }
  return(object)
}

#' Convert Validator Log to Table
#'
#' This function converts a validator log into a formatted data frame (table) for exports.
#'
#' @param log A list representing the validator log, where each element is a log entry.
#'
#' @return A data frame containing the formatted log entries.
#' @export
log_to_table <- function(log) {
  table <- lapply(log, function(x) {
    x$failing_ids <- paste0(x$failing_ids, collapse = ", ")
    x[is.na(x) | x == "NA"] <- ""
    data.frame(x)
  })

  table <- do.call(rbind, table)

  colnames(table) <- gsub("_", " ", colnames(table))
  colnames(table) <- tools::toTitleCase(gsub("_", " ", colnames(table))) # Capitalize first letter of each word

  return(table)
}

#' Print Validator Log
#'
#' This function prints the log of a `Validator` object in a markdown table format.
#'
#' @param x A `Validator` object containing a log to be printed.
#' @param ... Additional arguments passed to specific methods.
#'
#' @return A markdown-formatted table of the validator log.
#' @export
print.Validator <- function(x, ...) {
  if (length(x$log) > 1) {
    text_log <- log_to_table(x$log[2:length(x$log)]) # Skip the first entry which is system info
    text_log <- knitr::kable(text_log, format = "simple") |>
      as.character() |>
      paste0(collapse = "\n")
  } else {
    text_log <- ""
  }

  info <- knitr::kable( x$log[[1]]$description, col.names = "System information", format  = "simple") |>
    as.character() |>
    paste0(collapse = "\n")
  cat(info, "\n\n", text_log, "\n")
}

#' Generate HTML Representation of a Log
#'
#' @param log A log object to be converted into HTML. It is expected to be in a format compatible with `log_to_table`.
#'
#' @return A string containing the HTML representation of the log.
#'
#' @importFrom glue glue
#' @importFrom knitr kable
#' @export
log_html <- function(log) {
  text_log <- log_to_table(log[2:length(log)]) # Skip the first entry which is system info
  info <- gsub("\n", "<br>", log[[1]]$description)

  html <- glue::glue('<!DOCTYPE html>
            <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Document</title>
              <style>
                body {
                  font-family: Arial, Helvetica, sans-serif;
                  font-size: 16px;
                  line-height: 1.5;
                  margin: 0;
                  padding: 0;
                }
                header {
                  background-color: #f8f9fa;
                  padding: 1rem;
                  text-align: center;
                }
                main {
                  padding: 1rem;
                }
                table {
                  width: 100%;
                  border-collapse: collapse;
                  margin-top: 1rem;
                }
                th, td {
                  border: 1px solid #ddd;
                  padding: 0.5rem;
                  text-align: left;
                }
                th {
                  background-color: #f2f2f2;
                }
              </style>
            </head>
            <body>
              <header>
                <h1>QA log</h1>
              </header>
              <main>
                <h2>System Information</h2>
                {{{info}}}

                <h2> QA log </h2>
                {{{knitr::kable(text_log, format = "html")}}}
              </main>
            </body>
            </html>
            ', .open = "{{{", .close = "}}}")

  return(html)
}


#' Log pointblank validation outcomes to a validator log
#'
#' This function extracts validation results from a pointblank agent and appends them to the validator's log.
#'
#' @param validator A list containing a pointblank agent and a log. The agent should have a validation_set from a pointblank interrogation.
#' @return The updated validator list with new log entries appended.
#' @details Each entry in the log will contain the timestamp, description, outcome, failing row indices, number of failures, and entry type for each validation step.
log_pointblank_outcomes <- function(validator){
  entries <- apply(validator$agent$validation_set, 1, function(x) {
    list(
      timestamp = x$time_processed,
      description = x$label,
      outcome = ifelse(x$all_passed, "pass", "fail"),
      failing_ids = which(x$tbl_checked[[1]]$pb_is_good_ == FALSE),
      n_failing = x$n_failed,
      entry_type = "error"
    )
  })
 
  validator$log <- append(validator$log, entries)
 
  return(validator)
 }
 