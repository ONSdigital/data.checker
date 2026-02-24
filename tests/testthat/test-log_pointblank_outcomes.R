# Test for log_pointblank_outcomes
df <- data.frame(
  x = c(1, 2, 3, 4),
  y = c("a", "b", "c", "d")
)

agent <- 
  pointblank::create_agent(tbl = df) |>
  pointblank::col_exists(columns = pointblank::vars(x, y)) |>
  pointblank::col_is_numeric(columns = pointblank::vars(x)) |>
  pointblank::col_is_numeric(columns = pointblank::vars(y)) |>
  pointblank::interrogate( progress = FALSE)

validator <- list(
  agent = agent,
  log = list(list(
    timestamp = Sys.time(),
    description = "Initial log entry",
    outcome = "info",
    failing_ids = NA,
    n_failing = 0,
    entry_type = "info"
  ))
)

output <- log_pointblank_outcomes(validator)

test_that("log_pointblank_outcomes preserves existing log and appends outcomes", {
  expect_equal(length(output$log), 5)
  expect_identical(output$log[[1]], validator$log[[1]])
})

test_that("log_pointblank_outcomes captures correct outcomes", {
  expect_true(grepl("pass", output$log[[2]]$outcome, fixed = TRUE))
  expect_true(grepl("pass", output$log[[3]]$outcome, fixed = TRUE))
  expect_true(grepl("pass", output$log[[4]]$outcome, fixed = TRUE))
  expect_true(grepl("fail", output$log[[5]]$outcome, fixed = TRUE))
  expect_equal(output$log[[5]]$n_failing, 1)
})