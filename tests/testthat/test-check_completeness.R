schema <- list(
  check_completeness = TRUE,
  completeness_cols = c("a", "b"),
  check_duplicates = FALSE,
  columns = list(
    a = list(type = "float"),
    b = list(type = "character")
  )
)

df <- data.frame(
  a = c(1, 2, 1, 2, 1, 2),
  b = c("a", "a", "b", "b", "c", "c")
)

test_that("completeness check returns TRUE when data is complete", {
  validator <- new_validator(df, schema)
  validator$agent <- pointblank::create_agent(tbl = df) 
  validator <- check_completeness(validator)

  expect_equal(validator$log[[2]]$outcome, "pass")
})


test_that("completeness check returns FALSE when data is complete", {
  df <- data.frame(
    a = c(1, 2, 1, 2, 1),
    b = c("a", "a", "b", "b", "c")
  )

  validator <- new_validator(df, schema)
  validator$agent <- pointblank::create_agent(tbl = df) 
  validator <- check_completeness(validator)

  expect_equal(validator$log[[2]]$outcome, "fail")
})
