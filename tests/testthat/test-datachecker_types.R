test_that("Input data is list produces error", {
  df = list(a= 1, b = "hello!", c = NA)
  columns = list(
    a = list(type = "double", optional = TRUE, max_val = 0.5),
    b = list(type = "character", forbidden_strings = "[[:punct:]]", optional = TRUE),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = FALSE)
  )

    expect_error(
        new_validator(
                schema = list(columns = columns, hard_checks = TRUE),
                data = df
            ),
    )

})

test_that("Schema is not list produces error", {
  df = data.frame(a= 1, b = "hello!", c = NA)
  columns = list(
    a = list(type = "double", optional = TRUE, max_val = 0.5),
    b = list(type = "character", forbidden_strings = "[[:punct:]]", optional = TRUE),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = FALSE)
  )

    expect_error(
        new_validator(
                schema =  TRUE,
                data = df
            ),
    )

})

test_that("schema is not named list produces error", {
  df = data.frame(a= 1, b = "hello!", c = NA)
  columns = list(
    a = list(type = "double", optional = TRUE, max_val = 0.5),
    b = list(type = "character", forbidden_strings = "[[:punct:]]", optional = TRUE),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = FALSE)
  )

    expect_error(
        new_validator(
                schema = list(columns, TRUE),
                data = df
            ),
    )

})

test_that("schema is does not contain column produces error", {
  df = data.frame(a= 1, b = "hello!", c = NA)
  columns = list(
    a = list(type = "double", optional = TRUE, max_val = 0.5),
    b = list(type = "character", forbidden_strings = "[[:punct:]]", optional = TRUE),
    c = list(type = "double", optional = TRUE, min_val = 0, max_val = 10, allow_na = FALSE)
  )

    expect_error(
        new_validator(
                schema = list(hard_checks = TRUE),
                data = df
            ),
    )

})
