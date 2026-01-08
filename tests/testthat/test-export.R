# Setup
df = data.frame(a= 1, b = 2,c = 3)
columns = list(
  a = list(type = "numeric", optional = TRUE),
  b = list(type = "character", optional = TRUE)
)

test <- new_validator(
  schema = list(columns = columns, hard_checks = TRUE, check_duplicates = FALSE, check_completeness = FALSE),
  data = df
) %>% check_colnames()

test_that("export function returns error if file path doesn't match format", {
  expect_error(export.Validator(test, "test.csv", format = "html"))
  expect_error(export.Validator(test, "test.csv", format = "json"))
  expect_error(export.Validator(test, "test.csv", format = "yaml"))
  expect_error(export.Validator(test, "test.html", format = "csv"))
})

test_that("export function exports the correct file type", {
  dir.create("temp")

  export.Validator(test, "temp/test.yaml", format = "yaml")
  export.Validator(test, "temp/test.json", format = "json")
  export.Validator(test, "temp/test.html", format = "html")
  export.Validator(test, "temp/test.csv", format = "csv")

  files <- list.files("temp", full.names = FALSE)

  expect_setequal(files, c("test.yaml", "test.json", "test.html", "test.csv"))

  unlink("temp", recursive = TRUE)
})

test_that("print function works correctly", {
  expect_output(print.Validator(test))
})
