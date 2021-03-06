expect_tibble_error <- function(object, cnd, fixed = NULL) {
  cnd_actual <- expect_error(object, regexp = cnd_message(cnd), class = class(cnd), fixed = TRUE)
  expect_cnd_equivalent(cnd_actual, cnd)
  expect_s3_class(cnd_actual, class(cnd), exact = TRUE)
}

expect_cnd_equivalent <- function(actual, expected) {
  actual$trace <- NULL
  actual$parent <- NULL
  actual$cnd_bullets <- NULL
  expected$trace <- NULL
  expected$parent <- NULL
  expected$cnd_bullets <- NULL
  expect_equivalent(actual, expected)
}

expect_error_cnd <- function(object, class, message = NULL, ..., .fixed = TRUE) {
  cnd <- expect_error(object, regexp = message, class = class, fixed = .fixed)
  expect_true(inherits_all(cnd, class))

  exp_fields <- list2(...)
  if (has_length(exp_fields)) {
    expect_true(is_empty(setdiff(!!names(exp_fields), names(cnd))))
    expect_equal(cnd[names(exp_fields)], exp_fields)
  }
}

expect_error_relax <- function(object, ...) {
  expect_error(object)
}

expect_known_tibble_error_output <- function(...) {
  quos <- enquos(...)

  vals <- map(quos, eval_tidy)

  functions <- map_chr(pluck(map(map(quos, quo_get_expr), as.list), 1), as_name)

  skip_on_non_utf8_locale()
  skip_on_cran()

  headers <- paste0("\n## ", functions, "()\n\n")
  header_same <- c(FALSE, headers[-1] == headers[-length(headers)])
  headers[header_same] <- ""

  output <- paste0(
    "# Errors\n",
    paste0(headers, map_chr(vals, cnd_message), collapse = "\n\n")
  )

  expect_known_output(cat(output), "errors.txt")
}
