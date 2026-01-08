test_that("The validator logs an error if types are wrong", {
  validator <- new_validator(
  schema = list(
    columns = list(
      a = list(type = "double", optional = TRUE),
      b = list(type = "character", optional = TRUE)
    ),
    hard_checks = TRUE,
    check_duplicates = FALSE, check_completeness = FALSE
  ),
  data = data.frame(a = 1, b = 2)
)

  validator <- check_types(validator)

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$n_failing, 1)
})

test_that("The validator logs a pass if all types are correct", {
  validator <- new_validator(
    schema = list(
      columns = list(
        a = list(type = "double", optional = TRUE),
        b = list(type = "character", optional = TRUE)
      ),
      hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE
    ),
    data = data.frame(a = 1.5, b = "test", stringsAsFactors = FALSE)
  )

  validator <- check_types(validator)

  expect_equal(validator$log[[2]]$outcome, "pass")
  expect_equal(validator$log[[2]]$n_failing, "N/A")
})

test_that("check_types validates column types and classes correctly", {
  validator <- new_validator(
    schema = list(
      columns = list(
        a = list(type = "double", class = "numeric", optional = TRUE),
        b = list(type = "character", class = "character", optional = TRUE)
      ),
      check_duplicates = FALSE, check_completeness = FALSE,
      hard_checks = TRUE,
      check_duplicates = FALSE,
      check_completeness = FALSE
    ),
    data = data.frame(a = 1.5, b = "test", stringsAsFactors = FALSE)
  )

  # Execute: Perform type and class validation
  validator <- check_types(validator)

  expect_equal(validator$log[[3]]$outcome, "pass")
  expect_equal(validator$log[[3]]$n_failing, "N/A")
})
