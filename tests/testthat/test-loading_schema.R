df <- data.frame(a = 1.23, b = "a")

test_that("The schema is loaded correctly for JSON", {
  expect_no_error(new_validator(schema = "test_schema.json", data = df))
})

test_that("The schema is loaded correctly for YAML", {
  expect_no_error(new_validator(schema = "test_schema.yaml", data = df))
})

test_that("The schema is loaded correctly for toml", {
  validator <- new_validator(schema = "test_schema.toml", data = df)
  validator$agent <- pointblank::create_agent(tbl = df)
  expect_no_error(validator <- validator |> check() |>
                  hard_checks_status(hard_check = TRUE))
})

test_that("The schema is loaded incorrectly for csv", {
  expect_error(new_validator(schema = "test_schema.csv", data = df))
})
