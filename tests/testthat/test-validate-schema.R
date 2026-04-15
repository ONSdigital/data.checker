test_that("is_valid_schema returns TRUE for a valid schema", {
schema = list(
    columns = list(
      col1 = list(type = "int", max_val = 10, min_val = 0, optional = FALSE),
      col2 = list(type = "decimal",optional = FALSE),
      col3 = list(type = "string_length", max_string_length = 20, min_string_length = 5, optional = FALSE),
      col4 = list(type = "date", max_date = as.Date("2024-12-31"), min_date = as.Date("2020-01-01"), optional = FALSE),
      col5 = list(type = "datetime", max_datetime = as.POSIXct("2024-12-31 23:59:59"), min_datetime = as.POSIXct("2020-01-01 00:00:00"), optional = FALSE),
        col6 = list(type = "int", max_val = 10, optional = FALSE),
        col7 = list(type = "decimal", optional = FALSE)
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
  
  expect_error(is_column_contents_valid(schema), "Column col1 max_val cannot be less than min_val.")
})

test_that("is_valid_schema returns error (max_string_length < min_string_length)", {
schema = list(
    columns = list(
      col1 = list(type = "str", max_string_length = 0, min_string_length = 20, optional = FALSE)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_column_contents_valid(schema), "Column col1 max_string_length cannot be less than min_string_length.")
})

test_that("is_valid_schema returns error for correct column (max_date < min_date)", {
schema = list(
    columns = list(
      col1 = list(type = "date", max_date = as.Date("2024-01-01"), min_date = as.Date("2012-12-31"), optional = FALSE),
      col2 = list(type = "date", max_date = as.Date("2020-01-01"), min_date = as.Date("2024-12-31"), optional = FALSE)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_column_contents_valid(schema), "Column col2 max_date cannot be less than min_date.")
})

test_that("is_valid_schema returns error for mismatch types (max_val < min_val)", {
schema = list(
    columns = list(
      col1 = list(type = "int", max_val = 0, min_val = "20")
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_column_contents_valid(schema), "Column col1 max_val and min_val must be of the same type.")
})


test_that("is_valid_schema validator warning for allowed and forbidden strings", {
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

test_that("is_valid_schema doesnt return validator warning for allowed and forbidden strings in diff columns", {
df = data.frame(col1 = "hello!", col2 = "world!")
schema = list(
    columns = list(
      col1 = list(type = "character", allowed_strings = c("a","b"), optional = FALSE),
      col2 = list(type = "character", forbidden_strings = c("c","d"), optional = FALSE)
      ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  validator <- new_validator(schema = schema, data = df) |> check()
  expect_false(validator$log[[2]]$description == "Column col1 allowed_strings and forbidden_strings cannot both be present. Using allowed_strings only.")
  expect_false(validator$log[[2]]$description == "Column col2 allowed_strings and forbidden_strings cannot both be present. Using allowed_strings only.")
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

test_that("is_valid_schema returns error for two incorrect column types", {
schema = list(  
    columns = list(
      col1 = list(type = "decimal", max_val = 10, min_val = 0),
      col2 = list(type = "letters", max_string_length = 20, min_string_length = 5)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_type_valid(schema), "The following columns have invalid types: col1, col2. Accepted types are")
})

test_that("is_valid_schema returns error one incorrect column type", {
schema = list(  
    columns = list(
      col1 = list(type = "numeric", max_val = 10, min_val = 0),
      col2 = list(type = "letters", max_string_length = 20, min_string_length = 5),
      col3 = list(type = "character", max_string_length = 20, min_string_length = 5)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_type_valid(schema), "The following columns have invalid types: col2. Accepted types are")
})

test_that("error is returned when column is missing optional field", {
schema = list(
    columns = list(
      col1 = list(type = "numeric", max_val = 10, min_val = 0),
      col2 = list(type = "character", max_string_length = 20, min_string_length = 5)
    ),
    check_duplicates = TRUE,
    check_completeness = TRUE
  )
  
  expect_error(is_column_contents_valid(schema), "Column col1 must have an 'optional' field set to either TRUE or FALSE")
}
)
