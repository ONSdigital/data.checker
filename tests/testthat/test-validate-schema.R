test_that("is_valid_schema returns TRUE for a valid schema", {
schema = list(
    columns = list(
      col1 = list(type = "int", max_val = 10, min_val = 0),
      col2 = list(type = "decimal", max_decimal = 5, min_decimal = 0),
      col3 = list(type = "string_length", max_string_length = 20, min_string_length = 5),
      col4 = list(type = "date", max_date = as.Date("2024-12-31"), min_date = as.Date("2020-01-01")),
      col5 = list(type = "datetime", max_datetime = as.POSIXct("2024-12-31 23:59:59"), min_datetime = as.POSIXct("2020-01-01 00:00:00")),
        col6 = list(type = "int", max_val = 10),
        col7 = list(type = "decimal", min_decimal = 0)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_true(is_valid_schema(schema))
})

test_that("is_valid_schema returns error (max_val < min_val)", {
schema = list(
    columns = list(
      col1 = list(type = "int", max_val = 0, min_val = 20)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_valid_schema(schema), "Column col1 max_val cannot be less than min_val.")
})

test_that("is_valid_schema returns error (max_string_length < min_string_length)", {
schema = list(
    columns = list(
      col1 = list(type = "str", max_string_length = 0, min_string_length = 20)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_valid_schema(schema), "Column col1 max_string_length cannot be less than min_string_length.")
})

test_that("is_valid_schema returns error for correct column (max_date < min_date)", {
schema = list(
    columns = list(
      col1 = list(type = "date", max_date = as.Date("2024-01-01"), min_date = as.Date("2012-12-31")),
      col2 = list(type = "date", max_date = as.Date("2020-01-01"), min_date = as.Date("2024-12-31"))
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_valid_schema(schema), "Column col2 max_date cannot be less than min_date.")
})


test_that("is_valid_schema returns error for allowed and forbidden strings", {
df = data.frame(col1 = "hello!")
schema = list(
    columns = list(
      col1 = list(type = "character", allowed_strings = c("a","b"), forbidden_strings = c("c","d"), optional = FALSE)
      ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  validator <- new_validator(schema = schema, data = df) |> check()
  expect_equal(validator$log[[2]]$description, "Column col1 allowed_strings and forbidden_strings cannot both be present. Using allowed_strings only.")
  expect_true(is.null(validator$schema$columns$col1$forbidden_strings))
})

test_that("unused schema args are put into the log", {
df = data.frame(a = "hello!")
schema = list(
    columns = list(
      a = list(type = "character", accepted_strings = c("a","b"), optional = FALSE)
      ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  validator <- new_validator(schema = schema, data = df) |> check()
  expect_equal(validator$log[[2]]$description, "Column a unused schema entries: accepted_strings")
})

test_that("warning when completeness cols not in df", {
df = data.frame(a = "hello!", b = "world!")
schema = list(
    columns = list(
      a = list(type = "character", optional = FALSE),
      b = list(type = "character", optional = FALSE)
      ),
    check_duplicates = TRUE,
    check_completeness = TRUE,
    completeness_cols = c("b", "c")
  )
  expect_error(validator <- new_validator(schema = schema, data = df) |> check(), "All columns specified in completeness_cols must be present in the data.")
})