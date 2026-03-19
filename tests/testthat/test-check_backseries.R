# Tests for check_backseries

test_that("column names and row checks pass when the data matches the backseries", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(5, 6, 7, 8),
    y = c("a", "c", "d", "e")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  validator <- check_backseries(validator)
})

test_that("column names and row checks fail when the data does not match the backseries", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(5, 6, 7),
    z = c("a", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  validator <- check_backseries(validator)
})