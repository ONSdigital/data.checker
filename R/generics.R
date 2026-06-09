
#' Generic export function
#'
#' This function exists For ease of use - see export.Validator() for details.
#'
#' @param object The object to be checked.
#' @param ... Additional arguments passed to specific methods.
#'
#' @return The result of the export operation, specific to the object type.
#' @export
export <- function(object, ...) {
  UseMethod("export")
}
