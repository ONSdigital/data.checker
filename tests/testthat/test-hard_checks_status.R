df <- data.frame(a = 1.23, b = 2, c = 3)
columns <- list(
  a = list(type = "double", optional = TRUE, max_val = 100, min_val = 0, max_decimal = 2, min_decimal = 0),
  b = list(type = "character", optional = TRUE, min_string_length = 0, max_string_length = 10)
)
schema <- list(
  check_duplicates = FALSE,
  check_completeness = FALSE,
  columns = columns)

out <- new_validator(
    data = df,
    schema = list(
      columns = columns,
      check_completeness = FALSE,
      check_duplicates = FALSE
    )
  ) %>%
    check()

test_that("The code returns errors when incorrect and hard_checks TRUE", {

  expect_error(
    out %>%
      hard_checks_status(hard_check = TRUE),
    regexp = paste0(
      "Hard checks failed: 2 error(s) found, ",
      "see log output for more details"
    ),
    fixed = TRUE
  )
})

test_that("The code returns warning when incorrect and hard_checks FALSE", {

  expect_warning(
    out %>%
      hard_checks_status(hard_check = FALSE),
    regexp = paste0(
      "Soft checks failed: 2 error(s) found, ",
      "see log output for more details"
    ),
    fixed = TRUE
  )
})

validator <- new_validator(
    schema = list(
      columns = columns,
      check_duplicates = FALSE, check_completeness = FALSE
    ),
    data = df
  )

out <- add_qa_entry(
    validator = validator,
    description = "Test entry 2",
    outcome =  FALSE,
    failing_ids = c(4,5),
    entry_type = "warning"
  )

test_that("The code returns warning when hard_check true", {

  expect_warning(
    out %>% hard_checks_status(hard_check = TRUE),
    regexp = paste0(
      "Soft checks failed: 1 warning(s) found, ",
      "see log output for more details"
    ),
    fixed = TRUE
  )
})

