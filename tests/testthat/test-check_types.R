test_that("The validator logs an error if types are wrong", {
  validator <- new_validator(
  schema = list(
    columns = list(
      a = list(type = "double", optional = TRUE),
      b = list(type = "character", optional = TRUE)
    ),
    hard_checks = TRUE,
    check_duplicates = FALSE, 
    check_completeness = FALSE
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
  expect_equal(validator$log[[2]]$n_failing, 0)
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
  expect_equal(validator$log[[3]]$n_failing, 0)
})

test_that("checks work for multiple non-optional columns", {
  validator <- new_validator(
    schema = list(
      columns = list(
        a = list(type = "double", optional = FALSE),
        b = list(type = "character", optional = FALSE)
      ),
      check_duplicates = FALSE, check_completeness = FALSE,
      hard_checks = TRUE,
      check_duplicates = FALSE,
      check_completeness = FALSE
    ),
    data = data.frame(a = 1.5, b = "test", stringsAsFactors = FALSE)
  )

  validator <- check_types(validator)

  expect_equal(validator$log[[2]]$outcome, "pass")
  expect_equal(validator$log[[2]]$n_failing, 0)
})

test_that("class checks work for multiple non-optional columns", {
  validator <- new_validator(
    schema = list(
      columns = list(
        a = list(type = "double", class = "numeric", optional = FALSE),
        b = list(type = "character", class = "character", optional = FALSE)
      ),
      check_duplicates = FALSE, check_completeness = FALSE,
      hard_checks = TRUE,
      check_duplicates = FALSE,
      check_completeness = FALSE
    ),
    data = data.frame(a = 1.5, b = "test", stringsAsFactors = FALSE)
  )

  validator <- check_types(validator)

  expect_equal(validator$log[[3]]$outcome, "pass")
  expect_equal(validator$log[[3]]$n_failing, 0)
})

test_that("The validator logs fails when both type and class checks fail", {
  validator <- new_validator(
    schema = list(
      columns = list(
        a = list(type = "character", class = "numeric", optional = TRUE),
        b = list(type = "integer", class = "factor", optional = TRUE)
      ),
      check_duplicates = FALSE,
      check_completeness = FALSE
    ),
    data = data.frame(a = 1, b = 2L, stringsAsFactors = FALSE)
  )

  validator <- check_types(validator)

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$n_failing, 1)
  expect_equal(validator$log[[2]]$failing_ids, 1)
  expect_equal(validator$log[[3]]$outcome, "fail")
  expect_equal(validator$log[[3]]$n_failing, 1)
  expect_equal(validator$log[[3]]$failing_ids, 2)
})