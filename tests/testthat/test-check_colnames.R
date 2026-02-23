test_that("The code returns no errors when the column names are correct", {
  df <- data.frame(a = 1, b = 2, c = 3)
  columns <- list(
    a = list(type = "numeric", optional = TRUE),
    b = list(type = "character", optional = TRUE),
    c = list(type = "logical", optional = FALSE)
  )

  validator <- new_validator(
    schema = list(
      columns = columns, 
      hard_checks = TRUE, 
      check_duplicates = FALSE,
      check_completeness = FALSE
    ),
    data = df
  )
  validator <- check_colnames(validator)

  for (entry in validator$log[2:5]) {
    expect_equal(entry$outcome, "pass")
    expect_equal(entry$n_failing, 0)
    expect_equal(entry$failing_ids, NA)
  }

})

test_that("Column names with incorrect style return errors", {
  df <- data.frame(A = 1, B.1 = 2, "c " = 3, check.names = FALSE)
  columns <- list(
    A = list(type = "numeric", optional = TRUE),
    B.1 = list(type = "character", optional = TRUE),
    "c " = list(type = "logical", optional = FALSE))

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  )
  validator <- check_colnames(validator)

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[3]]$outcome, "fail")
  expect_equal(c(validator$log[[2]]$n_failing, validator$log[[3]]$n_failing), c(2, 2))
})

test_that("Missing mandatory columns return errors", {
  df <- data.frame(a = 1, b = 2, check.names = FALSE)
  columns <- list(
    a = list(type = "numeric", optional = TRUE),
    b = list(type = "character", optional = TRUE),
    c = list(type = "logical", optional = FALSE)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) 
  validator <- check_colnames(validator)

  expect_equal(validator$log[[4]]$outcome, "fail")
  expect_equal(validator$log[[4]]$n_failing, 1)
  expect_equal(validator$log[[4]]$failing_ids, NA)
})

test_that("Unexpected columns return errors", {
  df <- data.frame(a = 1, b = 2, c = 3, d = 4, check.names = FALSE)
  columns <- list(
    a = list(type = "numeric", optional = TRUE),
    b = list(type = "character", optional = TRUE),
    c = list(type = "logical", optional = FALSE)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  )
  validator <- check_colnames(validator)

  expect_equal(validator$log[[5]]$outcome, "fail")
  expect_equal(validator$log[[5]]$n_failing, 1)
  expect_equal(validator$log[[5]]$failing_ids, NA)
})

test_that("validator removes unnecessary schema info for optional columns", {
  df <- data.frame(a = 1, b = 2, check.names = FALSE)
  columns <- list(
    a = list(type = "numeric", optional = FALSE),
    b = list(type = "character", optional = FALSE),
    c = list(type = "logical", optional = TRUE)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  )
  validator <- check_colnames(validator)

  expect_false("c" %in% names(validator$schema$columns))

})
