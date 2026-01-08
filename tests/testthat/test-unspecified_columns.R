test_that("Only Required checks are run for all columns in dataframe", {
    # Columns in dataframe but not schema: c, d, h
    # Columns in schema but not dataframe: f
    df <- data.frame(
        a = c(1.23, 2.34, 3.45, 4.56, NA),
        b = c("one", "two", "three", "four", "five"),
        c = c(NA, NA, NA, NA, NA),
        d = c(2, 3, 4, 5, 6),
        g = c("te", "st", "in", "g", "ok"),
        e = as.Date(c("2022-01-01", "2022-02-01", "2022-03-01", "2022-04-01", "2022-05-01")),
        h = c(1, 3, 4, 5, 6),
        i = lubridate::parse_date_time(c("2022-01-01 12:00:00", "2022-02-01 13:30:00", "2022-03-01 15:45:00", "2022-04-01 09:15:00", "2022-05-01 18:00:00"), orders = "ymd HMS")
    )
    # Issues with datetime datatypes when validating schema,
    columns <- list(
        a = list(type = "double", optional = FALSE, allow_na = FALSE, max_val = 100, min_val = 0, max_decimal = 2, min_decimal = 0),
        b = list(type = "character", optional = FALSE, min_string_length = 0, max_string_length = 10, allowed_strings = "^.{0,4}$"),
        g = list(type = "character", optional = FALSE, min_string_length = 0, max_string_length = 2, forbidden_strings = "[[:punct:]]"),
        e = list(type = "date", optional = FALSE, allow_na = TRUE, min_date = "2020-01-01", max_date = "2023-12-31"),
        f = list(type = "integer", optional = FALSE, min_val = 0, max_val = 10),
        i = list(type = "datetime", optional = TRUE, allow_na = TRUE, min_datetime = "2020-01-01 01:00:00", max_datetime = "2023-12-31 01:00:00")
    )

    validator <- new_validator(
        schema = list(columns = columns, check_duplicates = FALSE, check_completeness = FALSE),
        data = df
    ) |> check()
    # Expecting:
    # 15 data checks for columns a (5), b(3), g(3), e(2), i(2)
    # 7 overall checks on column names and expected columns
    # 1 log entry is system information.
    expect_equal(length(validator$log), 23)
})

