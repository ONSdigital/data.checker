# Tests for check_backseries

test_that("column names and row checks pass when the data matches the backseries", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(5, 6, 7, 8),
    y = c("a", "c", "d", "e")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  validator <- check_backseries(validator)
  expect_equal(validator$log[[2]]$outcome,"pass")
  expect_equal(validator$log[[2]]$description,"Number of rows is consistent with previous data")
  expect_equal(validator$log[[3]]$description,"Column names match previous data")
  expect_equal(validator$log[[3]]$outcome,"pass")
})

test_that("column names and row checks fail when the data does not match the backseries", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(5, 6, 7),
    z = c("a", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  validator <- check_backseries(validator)
  for (i in 2:3) {
    expect_equal(validator$log[[i]]$outcome,"fail")
    expect_equal(validator$log[[i]]$failing_ids, NA)
  }
  expect_equal(validator$log[[2]]$description,"Number of rows is consistent with previous data")
  expect_equal(validator$log[[3]]$description,"Column names match previous data")
})

test_that("threshold checks catch errors", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 10),
    y = c("a", "b", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_cols = list(
        x = list(
          match_cols = "y",
          threshold_prop = .5,
          threshold_abs = 1
        )
      )
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()

  expect_equal(out$log[[length(out$log) - 1]]$outcome, "fail")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, 4)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 1)

  expect_equal(out$log[[length(out$log)]]$outcome, "fail")
  expect_equal(out$log[[length(out$log)]]$failing_ids, 4)
  expect_equal(out$log[[length(out$log)]]$n_failing, 1)
})

test_that("threshold checks pass when differences are within limits", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 5),
    y = c("a", "b", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_cols = list(
        x = list(
          match_cols = "y",
          threshold_prop = 0.25,
          threshold_abs = 1
        )
      )
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()
  
  expect_equal(out$log[[length(out$log) - 1]]$outcome, "pass")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 0)

  expect_equal(out$log[[length(out$log)]]$outcome, "pass")
  expect_equal(out$log[[length(out$log)]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log)]]$n_failing, 0)
})

test_that("completeness backseries check catches error", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 5),
    y = c("a", "c", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_unique_vals = c("x", "y")
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()

  expect_equal(out$log[[length(out$log) - 1]]$outcome, "fail")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 1)

  expect_equal(out$log[[length(out$log)]]$outcome, "fail")
  expect_equal(out$log[[length(out$log)]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log)]]$n_failing, 1)
})

test_that("threshold checks catch errors", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 10),
    y = c("a", "b", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_cols = list(
        x = list(
          match_cols = "y",
          threshold_prop = .5,
          threshold_abs = 1
        )
      )
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()

  expect_equal(out$log[[length(out$log) - 1]]$outcome, "fail")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, 4)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 1)

  expect_equal(out$log[[length(out$log)]]$outcome, "fail")
  expect_equal(out$log[[length(out$log)]]$failing_ids, 4)
  expect_equal(out$log[[length(out$log)]]$n_failing, 1)
})

test_that("threshold checks pass when differences are within limits", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 5),
    y = c("a", "b", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_cols = list(
        x = list(
          match_cols = "y",
          threshold_prop = 0.25,
          threshold_abs = 1
        )
      )
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()
  
  expect_equal(out$log[[length(out$log) - 1]]$outcome, "pass")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 0)

  expect_equal(out$log[[length(out$log)]]$outcome, "pass")
  expect_equal(out$log[[length(out$log)]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log)]]$n_failing, 0)
})

test_that("completeness backseries check catches error", {
  data <- data.frame(
    x = c(1, 2, 3, 4),
    y = c("a", "b", "c", "d")
  )
  backseries <- data.frame(
    x = c(1, 2, 3, 5),
    y = c("a", "c", "c", "d")
  )

  schema <- list(
    check_completeness = FALSE,
    check_duplicates = FALSE,
    columns = list(
      x = list(optional = FALSE, type = "numeric"),
      y = list(optional = FALSE, type = "character")
    ),
    backseries = list(
      check_n_rows = TRUE,
      check_cols_match = TRUE,
      check_unique_vals = c("x", "y")
    )
  )

  validator <- new_validator(
    data = data,
    schema = schema,
    backseries = backseries
  )

  out <- validator |> check_backseries()

  expect_equal(out$log[[length(out$log) - 1]]$outcome, "fail")
  expect_equal(out$log[[length(out$log) - 1]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log) - 1]]$n_failing, 1)

  expect_equal(out$log[[length(out$log)]]$outcome, "fail")
  expect_equal(out$log[[length(out$log)]]$failing_ids, NA)
  expect_equal(out$log[[length(out$log)]]$n_failing, 1)
})