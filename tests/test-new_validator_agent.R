df <- data.frame(a = 1.23, b = 2, c = 3)
columns <- list(
  a = list(type = "double", optional = TRUE, max_val = 100, min_val = 0, max_decimal = 2, min_decimal = 0),
  b = list(type = "character", optional = TRUE, min_string_length = 0, max_string_length = 10)
)
schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = columns)


test_that("new validator has agent field", {
    validator <- new_validator(
    data = df,
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    )
  ) 
  expect_true("agent" %in% names(validator))
  expect_true(inherits(validator$agent, "ptblank_agent"))
})