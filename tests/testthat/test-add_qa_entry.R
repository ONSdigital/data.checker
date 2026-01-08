validator <- new_validator(
  schema = list(
    columns = list(
      a = list(type = "numeric", optional = TRUE),
      b = list(type = "character", optional = TRUE)
    ),
    check_duplicates = FALSE, check_completeness = FALSE
  ),
  data = data.frame(a = 1, b = 2)
)

test_that("the QA log entry is added correctly", {
  out <- add_qa_entry(
      validator = validator,
      description = "Test entry",
      outcome =  FALSE,
      failing_ids = c(1,2,3),
      entry_type = "error"
  )

  # Ignore timestamp for test purposes
  expected <- list(
    description = "Test entry",
    outcome = "fail",
    failing_ids = c(1, 2, 3),
    n_failing = 3,
    entry_type = "error"
  )

  expect_equal(out$log[[2]][2:6], expected)
})

test_that("The function works without being supplied optional arguments",{
    expect_no_error(add_qa_entry(
        validator = validator,
        description = "Test entry",
        outcome = NA
    ))
})

