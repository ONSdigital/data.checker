test_that("The code returns no errors when the column contents are correct", {
  df <- data.frame(a = 1.23, b = 2, c = NA)
  columns <- list(
    a = list(type = "double", optional = TRUE, max_val = 100, min_val = 0, max_decimal = 2, min_decimal = 0),
    b = list(type = "character", optional = TRUE, min_string_length = 0, max_string_length = 10),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = TRUE)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, characters = list(forbidden_characters = "[[:punct:]]"),
                  check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  for (entry in validator$log[2:length(validator$log)]) {
    if (is.na(entry$outcome)) {
      expect_true(entry$entry_type == "info")
    } else {
      expect_equal(entry$outcome, "pass")
      expect_equal(entry$n_failing, "N/A")
      expect_equal(entry$failing_ids, integer())
    }
  }
})

test_that("The code returns errors when the numeric contents are outside ranges", {
  df <- data.frame(a = c(-1, 101.11, -50))
  columns <- list(
    a = list(type = "double", optional = TRUE, max_val = 100, min_val = 0, max_decimal = 1, min_decimal = 0)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, characters = list(allowed_characters = "^[A-Za-z0-9]+$", forbidden_strings = "[[:punct:]]"),
                  check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, c(1, 3))
  expect_equal(validator$log[[2]]$n_failing, 2)

  expect_equal(validator$log[[3]]$outcome, "fail")
  expect_equal(validator$log[[3]]$failing_ids, c(2))
  expect_equal(validator$log[[3]]$n_failing, 1)

  expect_equal(validator$log[[5]]$outcome, "fail")
  expect_equal(validator$log[[5]]$failing_ids, c(2))
  expect_equal(validator$log[[5]]$n_failing, 1)

})

test_that("Column with incorrect content return errors", {
  df = data.frame(a= 1, b = "hello!", c = NA)
  columns = list(
    a = list(type = "double", optional = TRUE, max_val = 0.5),
    b = list(type = "character", forbidden_strings = "[[:punct:]]", optional = TRUE),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = FALSE)
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[3]]$outcome, "fail")
  expect_equal(validator$log[[4]]$outcome, "fail")

})

test_that("Factor checks work correctly", {
  df <- data.frame(a = factor(c("A", "B", "C")), b = factor(c("X", "Y", "Z")))
  columns <- list(
    a = list(type = "integer", class = "factor", expected_levels = c("A", "B", "C")),
    b = list(type = "integer", class = "factor", expected_levels = c("A", "B", "C"))
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "pass")
  expect_equal(validator$log[[3]]$outcome, "fail")
})

test_that("Date checks work correctly", {
  df <- data.frame(a = as.Date(c("2020-01-01", "2020-02-01", "2020-03-01")), b = as.Date(c("2020-01-01", "2020-02-30", "2020-03-01")))
  columns <- list(
    a = list(type = "Date", optional = TRUE, min_date = "2019-12-31", max_date = "2021-01-01"),
    b = list(type = "Date", optional = TRUE, min_date = "2021-12-31", max_date = "2019-01-01")
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "pass")
  expect_equal(validator$log[[3]]$outcome, "pass")
  expect_equal(validator$log[[4]]$outcome, "fail")
  expect_equal(validator$log[[4]]$failing_ids, c(1, 3))
  expect_equal(validator$log[[5]]$outcome, "fail")
  expect_equal(validator$log[[5]]$failing_ids, c(1,3))
})

test_that("Datetime checks work correctly", {
  df <- data.frame(a = strptime(c("2020-01-01 12:00", "2020-02-01 12:00", "2020-03-01 12:00"), format = "%Y-%m-%d %H:%M"),
                   b = strptime(c("2020-01-01 12:00", "2020-02-30 12:00", "2020-03-01 12:00"), format = "%Y-%m-%d %H:%M"))
  columns <- list(
    a = list(type = "datetime", optional = TRUE, min_datetime = "2019-12-31 11:59", max_datetime = "2021-01-01 13:00"),
    b = list(type = "datetime", optional = TRUE, min_datetime = "2021-12-31 11:59", max_datetime = "2019-01-01 13:00")
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "pass")
  expect_equal(validator$log[[3]]$outcome, "pass")
  expect_equal(validator$log[[4]]$outcome, "fail")
  expect_equal(validator$log[[4]]$failing_ids, c(1,3))
  expect_equal(validator$log[[5]]$outcome, "fail")
  expect_equal(validator$log[[5]]$failing_ids, c(1,3))
})

test_that("allowed strings for regex expressions work correctly", {
  df <- data.frame(a = c("abc123", "def", "sda:@"))
  columns <- list(
    a = list(type = "character", optional = TRUE, allowed_strings = "(^[a-z]+$)")
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, c(1, 3))
})

test_that("allowed strings for given list work correctly", {
  df <- data.frame(a = c("abc123", "def", "sda:@"))
  columns <- list(
    a = list(type = "character", optional = TRUE, allowed_strings = c("abc", "def", "sda"))
  )

  validator <- new_validator(
    schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, c(1, 3))
})

test_that("forbidden strings for given list work correctly", {
  df <- data.frame(a = c("abc123", "def", "@"))
  columns <- list(
    a = list(type = "character", optional = TRUE, forbidden_strings = c("abc123", ":", "@"))
  )

  validator <- new_validator(
    schema = list(columns = columns, check_completeness = FALSE, check_duplicates = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, c(1, 3))
})

test_that("duplicate checks return correct outcomes", {
  df <- data.frame(a = c(1, 2, 3, 1))
  columns <- list(
    a = list(type = "character", optional = FALSE, allow_duplicates = FALSE)
  )

  validator <- new_validator(
    schema = list(columns = columns, check_completeness = FALSE, check_duplicates = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "fail")
  expect_equal(validator$log[[2]]$failing_ids, 4)

  df <- data.frame(a = c(1, 2, 3))

  validator <- new_validator(
    schema = list(columns = columns, check_completeness = FALSE, check_duplicates = FALSE),
    data = df
  ) %>% check_column_contents()

  expect_equal(validator$log[[2]]$outcome, "pass")
})

convert_to_regex <- function(forbidden_strings) {
  escaped_strings <- gsub("([\\^$.|?*+(){}\\[\\]])", "\\\\\\1", forbidden_strings)
  regex_pattern <- paste0("^", escaped_strings, "$", collapse = "|")
  return(regex_pattern)
}

