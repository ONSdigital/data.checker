df <- data.frame(
    id = 1:3,
    date = lubridate::ymd(c("2024-06-01", "2024-06-02", "2024-06-03")),
    end_date = lubridate::ymd(c("2026-06-01", "2026-06-02", "2026-06-03"))
)

test_that("min value raises error if incorrect format", {
    columns <- list(
        id = list(type = "integer", optional = FALSE, min_val = 0, max_val = 10),
        date = list(type = "date", optional = FALSE, min_date = "01-01-2012"),
        end_date = list(type = "date", optional = TRUE)
    )

    expect_error( new_validator(
        schema = list(columns = columns, check_duplicates = FALSE, check_completeness = FALSE),
        data = df
    ), "Invalid date format for min_date in column 'date' use Year Month Day format")
})

test_that("max value raises error if incorrect format", {
    columns <- list(
        id = list(type = "integer", optional = FALSE, min_val = 0, max_val = 10),
        date = list(type = "date", optional = FALSE, max_date = "30/06/2024"),
        end_date = list(type = "date", optional = TRUE)
    )

    expect_error( new_validator(
        schema = list(columns = columns, check_duplicates = FALSE, check_completeness = FALSE),
        data = df
    ), "Invalid date format for max_date in column 'date', use Year Month Day format")
})

# test_that("max and min value error for different types", {
#     columns <- list(
#         id = list(type = "integer", optional = FALSE, min_val = 0, max_val = 10),
#         date = list(type = "date", optional = FALSE, min_date = "20120102", max_date = "2023.01.01"),
#         end_date = list(type = "date", optional = TRUE, min_date = 20250101, max_date = "2025-12-31")
#     )

#     expect_error(
#         new_validator(
#             schema = list(columns = columns, check_duplicates = FALSE, check_completeness = FALSE),
#             data = df
#         ),"Column end_date max_date and min_date must be of the same type."
#     )
# })

test_that("max and min value no error for different formats", {
    columns <- list(
        id = list(type = "integer", optional = FALSE, min_val = 0, max_val = 10),
        date = list(type = "date", optional = FALSE, min_date = "20120102", max_date = "2023.01.01"),
        end_date = list(type = "date", optional = TRUE, min_date = "2025/01/01", max_date = "2025-12-31")
    )

    expect_no_error(
        new_validator(
            schema = list(columns = columns, check_duplicates = FALSE, check_completeness = FALSE),
            data = df
        )
    )
})