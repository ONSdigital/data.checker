df <- data.frame(
  age = c(10, 11, 13, 15, 22, 34, 80),
  sex = c("M", "F", "M", "F", "M", "F", "M")
)

schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    age = list(type = "integer", optional = FALSE),
    sex = list(type = "character", optional = FALSE)
  )
)

validator <- new_validator(df, schema)

test_that("custom checks work with standard evaluation", {
  condition <- df$age > 20

  expect_no_error(
    add_check(
      validator,
      description = "Age greater than 20",
      condition = condition,
      type = "error",
      rowwise = TRUE
    )
  )
})

test_that("custom checks work within validator$data environment", {
  expect_no_error(
    add_check(
      validator,
      description = "Age greater than 20",
      condition = age > 20,
      type = "error",
      rowwise = TRUE
    )
  )

  validator <- validator |> add_check("Age greater than 20", condition = age > 20)

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, c(1, 2, 3, 4))
  expect_equal(validator$log[[2]]$n_failing, 4)
})
