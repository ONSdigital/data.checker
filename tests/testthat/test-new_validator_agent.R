df <- data.frame(a = 1.23, b = 2, c = 3)
columns <- list(
  a = list(type = "double", optional = TRUE, max_val = 100, min_val = 0),
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

test_that("new_validator accepts optional name", {
  validator <- new_validator(
    data = df,
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    ),
    name = "my-validator"
  )

  expect_identical(validator$name, "my-validator")
})

test_that("new_validator validates name input", {
  expect_error(
    new_validator(
      data = df,
      schema = list(
        columns = columns,
        check_completeness = FALSE,
        check_duplicates = FALSE
      ),
      name = c("a", "b")
    ),
    "name must be a single character string"
  )

  expect_error(
    new_validator(
      data = df,
      schema = list(
        columns = columns,
        check_completeness = FALSE,
        check_duplicates = FALSE
      ),
      name = 1
    ),
    "name must be a single character string"
  )
})

test_that("new_validator defaults name to data frame name", {
  validator <- new_validator(
    data = df,
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    )
  )

  expect_identical(validator$name, "df")

  validator <- new_validator(
    data = df[1:2, ],
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    )
  )

  expect_identical(validator$name, "df[1:2, ]")
})

test_that("new_validator allows users to specify custom name", {
  validator <- new_validator(
    data = df,
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    ),
    name = "custom-validator"
  )

  expect_identical(validator$name, "custom-validator")
})