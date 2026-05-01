dummy_log <- list(
  list(
    timestamp = "12:00:00",
    description = "System info",
    outcome = NA,
    failing_ids = NULL,
    n_failing = NA,
    entry_type = "info"
  ),
  list(
    timestamp = "12:01:00",
    description = "Check 1",
    outcome = "pass",
    failing_ids = NA,
    n_failing = 0,
    entry_type = "error"
  ),
  list(
    timestamp = "12:02:00",
    description = "Check 2",
    outcome = "fail",
    failing_ids = 1:20,
    n_failing = 20,
    entry_type = "error"
  ),
  list(
    timestamp = "12:03:00",
    description = "Check 3",
    outcome = "fail",
    failing_ids = 1:5,
    n_failing = 5,
    entry_type = "error"
  )
)

table <- log_to_table(dummy_log)

test_that("table headings are correct", {
  expect_equal(colnames(table), c("Timestamp", "Description", "Outcome", "Failing Ids", "n Failing", "Entry Type"))
})

test_that("failing ids are correctly formatted", {
  expect_equal(table$`Failing Ids`[1], "")
  expect_equal(table$`Failing Ids`[2], "")
  expect_equal(table$`Failing Ids`[3], "1, 2, 3, 4, 5, 6, 7, 8, 9, 10 (+ 10)")
  expect_equal(table$`Failing Ids`[4], "1, 2, 3, 4, 5")
})

