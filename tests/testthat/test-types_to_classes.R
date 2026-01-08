schema <- list(
  columns = list(
    a = list(type = "factor"),
    b = list(type = "Date"),
    c = list(type = "datetime"),
    d = list(type = "time")
  )
)

schema <- types_to_classes(schema)

test_that("Complex types are converted to the correct classes", {
    expect_equal(schema$columns$a$type, "integer")
    expect_equal(schema$columns$a$class, "factor")
    expect_equal(schema$columns$b$type, "double")
    expect_equal(schema$columns$b$class, "Date")
    expect_equal(schema$columns$c$type, "double")
    expect_equal(schema$columns$c$class, c("POSIXct", "POSIXt"))
    expect_equal(schema$columns$d$type, "double")
    expect_equal(schema$columns$d$class, c("POSIXct", "POSIXt"))
})
