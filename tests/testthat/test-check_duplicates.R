schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = list(
    a = list(type = "numeric"),
    b = list(type = "numeric")
  )
)

test_that("Checks correctly identify duplicates", {
  df <- data.frame(
    a = c(1, 2, 3, 1),
    b = c(2, 3, 4, 2)
  )

  validator <- new_validator(df, schema) |> check_duplicates()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]][["failing_ids"]], 4)
})

test_that("Checks correctly lack of duplicates", {
  df <- data.frame(
    a = c(1, 2, 3),
    b = c(2, 3, 4)
  )

  validator <- new_validator(df, schema) |> check_duplicates()

  expect_equal(validator$log[[2]]$outcome, "pass")
})
