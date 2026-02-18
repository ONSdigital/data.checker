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

  validator <- new_validator(df, schema)
  validator$agent <- pointblank::create_agent(tbl=df)
  validator <- check_duplicates(validator)

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]][["failing_ids"]], c(1, 4))
})

test_that("Checks correctly identifies lack of duplicates", {
  df <- data.frame(
    a = c(1, 2, 3),
    b = c(2, 3, 4)
  )

  validator <- new_validator(df, schema) 
  validator$agent <- pointblank::create_agent(tbl=df)

  validator <- check_duplicates(validator)

  expect_equal(validator$log[[2]]$outcome, "pass")
})


#AI generated - check!
test_that("check_duplicates respects check_duplicates_cols in schema", {
  df <- data.frame(
    a = c(1, 1, 2, 2),
    b = c(2, 2, 3, 4),
    c = c("x", "y", "y", "y")
  )

  schema <- list(
    check_duplicates = TRUE,
    check_duplicates_cols = c("a", "b"),
    check_completeness = FALSE,
    columns = list(
      a = list(type = "numeric"),
      b = list(type = "numeric"),
      c = list(type = "character")
    )
  )

  validator <- new_validator(df, schema)
  validator$agent <- pointblank::create_agent(tbl = df)
  validator <- check_duplicates(validator)

  expect_true(any(sapply(validator$log, function(x) grepl("duplicated rows", x$description))))
  expect_true(any(sapply(validator$log, function(x) x$outcome == "fail")))
})

